export interface PageMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface ApiEnvelope<T> {
  success: boolean;
  data: T;
  message?: string;
  meta?: PageMeta;
  statusCode?: number;
}

export interface HolderUser {
  id: string;
  name: string;
  email: string;
  role: string;
  totpEnabled?: boolean;
}

export interface TenantChannels {
  website: boolean;
  admin: boolean;
  mobile: boolean;
}

export interface TenantBranding {
  name: string;
  primary: string;
  accent: string;
  logo?: string;
  logoDark?: string;
  favicon?: string;
  splash?: string;
}

export interface TenantDomain {
  host: string;
  channel: 'website' | 'admin';
}

export interface TenantStaff {
  _id: string;
  name: string;
  email: string;
  role: string;
  status: string;
  totpEnabled?: boolean;
}

export interface TenantRow {
  id: string;
  slug: string;
  name: string;
  status: 'active' | 'suspended';
  channels: TenantChannels;
  branding: TenantBranding;
  currency: string;
  domains?: TenantDomain[];
  customers?: number;
  products?: number;
  orders?: number;
  staff?: TenantStaff[];
  createdAt?: string;
}

export interface SeriesPoint {
  day: string;
  orders: number;
  revenue: number;
  visits?: number;
  crashes?: number;
}

export interface PlatformOverview {
  tenantCount: number;
  active: number;
  suspended: number;
  customers: number;
  staff: number;
  products: number;
  orders: number;
  customOrders: number;
  revenue: number;
  revenue7d: number;
  orders7d: number;
  ordersOpen: number;
  visitsWebsite: number;
  visitsMobile: number;
  openIssues: number;
  crashes24h: number;
  channelsOff: { website: number; admin: number; mobile: number };
  series7: SeriesPoint[];
  topTenants: Array<{ id: string; name: string; orders: number; revenue: number }>;
  recentIssues: PlatformIssue[];
  db: 'up' | 'down';
}

export interface PlatformReports {
  series14: SeriesPoint[];
  ordersByStatus: Array<{ status: string; count: number }>;
  revenueByTenant: Array<{ id: string; name: string; orders: number; revenue: number }>;
  visitsByPlatform: Array<{ platform: string; count: number }>;
  issuesByChannel: Array<{ channel: string; count: number }>;
  channelMatrix: Array<{
    id: string;
    name: string;
    status: string;
    channels: TenantChannels;
  }>;
}

export interface PlatformIssue {
  _id?: string;
  id?: string;
  fingerprint?: string;
  kind: 'crash' | 'error' | 'issue';
  channel: string;
  tenantId?: string;
  message: string;
  stack?: string;
  url?: string;
  userAgent?: string;
  count: number;
  firstSeen?: string;
  lastSeen?: string;
  status?: 'open' | 'resolved';
}

export interface PlatformAudit {
  _id: string;
  actorId?: string;
  action: string;
  tenantId?: string;
  meta?: unknown;
  ip?: string;
  createdAt?: string;
}

export interface AuthOk {
  user: HolderUser;
  accessToken: string;
  backupCodes?: string[];
}

export interface AuthChallenge {
  requires2fa?: boolean;
  requires2faSetup?: boolean;
  challengeToken: string;
  qr?: string;
  otpauthUrl?: string;
}
