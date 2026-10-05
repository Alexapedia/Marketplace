import { Component, inject, OnDestroy, OnInit, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute } from '@angular/router';
import { ApiClient } from '../../core/api/api-client';
import { ChatSocket } from '../../core/api/chat-socket';
import { I18nService } from '../../core/i18n/i18n.service';
import {
  Address,
  asItems,
  Category,
  ChatMessage,
  CustomOrder,
  loc,
  media,
} from '../../core/models/models';
import { PageBar } from '../../shared/page-bar';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { ToastService } from '../../core/toast/toast.service';

@Component({
  selector: 'app-custom-detail-page',
  imports: [FormsModule, PageBar, TranslatePipe],
  templateUrl: './custom-detail-page.html',
})
export class CustomDetailPage implements OnInit, OnDestroy {
  private readonly api = inject(ApiClient);
  private readonly route = inject(ActivatedRoute);
  private readonly chat = inject(ChatSocket);
  readonly i18n = inject(I18nService);
  private readonly toast = inject(ToastService);

  order = signal<CustomOrder | null>(null);
  messages = signal<ChatMessage[]>([]);
  addresses = signal<Address[]>([]);
  text = '';
  chatFiles: File[] = [];
  confirmAddressId = '';
  readonly media = media;

  ngOnInit(): void {
    this.chat.incoming.subscribe((msg) => this.appendMessage(msg));
    this.api.get<Address[]>('/addresses').subscribe({
      next: (res) => {
        const list = asItems<Address>(res.data);
        this.addresses.set(list);
        const def = list.find((a) => a.isDefault) ?? list[0];
        this.confirmAddressId = String(def?._id || def?.id || '');
      },
    });
    this.route.paramMap.subscribe((params) => {
      const id = params.get('id') || '';
      this.load(id);
      this.chat.connect(id);
    });
  }

  ngOnDestroy(): void {
    this.chat.disconnect();
  }

  title(o: CustomOrder): string {
    const cat = o.categoryId;
    if (cat && typeof cat === 'object') {
      const label = loc((cat as Category).names ?? (cat as Category).name, this.i18n.lang());
      if (label) return label;
    }
    return `#${String(o._id || '').slice(-8)}`;
  }

  confirm(proposalId: string): void {
    const id = this.route.snapshot.paramMap.get('id') || '';
    if (!this.confirmAddressId) {
      this.toast.show(this.i18n.t('selectAddress'));
      return;
    }
    this.api
      .post(`/custom-orders/${id}/confirm`, {
        proposalId,
        addressId: this.confirmAddressId,
      })
      .subscribe({
        next: () => {
          this.toast.show(this.i18n.t('confirmQuote'));
          this.load(id);
        },
        error: (e) => this.toast.show(e.message),
      });
  }

  reject(proposalId: string): void {
    const id = this.route.snapshot.paramMap.get('id') || '';
    const reason = prompt(this.i18n.t('reason')) || this.i18n.t('rejectQuote');
    this.api.post(`/custom-orders/${id}/reject`, { proposalId, reason }).subscribe({
      next: () => this.load(id),
      error: (e) => this.toast.show(e.message),
    });
  }

  onChatFiles(ev: Event): void {
    const input = ev.target as HTMLInputElement;
    this.chatFiles = input.files ? Array.from(input.files) : [];
  }

  sendChat(ev: Event): void {
    ev.preventDefault();
    const id = this.route.snapshot.paramMap.get('id') || '';
    const text = this.text.trim();
    if (!text && !this.chatFiles.length) return;
    if (text && this.chat.send(id, text)) {
      this.text = '';
      return;
    }
    const form = new FormData();
    if (text) form.append('text', text);
    for (const f of this.chatFiles) form.append('files', f);
    this.api.postForm(`/custom-orders/${id}/messages`, form).subscribe({
      next: (res) => {
        this.text = '';
        this.chatFiles = [];
        if (res.data) this.appendMessage(res.data as ChatMessage);
      },
      error: (e) => this.toast.show(e.message),
    });
  }

  isMine(m: ChatMessage): boolean {
    return m.senderRole === 'customer' || m.senderRole === 'user';
  }

  private load(id: string): void {
    this.api.get<CustomOrder>(`/custom-orders/${id}`).subscribe({
      next: (res) => this.order.set(res.data),
    });
    this.api.get<ChatMessage[]>(`/custom-orders/${id}/messages`).subscribe({
      next: (res) => this.messages.set(asItems<ChatMessage>(res.data)),
      error: () => this.messages.set([]),
    });
  }

  private appendMessage(message: ChatMessage): void {
    const mid = String(message._id || message.id || '');
    if (mid && this.messages().some((m) => String(m._id || m.id) === mid)) return;
    this.messages.update((list) => [...list, message]);
  }
}
