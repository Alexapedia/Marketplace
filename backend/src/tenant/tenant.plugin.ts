import { Schema } from 'mongoose';
import { TenantContext } from './tenant.context';

const QUERY_OPS = [
  'find',
  'findOne',
  'findOneAndUpdate',
  'findOneAndDelete',
  'findOneAndReplace',
  'updateOne',
  'updateMany',
  'deleteOne',
  'deleteMany',
  'countDocuments',
  'count',
  'distinct',
  'replaceOne',
] as const;

function applyTenantFilter(this: { getQuery: () => Record<string, unknown>; where: (q: object) => void }) {
  if (TenantContext.isPlatform()) {
    return;
  }
  const tenantId = TenantContext.tenantId();
  if (!tenantId) {
    throw new Error('Tenant context missing');
  }
  const query = this.getQuery();
  if (query['tenantId'] === undefined) {
    this.where({ tenantId });
  }
}

export function applyTenantPlugin(schema: Schema): Schema {
  if (!schema.path('tenantId')) {
    schema.add({
      tenantId: { type: String, required: true, index: true },
    });
  }

  for (const op of QUERY_OPS) {
    (schema as unknown as { pre: (e: string, fn: (...args: never[]) => void) => void }).pre(
      op,
      applyTenantFilter,
    );
  }

  schema.pre('aggregate', function () {
    if (TenantContext.isPlatform()) {
      return;
    }
    const tenantId = TenantContext.tenantId();
    if (!tenantId) {
      throw new Error('Tenant context missing');
    }
    this.pipeline().unshift({ $match: { tenantId } });
  });

  schema.pre('save', function () {
    if (!this.get('tenantId')) {
      this.set('tenantId', TenantContext.requireTenantId());
    }
  });

  (schema as Schema & { pre: (e: string, fn: (...args: never[]) => void) => void }).pre(
    'insertMany',
    function (next: (err?: Error) => void, docs: Array<Record<string, unknown>>) {
      const tenantId = TenantContext.isPlatform() ? undefined : TenantContext.tenantId();
      if (tenantId) {
        for (const doc of docs) {
          if (!doc['tenantId']) {
            doc['tenantId'] = tenantId;
          }
        }
      }
      next();
    },
  );

  return schema;
}
