import { ConfigService } from '@nestjs/config';

const DEV_FALLBACK = 'change-me-in-production';

function resolve(config: ConfigService, value: string | undefined, name: string) {
  if (value) return value;
  if (config.get<string>('NODE_ENV') === 'production') {
    throw new Error(`${name} must be set in production`);
  }
  return DEV_FALLBACK;
}

export function tenantJwtSecret(config: ConfigService): string {
  return resolve(config, config.get<string>('JWT_SECRET'), 'JWT_SECRET');
}

export function platformJwtSecret(config: ConfigService): string {
  return resolve(
    config,
    config.get<string>('JWT_PLATFORM_SECRET') || config.get<string>('JWT_SECRET'),
    'JWT_PLATFORM_SECRET',
  );
}
