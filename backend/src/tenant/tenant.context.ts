import { AsyncLocalStorage } from 'async_hooks';

export type AppChannel = 'website' | 'admin' | 'mobile';

export type TenantStore = {
  kind: 'tenant' | 'platform' | 'none';
  tenantId?: string;
  slug?: string;
  channel?: AppChannel;
  status?: string;
  channels?: {
    website: boolean;
    admin: boolean;
    mobile: boolean;
  };
};

const als = new AsyncLocalStorage<TenantStore>();

export const TenantContext = {
  run<T>(store: TenantStore, fn: () => T): T {
    return als.run(store, fn);
  },

  get(): TenantStore {
    return als.getStore() ?? { kind: 'none' };
  },

  isPlatform(): boolean {
    return this.get().kind === 'platform';
  },

  tenantId(): string | undefined {
    return this.get().tenantId;
  },

  requireTenantId(): string {
    const id = this.tenantId();
    if (!id) {
      throw new Error('Tenant context missing');
    }
    return id;
  },
};
