import { INestApplication, ValidationPipe } from '@nestjs/common';
import { getConnectionToken } from '@nestjs/mongoose';
import { Test, TestingModule } from '@nestjs/testing';
import { Connection } from 'mongoose';
import request from 'supertest';
import { App } from 'supertest/types';

process.env.MONGODB_URI =
  process.env.E2E_MONGODB_URI || 'mongodb://127.0.0.1:27017/placemarket_e2e';
process.env.NODE_ENV = 'test';

// Imported after env is set so ConfigModule picks up the e2e database.
// eslint-disable-next-line @typescript-eslint/no-require-imports
const { AppModule } = require('../src/app.module');

describe('API (e2e)', () => {
  let app: INestApplication<App>;
  const email = `e2e.${Date.now()}@example.com`;
  const password = 'Passw0rd!e2e';

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api/v1');
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        transform: true,
        transformOptions: { enableImplicitConversion: true },
      }),
    );
    await app.init();
  }, 60000);

  afterAll(async () => {
    await app.get<Connection>(getConnectionToken()).dropDatabase();
    await app.close();
  });

  const http = () => request(app.getHttpServer());

  it('GET /health', () => http().get('/api/v1/health').expect(200));

  it('register → refresh rotates → old token rejected → logout', async () => {
    const reg = await http()
      .post('/api/v1/auth/register')
      .send({ name: 'E2E', email, password })
      .expect(201);
    const first = reg.body.data.refreshToken as string;
    expect(reg.body.data.accessToken).toBeTruthy();
    expect(first).toBeTruthy();

    const refreshed = await http()
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: first })
      .expect(201);
    const second = refreshed.body.data.refreshToken as string;
    expect(second).not.toEqual(first);

    await http()
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: first })
      .expect(401);

    await http()
      .post('/api/v1/auth/logout')
      .set('Authorization', `Bearer ${refreshed.body.data.accessToken}`)
      .send({ refreshToken: second })
      .expect(201);

    await http()
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: second })
      .expect(401);
  });

  it('forgot-password issues a token that resets the password', async () => {
    const forgot = await http()
      .post('/api/v1/auth/forgot-password')
      .send({ email })
      .expect(201);
    const token = forgot.body.data.resetToken as string;
    expect(token).toBeTruthy();
    await http()
      .post('/api/v1/auth/reset-password')
      .send({ token, password: 'N3wPassw0rd!' })
      .expect(201);
    await http()
      .post('/api/v1/auth/login')
      .send({ email, password: 'N3wPassw0rd!' })
      .expect(201);
  });

  it('GET /products supports price filters and escapes search', async () => {
    const res = await http()
      .get('/api/v1/products?minPrice=0&maxPrice=1000000&search=(%5B&sort=-ratingAvg')
      .expect(200);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.meta).toBeDefined();
  });
});
