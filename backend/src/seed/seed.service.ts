import { Injectable, Logger, OnApplicationBootstrap } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectConnection, InjectModel } from '@nestjs/mongoose';
import * as bcrypt from 'bcrypt';
import { Connection, Model } from 'mongoose';
import { ALL_PERMISSIONS } from '../common/constants';
import { Ad, AdDocument } from '../schemas/ad.schema';
import { AppConfig, AppConfigDocument } from '../schemas/app-config.schema';
import { Category, CategoryDocument } from '../schemas/category.schema';
import { CustomField, CustomFieldDocument } from '../schemas/custom-field.schema';
import { Product, ProductDocument } from '../schemas/product.schema';
import { Review, ReviewDocument } from '../schemas/review.schema';
import { Role, RoleDocument } from '../schemas/role.schema';
import { User, UserDocument } from '../schemas/user.schema';
import {
  PlatformUser,
  PlatformUserDocument,
} from '../schemas/platform-user.schema';
import { TenantContext } from '../tenant/tenant.context';
import { TenantService } from '../tenant/tenant.service';

@Injectable()
export class SeedService implements OnApplicationBootstrap {
  private readonly logger = new Logger(SeedService.name);

  constructor(
    @InjectConnection() private readonly connection: Connection,
    @InjectModel(Role.name) private readonly roleModel: Model<RoleDocument>,
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
    @InjectModel(Category.name)
    private readonly categoryModel: Model<CategoryDocument>,
    @InjectModel(CustomField.name)
    private readonly fieldModel: Model<CustomFieldDocument>,
    @InjectModel(Product.name)
    private readonly productModel: Model<ProductDocument>,
    @InjectModel(AppConfig.name)
    private readonly configModel: Model<AppConfigDocument>,
    @InjectModel(Ad.name)
    private readonly adModel: Model<AdDocument>,
    @InjectModel(Review.name)
    private readonly reviewModel: Model<ReviewDocument>,
    @InjectModel(PlatformUser.name)
    private readonly platformUsers: Model<PlatformUserDocument>,
    private readonly config: ConfigService,
    private readonly tenants: TenantService,
  ) {}

  async onApplicationBootstrap() {
    await this.connection.asPromise();
    const tenant = await this.tenants.ensureDefault();
    const tenantId = String(tenant._id);
    await TenantContext.run({ kind: 'platform' }, async () => {
      await this.dropLegacyIndexes();
      await this.backfillTenantId(tenantId);
      await this.userModel.syncIndexes();
      await this.seedPlatformOwner();
    });
    await TenantContext.run({ kind: 'tenant', tenantId, slug: tenant.slug }, async () => {
      await this.ensureReviewPermissions();
      await this.ensureAdsPermissions();
      const empty = (await this.roleModel.countDocuments()) === 0;
      const force = this.config.get<string>('SEED') === 'true';
      if (!empty && !force) {
        await this.seedAdsIfEmpty();
        return;
      }
      this.logger.log('Seeding database...');
      await this.seedRoles();
      await this.seedAdmin();
      const cats = await this.seedCategories();
      await this.seedCustomFields(cats);
      await this.seedProducts(cats);
      await this.seedAppConfig();
      await this.seedAdsIfEmpty();
      await this.seedReviews();
      this.logger.log('Seed complete');
    });
  }

  private async backfillTenantId(tenantId: string) {
    const skip = new Set(['tenants', 'platformusers', 'platformaudits', 'platformevents']);
    const collections = await this.connection.db!.listCollections().toArray();
    for (const col of collections) {
      if (skip.has(col.name) || col.name.startsWith('system.')) continue;
      await this.connection.db!.collection(col.name).updateMany(
        { tenantId: { $exists: false } },
        { $set: { tenantId } },
      );
    }
  }

  private async dropLegacyIndexes() {
    const drops: Array<[string, string]> = [
      ['users', 'email_1'],
      ['users', 'firebaseUid_1'],
      ['roles', 'name_1'],
      ['appconfigs', 'key_1'],
      ['carts', 'userId_1'],
      ['orders', 'orderNumber_1'],
      ['favorites', 'userId_1_productId_1'],
      ['reviews', 'userId_1_scope_1'],
      ['users', 'tenantId_1_firebaseUid_1'],
    ];
    for (const [col, index] of drops) {
      try {
        await this.connection.collection(col).dropIndex(index);
      } catch {
        /* already gone */
      }
    }
  }

  private async seedPlatformOwner() {
    const email = (
      this.config.get<string>('SEED_HOLDER_EMAIL') || 'holder@placemarket.com'
    ).toLowerCase();
    const password =
      this.config.get<string>('SEED_HOLDER_PASSWORD') || 'Holder@123456';
    const existing = await this.platformUsers.findOne({ email });
    if (existing) return;
    await this.platformUsers.create({
      name: 'Project Holder',
      email,
      passwordHash: await bcrypt.hash(password, 10),
      role: 'platform_owner',
      status: 'active',
      totpEnabled: false,
    });
    this.logger.log(`Seeded holder ${email}`);
  }

  private async ensureReviewPermissions() {
    const add = async (name: string, perms: string[]) => {
      await this.roleModel.updateOne(
        { name },
        { $addToSet: { permissions: { $each: perms } } },
      );
    };
    await add('admin', ['reviews.read', 'reviews.write']);
    await add('support_agent', ['reviews.read', 'reviews.write']);
    await add('order_manager', ['reviews.read']);
    await add('product_manager', ['reviews.read']);
    await add('marketing_manager', ['reviews.read', 'reviews.write']);
    await add('super_admin', ['reviews.read', 'reviews.write']);
  }

  private async ensureAdsPermissions() {
    const add = async (name: string, perms: string[]) => {
      await this.roleModel.updateOne(
        { name },
        { $addToSet: { permissions: { $each: perms } } },
      );
    };
    const perms = ['ads.read', 'ads.write'];
    await add('admin', perms);
    await add('marketing_manager', perms);
    await add('super_admin', perms);
  }

  private async seedRoles() {
    const defs: { name: string; permissions: string[] }[] = [
      { name: 'super_admin', permissions: [...ALL_PERMISSIONS] },
      {
        name: 'admin',
        permissions: ALL_PERMISSIONS.filter((p) => p !== 'roles.write'),
      },
      {
        name: 'support_agent',
        permissions: [
          'dashboard.read',
          'chats.read',
          'chats.write',
          'custom-orders.read',
          'custom-orders.write',
          'customers.read',
          'reviews.read',
          'reviews.write',
        ],
      },
      {
        name: 'order_manager',
        permissions: [
          'dashboard.read',
          'orders.read',
          'orders.write',
          'customers.read',
          'reports.read',
          'reviews.read',
        ],
      },
      {
        name: 'product_manager',
        permissions: [
          'dashboard.read',
          'products.read',
          'products.write',
          'categories.read',
          'categories.write',
          'custom-fields.read',
          'custom-fields.write',
          'reviews.read',
        ],
      },
      {
        name: 'marketing_manager',
        permissions: [
          'dashboard.read',
          'notifications.write',
          'app-config.read',
          'app-config.write',
          'ads.read',
          'ads.write',
          'reviews.read',
          'reviews.write',
        ],
      },
      { name: 'customer', permissions: [] },
    ];
    for (const role of defs) {
      await this.roleModel.updateOne(
        { name: role.name },
        { $set: { ...role, isSystem: true } },
        { upsert: true },
      );
    }
  }

  private async seedAdmin() {
    const email = (
      this.config.get<string>('SEED_ADMIN_EMAIL') || 'admin@placemarket.com'
    ).toLowerCase();
    const password =
      this.config.get<string>('SEED_ADMIN_PASSWORD') || 'Admin@123456';
    const existing = await this.userModel.findOne({ email });
    if (existing) {
      return;
    }
    await this.userModel.create({
      name: 'PlaceMarket Admin',
      email,
      passwordHash: await bcrypt.hash(password, 10),
      role: 'super_admin',
      status: 'active',
      language: 'en',
      theme: 'system',
    });
  }

  private async seedCategories() {
    const defs = [
      {
        key: 'perfumes',
        names: { en: 'Perfumes', ar: 'عطور' },
        type: 'standard',
        sortOrder: 1,
      },
      {
        key: 'watches',
        names: { en: 'Watches', ar: 'ساعات' },
        type: 'both',
        sortOrder: 2,
      },
      {
        key: 'accessories',
        names: { en: 'Accessories', ar: 'إكسسوارات' },
        type: 'both',
        sortOrder: 3,
      },
      {
        key: 'clothing',
        names: { en: 'Clothing', ar: 'ملابس' },
        type: 'both',
        sortOrder: 4,
      },
    ];
    const result: Record<string, CategoryDocument> = {};
    for (const def of defs) {
      let doc = await this.categoryModel.findOne({ 'names.en': def.names.en });
      if (!doc) {
        doc = await this.categoryModel.create({
          names: def.names,
          type: def.type,
          status: 'published',
          sortOrder: def.sortOrder,
          image: `https://picsum.photos/seed/pm-${def.key}/800/600`,
        });
      }
      result[def.key] = doc;
    }
    return result;
  }

  private async seedCustomFields(cats: Record<string, CategoryDocument>) {
    if ((await this.fieldModel.countDocuments()) > 0) {
      return;
    }
    const watch = [
      {
        labels: { en: 'Gender', ar: 'الجنس' },
        fieldType: 'dropdown',
        options: ['Men', 'Women', 'Unisex'],
      },
      {
        labels: { en: 'Style', ar: 'الأسلوب' },
        fieldType: 'dropdown',
        options: ['Classic', 'Sport', 'Luxury', 'Minimal'],
      },
      {
        labels: { en: 'Material', ar: 'الخامة' },
        fieldType: 'dropdown',
        options: ['Steel', 'Gold', 'Leather', 'Titanium'],
      },
      {
        labels: { en: 'Color', ar: 'اللون' },
        fieldType: 'color',
        options: ['Black', 'Silver', 'Gold', 'Blue'],
      },
      {
        labels: { en: 'Size', ar: 'المقاس' },
        fieldType: 'size',
        options: ['38mm', '40mm', '42mm', '44mm'],
      },
    ];
    const accessories = [
      {
        labels: { en: 'Type', ar: 'النوع' },
        fieldType: 'dropdown',
        options: ['Necklace', 'Bracelet', 'Earrings', 'Ring'],
      },
      {
        labels: { en: 'Material', ar: 'الخامة' },
        fieldType: 'dropdown',
        options: ['Gold', 'Silver', 'Platinum', 'Beads'],
      },
      {
        labels: { en: 'Color', ar: 'اللون' },
        fieldType: 'color',
        options: ['Gold', 'Silver', 'Rose Gold', 'Mixed'],
      },
      {
        labels: { en: 'Stones', ar: 'الأحجار' },
        fieldType: 'multi_select',
        options: ['Diamond', 'Pearl', 'Emerald', 'None'],
      },
    ];
    const clothing = [
      {
        labels: { en: 'Gender', ar: 'الجنس' },
        fieldType: 'dropdown',
        options: ['Men', 'Women', 'Unisex'],
      },
      {
        labels: { en: 'Size', ar: 'المقاس' },
        fieldType: 'size',
        options: ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
      },
    ];
    const groups: [string, typeof watch][] = [
      ['watches', watch],
      ['accessories', accessories],
      ['clothing', clothing],
    ];
    for (const [key, fields] of groups) {
      for (let i = 0; i < fields.length; i++) {
        await this.fieldModel.create({
          categoryId: cats[key]._id,
          ...fields[i],
          required: i === 0,
          sortOrder: i + 1,
          status: 'published',
        });
      }
    }
  }

  private async seedProducts(cats: Record<string, CategoryDocument>) {
    if ((await this.productModel.countDocuments()) > 0) {
      return;
    }
    const img = (seed: string) => `https://picsum.photos/seed/${seed}/800/800`;
    const products = [
      {
        categoryId: cats.perfumes._id,
        names: { en: 'Oud Royale', ar: 'عود ملكي' },
        descriptions: {
          en: 'A rich oud fragrance with amber and musk.',
          ar: 'عطر عود غني بالمسك والعنبر.',
        },
        price: 420,
        salePrice: 380,
        stock: 24,
        flags: { featured: true, newArrival: false, bestSeller: true },
        images: [img('pm-oud')],
      },
      {
        categoryId: cats.perfumes._id,
        names: { en: 'Rose Mist', ar: 'رذاذ الورد' },
        descriptions: {
          en: 'Soft rose petals with a fresh citrus opening.',
          ar: 'بتلات ورد ناعمة مع لمسة حمضية.',
        },
        price: 260,
        stock: 40,
        flags: { featured: false, newArrival: true, bestSeller: false },
        images: [img('pm-rose')],
      },
      {
        categoryId: cats.perfumes._id,
        names: { en: 'Cedar Night', ar: 'ليل الأرز' },
        descriptions: {
          en: 'Woody cedar with vanilla warmth.',
          ar: 'خشب الأرز مع دفء الفانيليا.',
        },
        price: 310,
        stock: 18,
        flags: { featured: true, newArrival: false, bestSeller: false },
        images: [img('pm-cedar')],
      },
      {
        categoryId: cats.watches._id,
        names: { en: 'Classic Chronograph', ar: 'كرونوغراف كلاسيكي' },
        descriptions: {
          en: 'Steel chronograph with a sapphire crystal.',
          ar: 'ساعة كرونوغراف فولاذية بزجاج ياقوتي.',
        },
        price: 1450,
        stock: 8,
        gender: 'Men',
        sizes: ['40mm', '42mm'],
        flags: { featured: true, newArrival: true, bestSeller: true },
        images: [img('pm-chrono')],
      },
      {
        categoryId: cats.watches._id,
        names: { en: 'Minimal Steel', ar: 'ستيل مينيمال' },
        descriptions: {
          en: 'Slim unisex watch with a mesh bracelet.',
          ar: 'ساعة نحيفة للجنسين بسوار شبكي.',
        },
        price: 890,
        salePrice: 790,
        stock: 15,
        gender: 'Unisex',
        sizes: ['38mm', '40mm'],
        flags: { featured: false, newArrival: true, bestSeller: false },
        images: [img('pm-steel')],
      },
      {
        categoryId: cats.accessories._id,
        names: { en: 'Gold Chain', ar: 'سلسلة ذهبية' },
        descriptions: {
          en: '18k gold-plated chain, everyday luxury.',
          ar: 'سلسلة مطلية ذهب 18 قيراط لإطلالة يومية.',
        },
        price: 540,
        stock: 30,
        flags: { featured: true, newArrival: false, bestSeller: true },
        images: [img('pm-chain')],
      },
      {
        categoryId: cats.accessories._id,
        names: { en: 'Pearl Earrings', ar: 'أقراط لؤلؤ' },
        descriptions: {
          en: 'Freshwater pearls with gold posts.',
          ar: 'لؤلؤ مياه عذبة مع قاعدة ذهبية.',
        },
        price: 320,
        stock: 22,
        flags: { featured: false, newArrival: true, bestSeller: false },
        images: [img('pm-pearl')],
      },
      {
        categoryId: cats.clothing._id,
        names: { en: 'Linen Shirt', ar: 'قميص كتان' },
        descriptions: {
          en: 'Breathable linen shirt for warm days.',
          ar: 'قميص كتان مريح لأيام الصيف.',
        },
        price: 180,
        stock: 50,
        gender: 'Men',
        sizes: ['S', 'M', 'L', 'XL'],
        flags: { featured: false, newArrival: true, bestSeller: false },
        images: [img('pm-linen')],
      },
      {
        categoryId: cats.clothing._id,
        names: { en: 'Tailored Trousers', ar: 'بنطال مفصل' },
        descriptions: {
          en: 'Tailored trousers with a clean drape.',
          ar: 'بنطال مفصل بقصة أنيقة.',
        },
        price: 240,
        stock: 28,
        gender: 'Women',
        sizes: ['XS', 'S', 'M', 'L'],
        flags: { featured: true, newArrival: false, bestSeller: true },
        images: [img('pm-trousers')],
      },
      {
        categoryId: cats.accessories._id,
        names: { en: 'Silk Scarf', ar: 'وشاح حريري' },
        descriptions: {
          en: 'Hand-rolled silk scarf with a desert motif.',
          ar: 'وشاح حرير يدوي بنقشة صحراوية.',
        },
        price: 210,
        stock: 16,
        flags: { featured: false, newArrival: true, bestSeller: false },
        images: [img('pm-scarf')],
      },
    ];
    await this.productModel.insertMany(
      products.map((p, i) => ({
        ...p,
        status: 'published',
        sortOrder: i + 1,
        descriptions: p.descriptions,
        flags: p.flags,
      })),
    );
  }

  private async seedAppConfig() {
    await this.configModel.updateOne(
      { key: 'global' },
      {
        $set: {
          key: 'global',
          banners: [
            {
              image: 'https://picsum.photos/seed/pm-banner1/1200/500',
              title: { en: 'Ramadan Edit', ar: 'إصدار رمضان' },
              subtitle: {
                en: 'Seasonal picks on the home feed',
                ar: 'اختيارات الموسم على الصفحة الرئيسية',
              },
              link: '/products?featured=true',
              sortOrder: 1,
              active: true,
              placement: 'home',
            },
            {
              image: 'https://picsum.photos/seed/pm-banner2/1200/500',
              title: { en: 'New Arrivals', ar: 'وصل حديثاً' },
              subtitle: {
                en: 'Fresh drops between products',
                ar: 'وصل حديثاً بين المنتجات',
              },
              link: '/products?newArrival=true',
              sortOrder: 2,
              active: true,
              placement: 'products',
            },
            {
              image: 'https://picsum.photos/seed/pm-banner3/1200/500',
              title: { en: 'Custom luxury', ar: 'فخامة حسب الطلب' },
              subtitle: {
                en: 'Shown on home and in product lists',
                ar: 'يظهر في الرئيسية وقائمة المنتجات',
              },
              link: '/products?featured=true',
              sortOrder: 3,
              active: true,
              placement: 'both',
            },
          ],
          onboarding: [
            {
              image: 'https://picsum.photos/seed/pm-on1/800/1200',
              title: { en: 'Shop curated luxury', ar: 'تسوق الفخامة المختارة' },
              body: {
                en: 'Perfumes, watches, and fashion in one place.',
                ar: 'عطور وساعات وأزياء في مكان واحد.',
              },
            },
            {
              image: 'https://picsum.photos/seed/pm-on2/800/1200',
              title: { en: 'Custom made for you', ar: 'تصميم حسب طلبك' },
              body: {
                en: 'Request a custom piece and chat with our team.',
                ar: 'اطلب قطعة خاصة وتحدث مع فريقنا.',
              },
            },
            {
              image: 'https://picsum.photos/seed/pm-on3/800/1200',
              title: { en: 'Fast local delivery', ar: 'توصيل محلي سريع' },
              body: {
                en: 'Cash on delivery and real-time order updates.',
                ar: 'الدفع عند الاستلام وتحديثات مباشرة للطلب.',
              },
            },
          ],
          version: {
            android: {
              latest: '1.0.0',
              minimum: '1.0.0',
              forceUpdate: false,
              storeUrl: 'https://play.google.com/store',
              message: {
                en: 'Please update PlaceMarket',
                ar: 'يرجى تحديث بلايس ماركت',
              },
            },
            ios: {
              latest: '1.0.0',
              minimum: '1.0.0',
              forceUpdate: false,
              storeUrl: 'https://apps.apple.com',
              message: {
                en: 'Please update PlaceMarket',
                ar: 'يرجى تحديث بلايس ماركت',
              },
            },
          },
          settings: {
            deliveryFee: 15,
            currency: 'SAR',
            supportPhone: '+966500000000',
            supportEmail: 'support@zezostore.com',
          },
        },
      },
      { upsert: true },
    );
  }

  private async seedAdsIfEmpty() {
    if ((await this.adModel.countDocuments()) > 0) return;
    await this.adModel.insertMany([
      {
        image: 'https://picsum.photos/seed/pm-banner1/1200/500',
        title: { en: 'Ramadan Edit', ar: 'إصدار رمضان' },
        subtitle: {
          en: 'Seasonal picks on the home feed',
          ar: 'اختيارات الموسم على الصفحة الرئيسية',
        },
        link: '/products?featured=true',
        sortOrder: 1,
        active: true,
        placement: 'home',
      },
      {
        image: 'https://picsum.photos/seed/pm-banner2/1200/500',
        title: { en: 'New Arrivals', ar: 'وصل حديثاً' },
        subtitle: {
          en: 'Fresh drops between products',
          ar: 'وصل حديثاً بين المنتجات',
        },
        link: '/products?newArrival=true',
        sortOrder: 2,
        active: true,
        placement: 'products',
      },
      {
        image: 'https://picsum.photos/seed/pm-banner3/1200/500',
        title: { en: 'Custom luxury', ar: 'فخامة حسب الطلب' },
        subtitle: {
          en: 'Shown on home and in product lists',
          ar: 'يظهر في الرئيسية وقائمة المنتجات',
        },
        link: '/products?featured=true',
        sortOrder: 3,
        active: true,
        placement: 'both',
      },
    ]);
  }

  private async seedReviews() {
    if ((await this.reviewModel.countDocuments()) > 0) {
      return;
    }
    const passwordHash = await bcrypt.hash('Customer@123', 10);
    const people: {
      name: string;
      email: string;
      rating: number;
      targetType: 'app' | 'website';
      comment: string;
    }[] = [
      {
        name: 'Lina Hassan',
        email: 'lina@example.com',
        rating: 5,
        targetType: 'app',
        comment:
          'Fast delivery and the perfume was exactly as pictured. Cash on delivery made it easy.',
      },
      {
        name: 'Omar Farid',
        email: 'omar@example.com',
        rating: 4.5,
        targetType: 'website',
        comment:
          'Clean shop and the watch I ordered looks premium. Would buy again.',
      },
      {
        name: 'Sara Nabil',
        email: 'sara@example.com',
        rating: 5,
        targetType: 'app',
        comment:
          'Loved being able to request a custom piece. Support replied quickly.',
      },
      {
        name: 'Karim Adel',
        email: 'karim@example.com',
        rating: 4,
        targetType: 'website',
        comment: 'Good prices and the packaging felt careful. Recommended.',
      },
    ];
    for (const person of people) {
      let user = await this.userModel.findOne({ email: person.email });
      if (!user) {
        user = await this.userModel.create({
          name: person.name,
          email: person.email,
          passwordHash,
          role: 'customer',
          status: 'active',
          language: 'en',
          theme: 'system',
        });
      }
      await this.reviewModel.create({
        userId: user._id,
        targetType: person.targetType,
        scope: person.targetType,
        rating: person.rating,
        comment: person.comment,
        targetName: { en: 'Zezo Store', ar: 'متجر زيزو' },
        hidden: false,
      });
    }
  }
}
