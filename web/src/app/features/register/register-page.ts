import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../core/auth/auth.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

@Component({
  selector: 'app-register-page',
  imports: [FormsModule, RouterLink, TranslatePipe],
  templateUrl: './register-page.html',
})
export class RegisterPage {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  name = '';
  email = '';
  password = '';
  phone = '';
  error = signal('');

  submit(ev: Event): void {
    ev.preventDefault();
    this.error.set('');
    this.auth.register({ name: this.name, email: this.email, password: this.password, phone: this.phone }).subscribe({
      next: () => void this.router.navigate(['/']),
      error: (e) => this.error.set(e.message),
    });
  }
}
