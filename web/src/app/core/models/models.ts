export type Lang = 'en' | 'ar';

export type Localized = { en?: string; ar?: string } | string | undefined | null;

export interface ApiEnvelope<T> {
  success: boolean;
  data: T;
  message?: string;
  meta?: PageMeta;
}

export interface PageMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface User {
  _id?: string;
  id?: string;
  name: string;
  email: string;
  phone?: string;
  avatar?: string;
  role?: string;
}

export interface Product {
  _id?: string;
  id?: string;
  names?: { en?: string; ar?: string };
  name?: { en?: string; ar?: string };
  descriptions?: { en?: string; ar?: string };
  description?: { en?: string; ar?: string };
  images?: string[];
  price: number;
  salePrice?: number;
  stock?: number;
  sizes?: string[];
  flags?: { featured?: boolean; newArrival?: boolean; bestSeller?: boolean };
  categoryId?: string | Category;
  ratingAvg?: number;
  ratingCount?: number;
}

export interface Category {
  _id?: string;
  id?: string;
  names?: { en?: string; ar?: string };
  name?: { en?: string; ar?: string };
  image?: string;
  children?: Category[];
}

export interface Ad {
  _id?: string;
  id?: string;
  image?: string;
  title?: { en?: string; ar?: string } | string;
  subtitle?: { en?: string; ar?: string } | string;
  link?: string;
  productId?: string | Product | null;
  categoryId?: string | Category | null;
  active?: boolean;
  placement?: string;
}

export interface Banner {
  image?: string;
  title?: { en?: string; ar?: string } | string;
  subtitle?: { en?: string; ar?: string } | string;
  link?: string;
  active?: boolean;
  placement?: string;
}

export interface Address {
  _id?: string;
  id?: string;
  label?: string;
  fullName: string;
  phone: string;
  city: string;
  street: string;
  notes?: string;
  lat?: number;
  lng?: number;
  isDefault?: boolean;
}

export interface AppPublicConfig {
  banners?: Banner[];
  settings?: {
    supportEmail?: string;
    supportPhone?: string;
    deliveryFee?: number;
    currency?: string;
  };
}

export interface CartItem {
  _id?: string;
  productId: string | Product;
  nameSnapshot: string;
  image?: string;
  unitPrice: number;
  quantity: number;
  size?: string;
}

export interface Cart {
  items: CartItem[];
}

export interface OrderItem {
  productId?: string | Product;
  nameSnapshot?: string;
  image?: string;
  unitPrice?: number;
  quantity?: number;
  size?: string;
}

export interface Order {
  _id?: string;
  status?: string;
  orderStatus?: string;
  total?: number;
  grandTotal?: number;
  createdAt?: string;
  rating?: number;
  ratingComment?: string;
  items?: OrderItem[];
  notes?: string;
  addressSnapshot?: Address;
}

export interface CustomField {
  _id?: string;
  id?: string;
  categoryId?: string;
  labels?: { en?: string; ar?: string };
  fieldType: string;
  required?: boolean;
  options?: string[];
  sortOrder?: number;
}

export interface CustomOrder {
  _id?: string;
  status?: string;
  description?: string;
  categoryId?: string | Category;
  attachments?: string[];
  fields?: Record<string, unknown>;
  proposals?: CustomProposal[];
}

export interface CustomProposal {
  _id?: string;
  productName?: string;
  price?: number;
  notes?: string;
  status?: string;
}

export interface ChatMessage {
  _id?: string;
  id?: string;
  conversationId?: string;
  text?: string;
  senderRole?: string;
  createdAt?: string;
  attachments?: string[];
  type?: string;
}

export interface Review {
  id?: string;
  _id?: string;
  targetType?: string;
  rating: number;
  comment?: string;
  userName?: string;
  targetName?: { en?: string; ar?: string } | string;
  createdAt?: string;
}

export interface ReviewsPayload {
  items?: Review[];
  ratingAvg?: number;
  ratingCount?: number;
  canRate?: boolean;
  myReview?: Review | null;
}

export interface Favorite {
  _id?: string;
  productId?: Product | string;
}

export interface NotificationItem {
  _id?: string;
  id?: string;
  title: { en: string; ar: string };
  body: { en: string; ar: string };
  type: string;
  readAt?: string;
  createdAt?: string;
}

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

export function pid(p: { _id?: string; id?: string } | null | undefined): string {
  return String(p?._id || p?.id || '');
}

export function loc(value: Localized, lang: Lang): string {
  if (value == null) return '';
  if (typeof value === 'string') return value;
  const map = value as Record<string, unknown>;
  const direct = map[lang];
  if (typeof direct === 'string' && direct.trim()) return direct;
  if (typeof map['en'] === 'string' && (map['en'] as string).trim()) return map['en'] as string;
  if (typeof map['ar'] === 'string' && (map['ar'] as string).trim()) return map['ar'] as string;
  for (const v of Object.values(map)) {
    if (typeof v === 'string' && v.trim()) return v;
  }
  return '';
}

export function media(path?: string | null): string {
  const value = (path || '').trim();
  if (!value) return '';
  if (value.startsWith('http') || value.startsWith('data:')) return value;
  return value.startsWith('/') ? value : `/${value}`;
}

export function asItems<T>(data: unknown): T[] {
  if (Array.isArray(data)) return data;
  if (data && typeof data === 'object') {
    const rec = data as Record<string, unknown>;
    if (Array.isArray(rec['items'])) return rec['items'] as T[];
    if (Array.isArray(rec['data'])) return rec['data'] as T[];
  }
  return [];
}

export function productName(p: Product, lang: Lang): string {
  return loc(p.names ?? p.name, lang);
}

export function productDesc(p: Product, lang: Lang): string {
  return loc(p.descriptions ?? p.description, lang);
}

export function priceOf(p: Product): number {
  return p.salePrice && p.salePrice > 0 && p.salePrice < p.price ? p.salePrice : p.price;
}

export function onSale(p: Product): boolean {
  return !!(p.salePrice && p.salePrice > 0 && p.salePrice < p.price);
}

export function flattenCategories(nodes: Category[], out: Category[] = []): Category[] {
  for (const n of nodes) {
    out.push(n);
    if (n.children?.length) flattenCategories(n.children, out);
  }
  return out;
}
