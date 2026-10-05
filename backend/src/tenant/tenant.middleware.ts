import {
  Injectable,
  NestMiddleware,
  NotFoundException,
  ServiceUnavailableException,
} from '@nestjs/common';
import { NextFunction, Request, Response } from 'express';
import { TenantContext } from './tenant.context';
import { TenantService } from './tenant.service';

const SKIP_TENANT = [
  '/api/v1/health',
  '/docs',
  '/docs-json',
  '/socket.io',
];

function isPlatformPath(path: string): boolean {
  return path.startsWith('/api/v1/platform');
}

function isTelemetry(path: string): boolean {
  return path.startsWith('/api/v1/telemetry');
}

function isAlwaysOpen(path: string): boolean {
  return (
    path === '/api/v1/app/config' ||
    path === '/api/v1/app/version' ||
    path.startsWith('/api/v1/platform/auth')
  );
}

@Injectable()
export class TenantMiddleware implements NestMiddleware {
  constructor(private readonly tenants: TenantService) {}

  use(req: Request, _res: Response, next: NextFunction): void {
    const path = req.originalUrl.split('?')[0];
    if (SKIP_TENANT.some((p) => path === p || path.startsWith(`${p}/`))) {
      TenantContext.run({ kind: 'none' }, () => next());
      return;
    }

    if (isPlatformPath(path)) {
      TenantContext.run({ kind: 'platform' }, () => next());
      return;
    }

    if (isTelemetry(path)) {
      void this.bindTelemetry(req, path, next);
      return;
    }

    void this.bindTenant(req, path, next);
  }

  private async bindTelemetry(req: Request, path: string, next: NextFunction) {
    try {
      const resolved = await this.tenants.resolveFromRequest({
        origin: typeof req.headers.origin === 'string' ? req.headers.origin : undefined,
        referer: typeof req.headers.referer === 'string' ? req.headers.referer : undefined,
        host: typeof req.headers.host === 'string' ? req.headers.host : undefined,
        client: String(req.headers['x-client'] || ''),
        path,
      });
      if (!resolved) {
        TenantContext.run({ kind: 'none' }, () => next());
        return;
      }
      TenantContext.run(
        {
          kind: 'tenant',
          tenantId: String(resolved.tenant._id),
          slug: resolved.tenant.slug,
          channel: resolved.channel,
        },
        () => next(),
      );
    } catch {
      TenantContext.run({ kind: 'none' }, () => next());
    }
  }

  private async bindTenant(req: Request, path: string, next: NextFunction) {
    try {
      const resolved = await this.tenants.resolveFromRequest({
        origin: typeof req.headers.origin === 'string' ? req.headers.origin : undefined,
        referer: typeof req.headers.referer === 'string' ? req.headers.referer : undefined,
        host: typeof req.headers.host === 'string' ? req.headers.host : undefined,
        client: String(req.headers['x-client'] || ''),
        path,
      });
      if (!resolved) {
        next(new NotFoundException('Unknown store'));
        return;
      }
      const { tenant, channel } = resolved;
      if (!isAlwaysOpen(path)) {
        this.tenants.assertChannel(tenant, channel);
      } else if (tenant.status === 'suspended' && !isAlwaysOpen(path)) {
        throw new ServiceUnavailableException('This store is suspended');
      }
      TenantContext.run(
        {
          kind: 'tenant',
          tenantId: String(tenant._id),
          slug: tenant.slug,
          channel,
          status: tenant.status,
          channels: {
            website: tenant.channels?.website !== false,
            admin: tenant.channels?.admin !== false,
            mobile: tenant.channels?.mobile !== false,
          },
        },
        () => next(),
      );
    } catch (err) {
      next(err);
    }
  }
}
