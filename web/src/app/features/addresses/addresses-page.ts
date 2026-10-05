import { Component, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiClient } from '../../core/api/api-client';
import { Address, asItems } from '../../core/models/models';
import { PageBar } from '../../shared/page-bar';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

@Component({
  selector: 'app-addresses-page',
  imports: [RouterLink, PageBar, TranslatePipe],
  templateUrl: './addresses-page.html',
})
export class AddressesPage implements OnInit {
  private readonly api = inject(ApiClient);
  addresses = signal<Address[]>([]);

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.api.get<Address[]>('/addresses').subscribe({
      next: (res) => this.addresses.set(asItems<Address>(res.data)),
    });
  }

  aid(a: Address): string {
    return String(a._id || a.id || '');
  }

  setDefault(id: string): void {
    this.api.patch(`/addresses/${id}/default`, {}).subscribe({ next: () => this.load() });
  }

  remove(id: string): void {
    this.api.delete(`/addresses/${id}`).subscribe({ next: () => this.load() });
  }
}
