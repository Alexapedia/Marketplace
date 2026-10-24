import { Routes } from '@angular/router';
import { authGuard, guestGuard } from './core/auth/auth.guard';

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
      { path: '', pathMatch: 'full', redirectTo: 'overview' },
      {
        path: 'overview',
        loadComponent: () =>
          import('./features/overview/overview-page').then((m) => m.OverviewPage),
      },
      {
        path: 'tenants',
        loadComponent: () => import('./features/tenants/tenants-page').then((m) => m.TenantsPage),
      },
      {
        path: 'tenants/new',
        loadComponent: () =>
          import('./features/tenants/tenant-create-page').then((m) => m.TenantCreatePage),
      },
      {
        path: 'tenants/:id',
        loadComponent: () =>
          import('./features/tenants/tenant-detail-page').then((m) => m.TenantDetailPage),
      },
      {
        path: 'reports',
        loadComponent: () => import('./features/reports/reports-page').then((m) => m.ReportsPage),
      },
      {
        path: 'issues',
        loadComponent: () => import('./features/issues/issues-page').then((m) => m.IssuesPage),
      },
      {
        path: 'audit',
        loadComponent: () => import('./features/audit/audit-page').then((m) => m.AuditPage),
      },
    ],
  },
  { path: '**', redirectTo: 'overview' },
];
