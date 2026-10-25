import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestExpressApplication } from '@nestjs/platform-express';
import helmet from 'helmet';
import { existsSync, mkdirSync } from 'fs';
import { resolveUploadDir } from './common/utils/upload-url';

/**
 * HTTP pipeline shared by main.ts and the integration-test harness, so tests
 * exercise the same prefix, validation, security headers and static uploads
 * as production.
 */
export function configureApp(app: NestExpressApplication): void {
  const config = app.get(ConfigService);

  // Behind nginx/cloudflared every request otherwise comes from the proxy's
  // IP, so rate limits would be shared by all users. Trusting only private
  // hops keeps X-Forwarded-For unspoofable for clients on the open internet.
  app.set('trust proxy', trustProxySetting(config.get<string>('TRUST_PROXY')));

  app.setGlobalPrefix('api/v1');
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));

  const uploadDir = resolveUploadDir(config.get<string>('UPLOAD_DIR'));
  if (!existsSync(uploadDir)) {
    mkdirSync(uploadDir, { recursive: true });
  }
  app.useStaticAssets(uploadDir, {
    prefix: '/uploads/',
    // User uploads are data, never documents: block MIME sniffing and any
    // script/frame execution even if a file is opened directly.
    setHeaders: (res) => {
      res.setHeader('X-Content-Type-Options', 'nosniff');
      res.setHeader(
        'Content-Security-Policy',
        "default-src 'none'; img-src 'self'; style-src 'unsafe-inline'; sandbox",
      );
    },
  });
}

/** TRUST_PROXY: hop count, true/false, or an Express trust list. */
export function trustProxySetting(raw?: string): boolean | number | string {
  const value = raw?.trim();
  if (!value) return 'loopback, linklocal, uniquelocal';
  if (value === 'true') return true;
  if (value === 'false') return false;
  if (/^\d+$/.test(value)) return Number(value);
  return value;
}
