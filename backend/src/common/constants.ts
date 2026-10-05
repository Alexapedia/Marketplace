export const STAFF_ROLES = [
  'super_admin',
  'admin',
  'support_agent',
  'order_manager',
  'product_manager',
  'marketing_manager',
] as const;

export type StaffRole = (typeof STAFF_ROLES)[number];

export const USER_ROLES = ['customer', ...STAFF_ROLES] as const;
export type UserRole = (typeof USER_ROLES)[number];

export const ALL_PERMISSIONS = [
  'dashboard.read',
  'products.read',
  'products.write',
  'categories.read',
  'categories.write',
  'custom-fields.read',
  'custom-fields.write',
  'orders.read',
  'orders.write',
  'custom-orders.read',
  'custom-orders.write',
  'customers.read',
  'customers.write',
  'chats.read',
  'chats.write',
  'notifications.write',
  'app-config.read',
  'app-config.write',
  'ads.read',
  'ads.write',
  'reports.read',
  'audit-logs.read',
  'roles.read',
  'roles.write',
  'reviews.read',
  'reviews.write',
] as const;

export type Permission = (typeof ALL_PERMISSIONS)[number];

export const ORDER_STATUSES = [
  'pending',
  'accepted',
  'rejected',
  'preparing',
  'ready',
  'out_for_delivery',
  'delivered',
  'completed',
  'cancelled',
] as const;

export type OrderStatus = (typeof ORDER_STATUSES)[number];

export const CUSTOM_ORDER_STATUSES = [
  'draft',
  'submitted',
  'under_review',
  'need_more_details',
  'quote_sent',
  'waiting_confirmation',
  'confirmed',
  'rejected',
  'in_preparation',
  'ready_shipped',
  'completed',
  'cancelled',
] as const;

export type CustomOrderStatus = (typeof CUSTOM_ORDER_STATUSES)[number];

export const PAYMENT_METHODS = ['COD', 'ONLINE'] as const;
export type PaymentMethod = (typeof PAYMENT_METHODS)[number];

export const PAYMENT_STATUSES = [
  'pending',
  'paid',
  'failed',
  'refunded',
  'cancelled',
] as const;
export type PaymentStatus = (typeof PAYMENT_STATUSES)[number];

export const ALLOWED_UPLOAD_MIMES = [
  'image/jpeg',
  'image/png',
  'image/webp',
  'application/pdf',
];

export const MAX_UPLOAD_BYTES = 8 * 1024 * 1024;
