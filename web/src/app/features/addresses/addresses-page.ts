import { Component, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiClient } from '../../core/api/api-client';
import { DialogService } from '../../core/dialog/dialog.service';
import { Address, asItems } from '../../core/models/models';
import { ToastService } from '../../core/toast/toast.service';
import { AsyncState } from '../../shared/async-state';
import { PageBar } from '../../shared/page-bar';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

import { Icon } from '../../shared/icon';
import { MAISON } from '../../shared/maison';

@Component({
  selector: 'app-addresses-page',
  imports: [RouterLink, PageBar, TranslatePipe, AsyncState, Icon, MAISON],
  templateUrl: './addresses-page.html',
})
export class AddressesPage implements OnInit {
  private readonly api = inject(ApiClient);
  private readonly dialog = inject(DialogService);
  private readonly toast = inject(ToastService);
  addresses = signal<Address[]>([]);
  loading = signal(true);
  error = signal<string | null>(null);

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.error.set(null);
    this.api.get<Address[]>('/addresses').subscribe({
      next: (res) => {
        this.addresses.set(asItems<Address>(res.data));
        this.loading.set(false);
      },
      error: (e: Error) => {
        this.error.set(e.message);
        this.loading.set(false);
      },
    });
  }

  aid(a: Address): string {
    return String(a._id || a.id || '');
  }

  setDefault(id: string): void {
    this.api.patch(`/addresses/${id}/default`, {}).subscribe({
      next: () => this.load(),
      error: (e: Error) => this.toast.show(e.message),
    });
  }

  async remove(id: string): Promise<void> {
    const ok = await this.dialog.confirm({
      title: 'deleteAddress',
      message: 'deleteAddressConfirm',
      confirmKey: 'delete',
      danger: true,
    });
    if (!ok) return;
    this.api.delete(`/addresses/${id}`).subscribe({
      next: () => this.load(),
      error: (e: Error) => this.toast.show(e.message),
    });
  }
}
