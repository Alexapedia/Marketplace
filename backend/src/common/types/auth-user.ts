export interface AuthUser {
  userId: string;
  email: string;
  name: string;
  role: string;
  type: 'customer' | 'staff';
  status: string;
  permissions: string[];
}
