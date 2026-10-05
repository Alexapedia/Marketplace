import { Component, inject, OnInit, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { ApiClient } from '../../core/api/api-client';
import { AuthService } from '../../core/auth/auth.service';
import { Address, asItems } from '../../core/models/models';
import { I18nService } from '../../core/i18n/i18n.service';
import { MapPicker } from '../../shared/map-picker';
import { PageBar } from '../../shared/page-bar';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { ToastService } from '../../core/toast/toast.service';

@Component({
  selector: 'app-address-form-page',
  imports: [FormsModule, MapPicker, PageBar, TranslatePipe],
  templateUrl: './address-form-page.html',
})
export class AddressFormPage implements OnInit {
  private readonly api = inject(ApiClient);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  readonly auth = inject(AuthService);
  private readonly toast = inject(ToastService);
  private readonly i18n = inject(I18nService);

  id = '';
  label = 'Home';
  fullName = '';
  phone = '';
  city = '';
  street = '';
  notes = '';
  lat = 30.0444;
  lng = 31.2357;
  isDefault = false;
  error = signal('');

  ngOnInit(): void {
    this.fullName = this.auth.user()?.name || '';
    this.phone = this.auth.user()?.phone || '';
    this.id = this.route.snapshot.paramMap.get('id') || '';
    if (this.id) {
      this.api.get<Address[]>('/addresses').subscribe({
        next: (res) => {
          const current = asItems<Address>(res.data).find((a) => String(a._id || a.id) === this.id);
          if (!current) return;
          this.label = current.label || 'Home';
          this.fullName = current.fullName;
          this.phone = current.phone;
          this.city = current.city;
          this.street = current.street;
          this.notes = current.notes || '';
          this.lat = current.lat ?? 30.0444;
          this.lng = current.lng ?? 31.2357;
          this.isDefault = !!current.isDefault;
        },
      });
    }
  }

  onCoords(c: { lat: number; lng: number }): void {
    this.lat = c.lat;
    this.lng = c.lng;
  }

  submit(ev: Event): void {
    ev.preventDefault();
    const body = {
      label: this.label || 'Home',
      fullName: this.fullName,
      phone: this.phone,
      city: this.city,
      street: this.street,
      notes: this.notes,
      lat: this.lat,
      lng: this.lng,
      isDefault: this.isDefault,
    };
    const req = this.id
      ? this.api.patch(`/addresses/${this.id}`, body)
      : this.api.post('/addresses', body);
    req.subscribe({
      next: () => {
        this.toast.show(this.i18n.t('saved'));
        void this.router.navigate(['/addresses']);
      },
      error: (e) => this.error.set(e.message),
    });
  }
}
