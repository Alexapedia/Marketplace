import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../core/auth/auth.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

@Component({
  selector: 'app-login-page',
  imports: [FormsModule, RouterLink, TranslatePipe],
  templateUrl: './login-page.html',
})
export class LoginPage {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  email = '';
  password = '';
  error = signal('');

  submit(ev: Event): void {
    ev.preventDefault();
    this.error.set('');
    this.auth.login(this.email, this.password).subscribe({
      next: () => void this.router.navigate(['/']),
      error: (e) => this.error.set(e.message),
    });
  }
}
