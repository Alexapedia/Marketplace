import { DatePipe } from '@angular/common';
import { Component, inject, OnInit, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatListModule } from '@angular/material/list';
import { ChatsApi } from '../../core/api/chats.api';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { ChatMessage, Conversation, entityId, User } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { asList, errMessage, UiService } from '../../shared/ui.service';

@Component({
  selector: 'app-chat-page',
  imports: [
    DatePipe,
    FormsModule,
    MatListModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
    TranslatePipe,
    AsyncState,
  ],
  templateUrl: './chat-page.html',
  styleUrl: './chat-page.scss',
})
export class ChatPage implements OnInit {
  private readonly api = inject(ChatsApi);
  private readonly route = inject(ActivatedRoute);
  private readonly ui = inject(UiService);

  readonly loading = signal(true);
  readonly error = signal<string | null>(null);
  readonly conversations = signal<Conversation[]>([]);
  readonly messages = signal<ChatMessage[]>([]);
  readonly activeId = signal<string | null>(null);
  readonly draft = signal('');
  readonly sending = signal(false);
  readonly entityId = entityId;

  ngOnInit(): void {
    this.loadList();
  }

  loadList(): void {
    this.loading.set(true);
    this.error.set(null);
    const customOrderId = this.route.snapshot.queryParamMap.get('customOrderId') ?? undefined;
    this.api.list({ customOrderId }).subscribe({
      next: (res) => {
        const list = asList(res.data);
        this.conversations.set(list);
        this.loading.set(false);
        const first = list[0];
        if (first) {
          this.select(first);
        }
      },
      error: (err: unknown) => {
        this.error.set(errMessage(err));
        this.loading.set(false);
      },
    });
  }

  select(conv: Conversation): void {
    const id = entityId(conv);
    this.activeId.set(id);
    this.api.messages(id).subscribe({
      next: (res) => this.messages.set(asList(res.data)),
      error: (err: unknown) => this.ui.error(errMessage(err)),
    });
  }

  label(conv: Conversation): string {
    const u = conv.userId;
    if (u && typeof u === 'object') {
      return (u as User).name || (u as User).email;
    }
    return conv.customOrderId || conv.orderId || entityId(conv).slice(-6);
  }

  send(): void {
    const id = this.activeId();
    const text = this.draft().trim();
    if (!id || !text || this.sending()) {
      return;
    }
    this.sending.set(true);
    this.api.send(id, { text, type: 'text' }).subscribe({
      next: (res) => {
        this.messages.update((m) => [...m, res.data]);
        this.draft.set('');
        this.sending.set(false);
      },
      error: (err: unknown) => {
        this.sending.set(false);
        this.ui.error(errMessage(err));
      },
    });
  }
}
