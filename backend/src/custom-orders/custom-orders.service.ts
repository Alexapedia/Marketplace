import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { AddressesService } from '../addresses/addresses.service';
import { AuditService } from '../audit/audit.service';
import { ChatRealtimeService } from '../chat/chat-realtime.service';
import { CUSTOM_ORDER_STATUSES } from '../common/constants';
import { paginationMeta } from '../common/dto/pagination.dto';
import { AuthUser } from '../common/types/auth-user';
import { toObjectId } from '../common/utils/mongo';
import { NotificationsService } from '../notifications/notifications.service';
import { OrdersService } from '../orders/orders.service';
import {
  Conversation,
  ConversationDocument,
} from '../schemas/conversation.schema';
import {
  CustomOrder,
  CustomOrderDocument,
  Proposal,
} from '../schemas/custom-order.schema';
import { Message, MessageDocument } from '../schemas/message.schema';
import { User, UserDocument } from '../schemas/user.schema';
import {
  AdminUpdateCustomOrderDto,
  ConfirmProposalDto,
  CreateCustomOrderDto,
  CreateMessageDto,
  CreateProposalDto,
  RejectProposalDto,
} from './dto/custom-order.dto';

@Injectable()
export class CustomOrdersService {
  constructor(
    @InjectModel(CustomOrder.name)
    private readonly customModel: Model<CustomOrderDocument>,
    @InjectModel(Conversation.name)
    private readonly conversationModel: Model<ConversationDocument>,
    @InjectModel(Message.name)
    private readonly messageModel: Model<MessageDocument>,
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
    private readonly orders: OrdersService,
    private readonly addresses: AddressesService,
    private readonly notifications: NotificationsService,
    private readonly audit: AuditService,
    private readonly realtime: ChatRealtimeService,
  ) {}

  private parseMaybeJson(value: unknown) {
    if (typeof value === 'string') {
      try {
        return JSON.parse(value);
      } catch {
        return value;
      }
    }
    return value;
  }

  async create(
    userId: string,
    dto: CreateCustomOrderDto,
    attachmentUrls: string[] = [],
  ) {
    const doc = await this.customModel.create({
      userId: new Types.ObjectId(userId),
      categoryId: toObjectId(dto.categoryId, 'categoryId'),
      fields: this.parseMaybeJson(dto.fields) ?? {},
      description: dto.description,
      attachments: attachmentUrls,
      status: dto.status === 'draft' ? 'draft' : 'submitted',
    });
    if (doc.status === 'submitted') {
      try {
        await this.notifications.notifyRoles({
          roles: ['super_admin', 'admin', 'order_manager', 'support_agent'],
          title: { en: 'New custom order', ar: 'طلب خاص جديد' },
          body: {
            en: 'A customer submitted a custom order.',
            ar: 'عميل أرسل طلب خاص جديد.',
          },
          type: 'new_custom_order',
          data: { customOrderId: String(doc._id) },
        });
      } catch {
        // Staff alerts should not fail submission.
      }
    }
    return doc;
  }

  async listMine(userId: string, page: number, limit: number) {
    const filter = { userId: new Types.ObjectId(userId) };
    const [items, total] = await Promise.all([
      this.customModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .populate('categoryId', 'names'),
      this.customModel.countDocuments(filter),
    ]);
    return { data: items, meta: paginationMeta(total, page, limit) };
  }

  async findMine(userId: string, id: string) {
    const doc = await this.customModel
      .findOne({
        _id: toObjectId(id),
        userId: new Types.ObjectId(userId),
      })
      .populate('categoryId', 'names');
    if (!doc) {
      throw new NotFoundException('Custom order not found');
    }
    return doc;
  }

  private findProposal(order: CustomOrderDocument, proposalId: string) {
    const proposal = order.proposals.find(
      (p) => String((p as Proposal & { _id?: Types.ObjectId })._id) === proposalId,
    );
    if (!proposal) {
      throw new NotFoundException('Proposal not found');
    }
    return proposal;
  }

  async confirm(userId: string, id: string, dto: ConfirmProposalDto, channel?: string) {
    const order = await this.findMine(userId, id);
    const proposal = this.findProposal(order, dto.proposalId);
    const existingShopOrder = await this.orders.findByCustomOrderId(
      String(order._id),
    );
    const awaiting =
      !proposal.status ||
      proposal.status === 'sent' ||
      (proposal.status === 'confirmed' && !existingShopOrder);
    if (!awaiting) {
      if (proposal.status === 'confirmed' && existingShopOrder) {
        return { customOrder: order, order: existingShopOrder };
      }
      throw new BadRequestException('Proposal is not awaiting confirmation');
    }

    const user = await this.userModel.findById(userId);
    const address = await this.addresses.resolve(
      userId,
      dto.addressId,
      dto.address,
    );
    const created =
      existingShopOrder ??
      (await this.orders.createFromProposal({
        userId,
        customOrderId: String(order._id),
        productName: proposal.productName || order.description || 'Custom order',
        image: proposal.images?.[0],
        unitPrice: proposal.price,
        quantity: proposal.quantity || 1,
        address,
        userName: user?.name,
        userPhone: user?.phone,
        channel,
      }));

    proposal.status = 'confirmed';
    proposal.respondedAt = new Date();
    order.status = 'confirmed';
    await order.save();

    try {
      await this.notifications.createAndOptionallyPush({
        userId,
        title: { en: 'Custom order confirmed', ar: 'تم تأكيد الطلب الخاص' },
        body: {
          en: `Order ${created.orderNumber} was created from your quote`,
          ar: `تم إنشاء الطلب ${created.orderNumber} من عرض السعر`,
        },
        type: 'custom_order_confirmed',
        data: { customOrderId: String(order._id), orderId: String(created._id) },
      });
    } catch {
      // Confirmation already persisted; skip a noisy notification failure.
    }

    return { customOrder: order, order: created };
  }

  async reject(userId: string, id: string, dto: RejectProposalDto) {
    const order = await this.findMine(userId, id);
    const proposal = this.findProposal(order, dto.proposalId);
    if (proposal.status !== 'sent') {
      throw new BadRequestException('Proposal is not awaiting confirmation');
    }
    proposal.status = 'rejected';
    proposal.customerResponse = dto.reason;
    proposal.respondedAt = new Date();
    order.status = dto.nextStatus === 'rejected' ? 'rejected' : 'need_more_details';
    await order.save();
    return order;
  }

  async ensureConversation(customOrder: CustomOrderDocument) {
    let convo = await this.conversationModel.findOne({
      customOrderId: customOrder._id,
    });
    if (!convo) {
      convo = await this.conversationModel.create({
        userId: customOrder.userId,
        customOrderId: customOrder._id,
        lastMessageAt: new Date(),
        unreadByCustomer: 0,
        unreadByStaff: 0,
      });
    }
    return convo;
  }

  async resolveConversation(
    user: AuthUser,
    body: { customOrderId?: string; conversationId?: string },
  ) {
    if (body.customOrderId) {
      const order =
        user.type === 'staff'
          ? await this.findAdmin(body.customOrderId)
          : await this.findMine(user.userId, body.customOrderId);
      return this.ensureConversation(order);
    }
    if (body.conversationId) {
      const convo = await this.getChat(body.conversationId);
      if (user.type !== 'staff') {
        const ownerId = this.idOf(convo.userId);
        if (ownerId !== user.userId) {
          throw new ForbiddenException();
        }
      }
      return convo;
    }
    throw new BadRequestException('customOrderId or conversationId required');
  }

  presentMessage(doc: MessageDocument) {
    const json = (
      typeof doc.toJSON === 'function' ? doc.toJSON() : doc
    ) as unknown as Record<string, unknown>;
    return {
      _id: String(json._id ?? ''),
      id: String(json._id ?? ''),
      conversationId: this.idOf(json.conversationId),
      senderId: this.idOf(json.senderId),
      senderRole: String(json.senderRole ?? ''),
      type: String(json.type ?? 'text'),
      text: String(json.text ?? ''),
      attachments: Array.isArray(json.attachments)
        ? (json.attachments as string[])
        : [],
      images: Array.isArray(json.attachments)
        ? (json.attachments as string[])
        : [],
      createdAt: json.createdAt as Date | undefined,
    };
  }

  private idOf(value: unknown): string {
    if (!value) return '';
    if (typeof value === 'string') return value;
    if (typeof value === 'object' && value !== null) {
      const rec = value as { _id?: unknown; id?: unknown };
      if (rec._id) return String(rec._id);
      if (rec.id) return String(rec.id);
    }
    return String(value);
  }

  private emitChat(convo: ConversationDocument, message: MessageDocument) {
    this.realtime.emitMessage({
      conversationId: String(convo._id),
      customOrderId: this.idOf(convo.customOrderId),
      message: this.presentMessage(message),
    });
  }

  async listMessages(user: AuthUser, customOrderId: string) {
    const order =
      user.type === 'staff'
        ? await this.findAdmin(customOrderId)
        : await this.findMine(user.userId, customOrderId);
    const convo = await this.ensureConversation(order);
    const messages = await this.messageModel
      .find({ conversationId: convo._id })
      .sort({ createdAt: 1 });

    if (user.type === 'staff') {
      convo.unreadByStaff = 0;
    } else {
      convo.unreadByCustomer = 0;
    }
    await convo.save();
    await this.messageModel.updateMany(
      { conversationId: convo._id, readAt: { $exists: false } },
      { readAt: new Date() },
    );
    return messages.map((m) => this.presentMessage(m));
  }

  async postMessage(
    user: AuthUser,
    customOrderId: string,
    dto: CreateMessageDto,
    attachmentUrls: string[] = [],
  ) {
    const order =
      user.type === 'staff'
        ? await this.findAdmin(customOrderId)
        : await this.findMine(user.userId, customOrderId);
    const convo = await this.ensureConversation(order);
    const message = await this.messageModel.create({
      conversationId: convo._id,
      senderId: new Types.ObjectId(user.userId),
      senderRole: user.role,
      type: dto.type || (attachmentUrls.length ? 'file' : 'text'),
      text: dto.text,
      attachments: attachmentUrls,
    });
    convo.lastMessageAt = new Date();
    convo.lastMessage = dto.text || (attachmentUrls.length ? '📷' : '');
    if (user.type === 'staff') {
      convo.unreadByCustomer += 1;
      convo.unreadByStaff = 0;
    } else {
      convo.unreadByStaff += 1;
      convo.unreadByCustomer = 0;
    }
    await convo.save();
    this.emitChat(convo, message);
    return message;
  }

  async listAdmin(query: {
    status?: string;
    page?: number;
    limit?: number;
  }) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const filter: Record<string, unknown> = {};
    if (query.status) {
      filter.status = query.status;
    }
    const [items, total] = await Promise.all([
      this.customModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .populate('userId', 'name email phone')
        .populate('categoryId'),
      this.customModel.countDocuments(filter),
    ]);
    return { data: items, meta: paginationMeta(total, page, limit) };
  }

  async findAdmin(id: string) {
    const doc = await this.customModel
      .findById(toObjectId(id))
      .populate('userId', 'name email phone')
      .populate('categoryId');
    if (!doc) {
      throw new NotFoundException('Custom order not found');
    }
    return doc;
  }

  async updateAdmin(id: string, dto: AdminUpdateCustomOrderDto) {
    if (
      dto.status &&
      !CUSTOM_ORDER_STATUSES.includes(
        dto.status as (typeof CUSTOM_ORDER_STATUSES)[number],
      )
    ) {
      throw new BadRequestException('Invalid status');
    }
    const doc = await this.customModel.findByIdAndUpdate(toObjectId(id), dto, {
      new: true,
    });
    if (!doc) {
      throw new NotFoundException('Custom order not found');
    }
    return doc;
  }

  async sendProposal(id: string, dto: CreateProposalDto, actorId: string) {
    const order = await this.findAdmin(id);
    const nextVersion =
      order.proposals.reduce((max, p) => Math.max(max, p.version || 0), 0) + 1;
    order.proposals.forEach((p) => {
      if (p.status === 'sent') {
        p.status = 'replaced';
      }
    });
    order.proposals.push({
      version: nextVersion,
      productName: dto.productName,
      images: dto.images ?? [],
      description: dto.description,
      specifications: dto.specifications,
      price: dto.price,
      quantity: dto.quantity ?? 1,
      estimatedDays: dto.estimatedDays,
      notes: dto.notes,
      status: 'sent',
    } as never);
    order.status = 'waiting_confirmation';
    await order.save();

    const convo = await this.ensureConversation(order);
    const proposalMessage = await this.messageModel.create({
      conversationId: convo._id,
      senderId: new Types.ObjectId(actorId),
      senderRole: 'staff',
      type: 'proposal',
      text: `Proposal v${nextVersion}: ${dto.productName}`,
    });
    convo.lastMessageAt = new Date();
    convo.unreadByCustomer += 1;
    await convo.save();
    this.emitChat(convo, proposalMessage);

    const customerId = String(order.userId._id ?? order.userId);
    await this.notifications.createAndOptionallyPush({
      userId: customerId,
      title: { en: 'New quote', ar: 'عرض سعر جديد' },
      body: {
        en: 'A new proposal is waiting for your confirmation',
        ar: 'يوجد عرض سعر بانتظار تأكيدك',
      },
      type: 'custom_order_proposal',
      data: { customOrderId: String(order._id) },
    });

    await this.audit.log({
      actorId,
      action: 'custom-order.proposal',
      entity: 'CustomOrder',
      entityId: String(order._id),
      newValue: { version: nextVersion, price: dto.price },
    });

    return order;
  }

  async listChats(page: number, limit: number, customOrderId?: string) {
    const filter: Record<string, unknown> = {};
    if (customOrderId) {
      filter.customOrderId = toObjectId(customOrderId);
    }
    const [items, total] = await Promise.all([
      this.conversationModel
        .find(filter)
        .sort({ lastMessageAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .populate('userId', 'name email')
        .populate('customOrderId'),
      this.conversationModel.countDocuments(filter),
    ]);
    return { data: items, meta: paginationMeta(total, page, limit) };
  }

  async getChat(id: string) {
    const convo = await this.conversationModel
      .findById(toObjectId(id))
      .populate('userId', 'name email')
      .populate('customOrderId');
    if (!convo) {
      throw new NotFoundException('Conversation not found');
    }
    return convo;
  }

  async listChatMessages(conversationId: string) {
    const convo = await this.getChat(conversationId);
    const messages = await this.messageModel
      .find({ conversationId: convo._id })
      .sort({ createdAt: 1 });
    convo.unreadByStaff = 0;
    await convo.save();
    return messages.map((m) => this.presentMessage(m));
  }

  async postChatMessage(
    user: AuthUser,
    conversationId: string,
    dto: CreateMessageDto,
    attachmentUrls: string[] = [],
  ) {
    const convo = await this.getChat(conversationId);
    if (user.type !== 'staff') {
      throw new ForbiddenException();
    }
    const message = await this.messageModel.create({
      conversationId: convo._id,
      senderId: new Types.ObjectId(user.userId),
      senderRole: user.role,
      type: dto.type || (attachmentUrls.length ? 'file' : 'text'),
      text: dto.text,
      attachments: attachmentUrls,
    });
    convo.lastMessageAt = new Date();
    convo.lastMessage = dto.text || (attachmentUrls.length ? '📷' : '');
    convo.unreadByCustomer += 1;
    convo.unreadByStaff = 0;
    await convo.save();
    this.emitChat(convo, message);
    return message;
  }
}