import { DatePipe } from '@angular/common';
import {
  afterNextRender,
  Component,
  computed,
  ElementRef,
  inject,
  Injector,
  OnDestroy,
  OnInit,
  signal,
  viewChild,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { Subscription } from 'rxjs';
import { ChatSocket } from '../../core/api/chat-socket';
import { ChatsApi } from '../../core/api/chats.api';
import { AuthService } from '../../core/auth/auth.service';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { ChatMessage, Conversation, entityId, PageMeta, User } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { asList, errMessage, UiService } from '../../shared/ui.service';

@Component({
  selector: 'app-chat-page',
  imports: [DatePipe, FormsModule, MatButtonModule, MatIconModule, TranslatePipe, AsyncState],
  templateUrl: './chat-page.html',
  styleUrl: './chat-page.scss',
})
export class ChatPage implements OnInit, OnDestroy {
  private readonly api = inject(ChatsApi);
  readonly socket = inject(ChatSocket);
  private readonly route = inject(ActivatedRoute);
  private readonly ui = inject(UiService);
  private readonly i18n = inject(I18nService);
  private readonly injector = inject(Injector);
  private readonly auth = inject(AuthService);
  private readonly subs: Subscription[] = [];
  private readonly scroller = viewChild<ElementRef<HTMLElement>>('scroller');

  readonly loading = signal(true);
  readonly loadingMore = signal(false);
  readonly listMeta = signal<PageMeta | null>(null);
  readonly error = signal<string | null>(null);
  readonly conversations = signal<Conversation[]>([]);
  readonly messages = signal<ChatMessage[]>([]);
  readonly activeId = signal<string | null>(null);
  readonly draft = signal('');
  readonly sending = signal(false);
  /** Messages that arrived while the reader was scrolled up. */
  readonly newCount = signal(0);
  /** Whether the thread is scrolled to (near) the latest message. */
  private atBottom = true;
  readonly query = signal('');
  readonly entityId = entityId;

  readonly filtered = computed(() => {
    const q = this.query().trim().toLowerCase();
    return this.conversations().filter((c) => {
      if (!q) return true;
      return `${this.label(c)} ${c.lastMessage ?? ''}`.toLowerCase().includes(q);
    });
  });

  readonly active = computed(
    () => this.conversations().find((c) => entityId(c) === this.activeId()) ?? null,
  );

  constructor() {
    afterNextRender(() => this.scrollToEnd());
  }

  ngOnInit(): void {
    this.socket.connect();
    this.subs.push(
      this.socket.incoming.subscribe((msg) => this.appendIncoming(msg)),
      this.socket.conversationUpdated.subscribe((payload) => this.patchConversation(payload)),
    );
    this.loadList();
  }

  ngOnDestroy(): void {
    for (const sub of this.subs) sub.unsubscribe();
    this.socket.disconnect();
  }

  loadList(): void {
    this.loading.set(true);
    this.error.set(null);
    const customOrderId = this.route.snapshot.queryParamMap.get('customOrderId') ?? undefined;
    this.api.list({ customOrderId, page: 1, limit: 30 }).subscribe({
      next: (res) => {
        const list = asList(res.data);
        this.conversations.set(list);
        this.listMeta.set(res.meta ?? null);
        this.loading.set(false);
        const keep = this.activeId();
        const next =
          list.find((c) => entityId(c) === keep) ??
          (customOrderId ? list.find((c) => entityId(c.customOrderId) === customOrderId) : list[0]);
        if (next) this.select(next);
      },
      error: (err: unknown) => {
        this.error.set(errMessage(err));
        this.loading.set(false);
      },
    });
  }

  hasMoreConversations(): boolean {
    const m = this.listMeta();
    return !!m && m.page < m.totalPages;
  }

  moreConversations(): void {
    const m = this.listMeta();
    if (!m || this.loadingMore()) return;
    this.loadingMore.set(true);
    const customOrderId = this.route.snapshot.queryParamMap.get('customOrderId') ?? undefined;
    this.api.list({ customOrderId, page: m.page + 1, limit: m.limit }).subscribe({
      next: (res) => {
        const seen = new Set(this.conversations().map((c) => entityId(c)));
        const extra = asList(res.data).filter((c) => !seen.has(entityId(c)));
        this.conversations.update((list) => [...list, ...extra]);
        this.listMeta.set(res.meta ?? null);
        this.loadingMore.set(false);
      },
      error: (err: unknown) => {
        this.loadingMore.set(false);
        this.ui.error(errMessage(err));
      },
    });
  }

  select(conv: Conversation): void {
    const id = entityId(conv);
    this.activeId.set(id);
    this.socket.join(id);
    this.conversations.update((list) =>
      list.map((c) => (entityId(c) === id ? { ...c, unreadByStaff: 0 } : c)),
    );
    this.newCount.set(0);
    this.atBottom = true;
    this.api.messages(id).subscribe({
      next: (res) => {
        this.messages.set(asList(res.data));
        this.scrollToEnd();
      },
      error: (err: unknown) => this.ui.error(errMessage(err)),
    });
  }

  closeThread(): void {
    this.activeId.set(null);
  }

  label(conv: Conversation | null): string {
    if (!conv) return '';
    const u = conv.userId;
    if (u && typeof u === 'object') {
      return (u as User).name || (u as User).email || this.i18n.t('chat.customer');
    }
    return this.i18n.t('chat.customer');
  }

  email(conv: Conversation | null): string {
    const u = conv?.userId;
    if (u && typeof u === 'object') return (u as User).email || '';
    return '';
  }

  initials(conv: Conversation): string {
    const name = this.label(conv).trim();
    const parts = name.split(/\s+/).filter(Boolean);
    return ((parts[0]?.[0] ?? 'C') + (parts[1]?.[0] ?? '')).toUpperCase();
  }

  preview(conv: Conversation): string {
    return conv.lastMessage?.trim() || '';
  }

  async send(): Promise<void> {
    const id = this.activeId();
    const text = this.draft().trim();
    if (!id || !text || this.sending()) return;
    this.sending.set(true);
    const ok = await this.socket.send(id, text);
    if (ok) {
      this.draft.set('');
      this.sending.set(false);
      return;
    }
    this.api.send(id, { text, type: 'text' }).subscribe({
      next: (res) => {
        this.appendIncoming(res.data);
        this.draft.set('');
        this.sending.set(false);
      },
      error: (err: unknown) => {
        this.sending.set(false);
        this.ui.error(errMessage(err));
      },
    });
  }

  onEnter(event: Event): void {
    const e = event as KeyboardEvent;
    if (e.shiftKey) return;
    e.preventDefault();
    void this.send();
  }

  onFile(event: Event): void {
    const id = this.activeId();
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    input.value = '';
    if (!id || !file) return;
    const body = new FormData();
    const text = this.draft().trim();
    if (text) body.append('text', text);
    body.append('files', file);
    this.sending.set(true);
    this.api.send(id, body).subscribe({
      next: (res) => {
        this.appendIncoming(res.data);
        this.draft.set('');
        this.sending.set(false);
      },
      error: (err: unknown) => {
        this.sending.set(false);
        this.ui.error(errMessage(err));
      },
    });
  }

  isStaff(msg: ChatMessage): boolean {
    return msg.senderRole !== 'customer';
  }

  private appendIncoming(msg: ChatMessage): void {
    if (!msg) return;
    const id = entityId(msg);
    const convoId = entityId(msg.conversationId);
    if (convoId) {
      this.patchConversation({
        conversationId: convoId,
        lastMessage: msg.text,
        lastMessageAt: msg.createdAt,
      });
      if (convoId !== this.activeId()) {
        this.conversations.update((list) =>
          list.map((c) =>
            entityId(c) === convoId ? { ...c, unreadByStaff: (c.unreadByStaff ?? 0) + 1 } : c,
          ),
        );
        return;
      }
    }
    if (id && this.messages().some((m) => entityId(m) === id)) return;
    this.messages.update((list) => [...list, msg]);
    // Follow the thread when reading the latest messages or sending one;
    // otherwise do not pull the reader away from older messages.
    const mine = !!msg.senderId && msg.senderId === entityId(this.auth.user());
    if (mine || this.atBottom) {
      this.scrollToEnd();
    } else {
      this.newCount.update((n) => n + 1);
    }
  }

  onScroll(): void {
    const el = this.scroller()?.nativeElement;
    if (!el) return;
    this.atBottom = el.scrollHeight - el.scrollTop - el.clientHeight < 80;
    if (this.atBottom) this.newCount.set(0);
  }

  /** Images grow the thread after it was scrolled; stay at the bottom. */
  onMediaLoad(): void {
    if (this.atBottom) this.scrollToEnd();
  }

  jumpToLatest(): void {
    this.newCount.set(0);
    this.scrollToEnd();
  }

  private patchConversation(payload: {
    conversationId?: string;
    lastMessage?: string;
    lastMessageAt?: string;
  }): void {
    const id = payload.conversationId || '';
    if (!id) return;
    if (!this.conversations().some((c) => entityId(c) === id)) {
      this.loadList();
      return;
    }
    this.conversations.update((list) => {
      const next = list.map((c) =>
        entityId(c) === id
          ? {
              ...c,
              lastMessage: payload.lastMessage ?? c.lastMessage,
              lastMessageAt: payload.lastMessageAt ?? c.lastMessageAt,
            }
          : c,
      );
      next.sort(
        (a, b) =>
          new Date(b.lastMessageAt || 0).getTime() - new Date(a.lastMessageAt || 0).getTime(),
      );
      return next;
    });
  }

  /** After Angular has rendered the new messages, so their height counts. */
  private scrollToEnd(): void {
    afterNextRender(
      () => {
        const el = this.scroller()?.nativeElement;
        if (!el) return;
        el.scrollTop = el.scrollHeight;
        this.atBottom = true;
      },
      { injector: this.injector },
    );
  }
}
