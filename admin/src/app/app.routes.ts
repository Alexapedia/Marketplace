import { Routes } from '@angular/router';
import { authGuard, guestGuard, superAdminGuard } from './core/auth/auth.guard';

export const routes: Routes = [
  {
    path: 'login',
    canActivate: [guestGuard],
    loadComponent: () => import('./features/login/login-page').then((m) => m.LoginPage),
  },
  {
    path: '',
    canActivate: [authGuard],
    loadComponent: () => import('./layout/shell').then((m) => m.Shell),
    children: [
      { path: '', pathMatch: 'full', redirectTo: 'dashboard' },
      {
        path: 'dashboard',
        loadComponent: () =>
          import('./features/dashboard/dashboard-page').then((m) => m.DashboardPage),
      },
      {
        path: 'products',
        loadComponent: () =>
          import('./features/products/products-page').then((m) => m.ProductsPage),
      },
      {
        path: 'categories',
        loadComponent: () =>
          import('./features/categories/categories-page').then((m) => m.CategoriesPage),
      },
      {
        path: 'custom-fields',
        loadComponent: () =>
          import('./features/custom-fields/custom-fields-page').then((m) => m.CustomFieldsPage),
      },
      {
        path: 'orders',
        loadComponent: () => import('./features/orders/orders-page').then((m) => m.OrdersPage),
      },
      {
        path: 'custom-orders',
        loadComponent: () =>
          import('./features/custom-orders/custom-orders-page').then((m) => m.CustomOrdersPage),
      },
      {
        path: 'customers',
        loadComponent: () =>
          import('./features/customers/customers-page').then((m) => m.CustomersPage),
      },
      {
        path: 'chat',
        loadComponent: () => import('./features/chat/chat-page').then((m) => m.ChatPage),
      },
      {
        path: 'notifications',
        loadComponent: () =>
          import('./features/notifications/notifications-page').then((m) => m.NotificationsPage),
      },
      {
        path: 'app-config',
        loadComponent: () =>
          import('./features/app-config/app-config-page').then((m) => m.AppConfigPage),
      },
      {
        path: 'reports',
        loadComponent: () => import('./features/reports/reports-page').then((m) => m.ReportsPage),
      },
      {
        path: 'audit-logs',
        loadComponent: () =>
          import('./features/audit-logs/audit-logs-page').then((m) => m.AuditLogsPage),
      },
      {
        path: 'roles',
        canActivate: [superAdminGuard],
        loadComponent: () => import('./features/roles/roles-page').then((m) => m.RolesPage),
      },
    ],
  },
  { path: '**', redirectTo: 'dashboard' },
];
