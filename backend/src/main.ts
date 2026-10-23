import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import helmet from 'helmet';
import { existsSync, mkdirSync } from 'fs';
import { join } from 'path';
import { AppModule } from './app.module';
import { SocketIoAdapter } from './chat/socket-io.adapter';
import { corsOptions, swaggerEnabled } from './common/utils/cors';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  app.useWebSocketAdapter(new SocketIoAdapter(app));
  const config = app.get(ConfigService);

  app.setGlobalPrefix('api/v1');
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  const env = {
    NODE_ENV: config.get<string>('NODE_ENV'),
    CORS_ORIGINS: config.get<string>('CORS_ORIGINS'),
    SWAGGER_ENABLED: config.get<string>('SWAGGER_ENABLED'),
  };
  app.enableCors(corsOptions(env));

  app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));

  const uploadDir = join(
    process.cwd(),
    config.get<string>('UPLOAD_DIR') || './uploads',
  );
  if (!existsSync(uploadDir)) {
    mkdirSync(uploadDir, { recursive: true });
  }
  app.useStaticAssets(uploadDir, { prefix: '/uploads/' });

  if (swaggerEnabled(env)) {
    const swagger = new DocumentBuilder()
      .setTitle('PlaceMarket API')
      .setDescription('PlaceMarket REST API v1')
      .setVersion('1.0')
      .addBearerAuth()
      .build();
    const document = SwaggerModule.createDocument(app, swagger);
    SwaggerModule.setup('docs', app, document, { useGlobalPrefix: false });
  }

  const port = Number(config.get('PORT') || 3000);
  await app.listen(port);
}

bootstrap();
