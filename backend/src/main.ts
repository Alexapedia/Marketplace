import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { configureApp } from './app.setup';
import { SocketIoAdapter } from './chat/socket-io.adapter';
import { corsOptions, swaggerEnabled } from './common/utils/cors';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  app.useWebSocketAdapter(new SocketIoAdapter(app));
  const config = app.get(ConfigService);

  configureApp(app);

  const env = {
    NODE_ENV: config.get<string>('NODE_ENV'),
    CORS_ORIGINS: config.get<string>('CORS_ORIGINS'),
    SWAGGER_ENABLED: config.get<string>('SWAGGER_ENABLED'),
  };
  app.enableCors(corsOptions(env));

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
