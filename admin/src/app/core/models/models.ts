export interface Localized {
  en: string;
  ar: string;
}

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
  errors?: Record<string, unknown>;
}

export type StaffRole =
  | 'super_admin'
  | 'admin'
  | 'support_agent'
  | 'order_manager'
  | 'product_manager'
  | 'marketing_manager';

export type UserRole = StaffRole | 'customer';

export interface User {
  _id?: string;
  id?: string;
  name: string;
  email: string;
  phone?: string;
  avatar?: string;
  role: UserRole;
  status: 'active' | 'blocked';
  language?: 'en' | 'ar';
  theme?: 'light' | 'dark' | 'system';
  permissions?: string[];
  createdAt?: string;
}

export interface AuthPayload {
  user?: User;
  accessToken?: string;
  backupCodes?: string[];
  requires2fa?: boolean;
  requires2faSetup?: boolean;
  challengeToken?: string;
  qr?: string;
  otpauthUrl?: string;
}

export interface ProductFlags {
  featured?: boolean;
  newArrival?: boolean;
  bestSeller?: boolean;
}

export interface ProductVariant {
  sku?: string;
  name?: string;
  price?: number;
  stock?: number;
  attributes?: Record<string, unknown>;
}

export interface Product {
  _id?: string;
  id?: string;
  categoryId?: string | Category;
  name?: Localized;
  names?: Localized;
  description?: Localized;
  descriptions?: Localized;
  images?: string[];
  price: number;
  salePrice?: number;
  stock?: number;
  variants?: ProductVariant[];
  gender?: string;
  sizes?: string[];
  flags?: ProductFlags;
  sortOrder?: number;
  status?: 'published' | 'unpublished' | 'archived';
  relatedProductIds?: string[];
  ratingAvg?: number;
  ratingCount?: number;
  createdAt?: string;
}

export interface Category {
  _id?: string;
  id?: string;
  name?: Localized;
  names?: Localized;
  parentId?: string | null;
  image?: string;
  type?: 'standard' | 'custom' | 'both';
  status?: string;
  sortOrder?: number;
  children?: Category[];
}

export type CustomFieldType =
  | 'text'
  | 'number'
  | 'dropdown'
  | 'multi_select'
  | 'boolean'
  | 'size'
  | 'color'
  | 'image'
  | 'textarea';

export interface CustomField {
  _id?: string;
  id?: string;
  categoryId: string;
  label?: Localized;
  labels?: Localized;
  fieldType: CustomFieldType;
  required?: boolean;
  options?: string[];
  sortOrder?: number;
  status?: string;
}

export type OrderStatus =
  | 'pending'
  | 'accepted'
  | 'rejected'
  | 'preparing'
  | 'ready'
  | 'out_for_delivery'
  | 'delivered'
  | 'completed'
  | 'cancelled';

export interface OrderItem {
  productId?: string | Product;
  nameSnapshot?: Localized | string;
  image?: string;
  unitPrice: number;
  quantity: number;
  variant?: string;
  size?: string;
}

export interface OrderAddress {
  fullName?: string;
  phone?: string;
  city?: string;
  street?: string;
  notes?: string;
}

export interface StatusHistory {
  status: string;
  at?: string;
  actorId?: string;
  note?: string;
}

export interface Order {
  _id?: string;
  id?: string;
  userId?: string | User;
  orderNumber?: string;
  items?: OrderItem[];
  address?: OrderAddress;
  subtotal?: number;
  discount?: number;
  deliveryFee?: number;
  total?: number;
  paymentMethod?: 'COD' | 'ONLINE';
  paymentStatus?: string;
  orderStatus?: OrderStatus;
  status?: OrderStatus;
  rejectionReason?: string;
  notes?: string;
  channel?: 'mobile' | 'website' | 'admin';
  statusHistory?: StatusHistory[];
  rating?: number;
  ratingComment?: string;
  createdAt?: string;
}

export type CustomOrderStatus =
  | 'draft'
  | 'submitted'
  | 'under_review'
  | 'need_more_details'
  | 'quote_sent'
  | 'waiting_confirmation'
  | 'confirmed'
  | 'rejected'
  | 'in_preparation'
  | 'ready_shipped'
  | 'completed'
  | 'cancelled';

export interface Proposal {
  version?: number;
  productName?: string;
  images?: string[];
  description?: string;
  specifications?: Record<string, unknown>;
  price?: number;
  quantity?: number;
  estimatedDays?: number;
  notes?: string;
  status?: 'sent' | 'confirmed' | 'rejected' | 'replaced';
  customerResponse?: string;
  respondedAt?: string;
}

export interface CustomOrder {
  _id?: string;
  id?: string;
  userId?: string | User;
  categoryId?: string | Category;
  fields?: Record<string, unknown>;
  description?: string;
  attachments?: string[];
  status?: CustomOrderStatus;
  proposals?: Proposal[];
  createdAt?: string;
}

export interface Conversation {
  _id?: string;
  id?: string;
  userId?: string | User;
  customOrderId?: string;
  orderId?: string;
  lastMessageAt?: string;
  lastMessage?: string;
  unreadByStaff?: number;
  unreadByCustomer?: number;
}

export interface ChatMessage {
  _id?: string;
  id?: string;
  conversationId?: string;
  senderId?: string;
  senderRole?: string;
  type?: 'text' | 'image' | 'file' | 'system' | 'proposal';
  text?: string;
  attachments?: string[];
  createdAt?: string;
  readAt?: string;
}

export interface AppNotification {
  _id?: string;
  id?: string;
  userId?: string;
  title?: Localized;
  body?: Localized;
  type?: string;
  data?: Record<string, unknown>;
  createdAt?: string;
  readAt?: string | null;
  sent?: number;
}

export interface VersionConfig {
  latest?: string;
  minimum?: string;
  forceUpdate?: boolean;
  storeUrl?: string;
  message?: Localized;
}

export interface Banner {
  _id?: string;
  id?: string;
  image?: string;
  title?: Localized | string;
  subtitle?: Localized | string;
  link?: string;
  productId?: string;
  categoryId?: string;
  active?: boolean;
  placement?: 'home' | 'products' | 'both';
  sortOrder?: number;
}

export interface OnboardingSlide {
  image?: string;
  title?: Localized | string;
  body?: Localized | string;
}

export interface TenantPublic {
  id?: string;
  slug?: string;
  name?: string;
  status?: 'active' | 'suspended';
  channels?: { website?: boolean; admin?: boolean; mobile?: boolean };
  branding?: {
    name?: string;
    primary?: string;
    accent?: string;
    logo?: string;
    logoDark?: string;
    favicon?: string;
    splash?: string;
  };
  currency?: string;
}

export interface AppConfig {
  _id?: string;
  key?: string;
  banners?: Banner[];
  onboarding?: OnboardingSlide[];
  version?: {
    android?: VersionConfig;
    ios?: VersionConfig;
  };
  settings?: Record<string, unknown>;
}

export interface DashboardStats {
  orders?: number;
  ordersCount?: number;
  pendingCustomOrders?: number;
  pendingCustom?: number;
  revenue?: number;
  profit?: number;
  deliveryFees?: number;
  products?: number;
  productsCount?: number;
  customers?: number;
  customersCount?: number;
  newCustomers?: number;
  unreadChats?: number;
  unreadChatCount?: number;
  lowStock?: number;
  activeCustomers?: number;
  inactiveCustomers?: number;
  publishedProducts?: number;
  unpublishedProducts?: number;
  ordersByStatus?: Array<{ status: string; count: number; revenue?: number }>;
  customOrdersByStatus?: Array<{ status: string; count: number }>;
  ordersByChannel?: Array<{ channel: string; count: number; revenue?: number }>;
  topProducts?: Array<{ name?: string; productId?: string; quantity?: number; revenue?: number }>;
  visits?: {
    visitsMobile?: number;
    visitsWebsite?: number;
    uniqueMobile?: number;
    uniqueWebsite?: number;
  };
  series?: Array<{ date: string; orders: number; revenue: number }>;
  trend?: {
    orders?: number;
    revenue?: number;
    thisWeekOrders?: number;
    prevWeekOrders?: number;
  };
  recent?: Array<{ label: string; value: number }>;
}

export interface ReportInsight {
  severity?: 'info' | 'warn' | 'ok';
  title?: Localized | string;
  body?: Localized | string;
}

export interface ReportsData {
  ordersByStatus?: Array<{ status?: string; _id?: string; count?: number; revenue?: number }>;
  topProducts?: Array<{ name?: Localized | string; productId?: string; quantity?: number; revenue?: number }>;
  customStats?: Array<{ _id?: string; status?: string; count?: number }> | Record<string, number>;
  rejectedReasons?: Array<{ reason?: string; _id?: string; count?: number }>;
  visits?: DashboardStats['visits'];
  ordersByChannel?: Array<{ _id?: string; channel?: string; count?: number; revenue?: number }>;
  buyersByChannel?: Array<{ channel?: string; _id?: string; orders?: number; buyers?: number }>;
  profitLoss?: {
    grossRevenue?: number;
    deliveryCost?: number;
    netProfit?: number;
    lostSales?: number;
    lostCount?: number;
  };
  insights?: ReportInsight[];
  totals?: {
    orders?: number;
    revenue?: number;
    customOrders?: number;
    customers?: number;
    conversion?: number;
  };
}

export interface AuditLog {
  _id?: string;
  id?: string;
  actorId?: string | User;
  action?: string;
  entity?: string;
  entityId?: string;
  oldValue?: unknown;
  newValue?: unknown;
  ip?: string;
  createdAt?: string;
}

export interface Review {
  id?: string;
  _id?: string;
  targetType?: 'product' | 'order' | 'app' | 'website';
  targetId?: string | null;
  rating: number;
  comment?: string;
  userName?: string;
  userEmail?: string;
  targetName?: Localized | string | null;
  hidden?: boolean;
  createdAt?: string;
}

export interface Role {
  _id?: string;
  id?: string;
  name: string;
  permissions: string[];
  isSystem?: boolean;
}

export const STAFF_ROLES: StaffRole[] = [
  'super_admin',
  'admin',
  'support_agent',
  'order_manager',
  'product_manager',
  'marketing_manager',
];

export const ORDER_STATUSES: OrderStatus[] = [
  'pending',
  'accepted',
  'rejected',
  'preparing',
  'ready',
  'out_for_delivery',
  'delivered',
  'completed',
  'cancelled',
];

export const CUSTOM_FIELD_TYPES: CustomFieldType[] = [
  'text',
  'number',
  'dropdown',
  'multi_select',
  'boolean',
  'size',
  'color',
  'image',
  'textarea',
];

export function entityId(entity: { _id?: string; id?: string } | string | undefined | null): string {
  if (!entity) {
    return '';
  }
  if (typeof entity === 'string') {
    return entity;
  }
  return entity._id ?? entity.id ?? '';
}

export function productRef(value: unknown): string {
  return entityId(value as { _id?: string; id?: string } | string | undefined | null);
}

export function loc(value: Localized | string | undefined | null, lang: 'en' | 'ar'): string {
  if (!value) {
    return '';
  }
  if (typeof value === 'string') {
    return value;
  }
  return value[lang] || value.en || value.ar || '';
}

export function localizedOf(entity: {
  name?: Localized;
  names?: Localized;
  label?: Localized;
  labels?: Localized;
  description?: Localized;
  descriptions?: Localized;
}): Localized {
  return (
    entity.name ??
    entity.names ??
    entity.label ??
    entity.labels ??
    entity.description ??
    entity.descriptions ?? { en: '', ar: '' }
  );
}

export function num(value: unknown, fallback = 0): number {
  return typeof value === 'number' && !Number.isNaN(value) ? value : fallback;
}
