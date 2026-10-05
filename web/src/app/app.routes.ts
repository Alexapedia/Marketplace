import { Routes } from '@angular/router';
import { authGuard, guestGuard } from './core/auth/auth.guard';

export const routes: Routes = [
  {
    path: 'login',
    canActivate: [guestGuard],
    loadComponent: () => import('./features/login/login-page').then((m) => m.LoginPage),
  },
  {
    path: 'register',
    canActivate: [guestGuard],
    loadComponent: () => import('./features/register/register-page').then((m) => m.RegisterPage),
  },
  {
    path: 'forgot',
    canActivate: [guestGuard],
    loadComponent: () => import('./features/forgot/forgot-page').then((m) => m.ForgotPage),
  },
  {
    path: 'reset',
    canActivate: [guestGuard],
    loadComponent: () => import('./features/reset/reset-page').then((m) => m.ResetPage),
  },
  {
    path: '',
    loadComponent: () => import('./layout/shell').then((m) => m.Shell),
    children: [
      {
        path: '',
        loadComponent: () => import('./features/home/home-page').then((m) => m.HomePage),
      },
      {
        path: 'shop',
        loadComponent: () => import('./features/shop/shop-page').then((m) => m.ShopPage),
      },
      {
        path: 'product/:id',
        loadComponent: () => import('./features/product/product-page').then((m) => m.ProductPage),
      },
      {
        path: 'cart',
        canActivate: [authGuard],
        loadComponent: () => import('./features/cart/cart-page').then((m) => m.CartPage),
      },
      {
        path: 'checkout',
        canActivate: [authGuard],
        loadComponent: () => import('./features/checkout/checkout-page').then((m) => m.CheckoutPage),
      },
      {
        path: 'orders',
        canActivate: [authGuard],
        loadComponent: () => import('./features/orders/orders-page').then((m) => m.OrdersPage),
      },
      {
        path: 'orders/:id',
        canActivate: [authGuard],
        loadComponent: () =>
          import('./features/order-detail/order-detail-page').then((m) => m.OrderDetailPage),
      },
      {
        path: 'custom',
        canActivate: [authGuard],
        loadComponent: () => import('./features/custom/custom-list-page').then((m) => m.CustomListPage),
      },
      {
        path: 'custom/new',
        canActivate: [authGuard],
        loadComponent: () => import('./features/custom/custom-new-page').then((m) => m.CustomNewPage),
      },
      {
        path: 'custom/:id',
        canActivate: [authGuard],
        loadComponent: () =>
          import('./features/custom/custom-detail-page').then((m) => m.CustomDetailPage),
      },
      {
        path: 'favorites',
        canActivate: [authGuard],
        loadComponent: () => import('./features/favorites/favorites-page').then((m) => m.FavoritesPage),
      },
      {
        path: 'account',
        canActivate: [authGuard],
        loadComponent: () => import('./features/account/account-page').then((m) => m.AccountPage),
      },
      {
        path: 'account/edit',
        canActivate: [authGuard],
        loadComponent: () =>
          import('./features/account/account-edit-page').then((m) => m.AccountEditPage),
      },
      {
        path: 'addresses',
        canActivate: [authGuard],
        loadComponent: () => import('./features/addresses/addresses-page').then((m) => m.AddressesPage),
      },
      {
        path: 'address',
        canActivate: [authGuard],
        loadComponent: () =>
          import('./features/addresses/address-form-page').then((m) => m.AddressFormPage),
      },
      {
        path: 'address/:id',
        canActivate: [authGuard],
        loadComponent: () =>
          import('./features/addresses/address-form-page').then((m) => m.AddressFormPage),
      },
      {
        path: 'notifications',
        canActivate: [authGuard],
        loadComponent: () =>
          import('./features/notifications/notifications-page').then((m) => m.NotificationsPage),
      },
    ],
  },
  { path: '**', redirectTo: '' },
];
