import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';
import { PlatformTelemetryService } from '../../platform/platform-telemetry.service';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  constructor(private readonly telemetry: PlatformTelemetryService) {}

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const res = ctx.getResponse<Response>();
    const req = ctx.getRequest<{ originalUrl?: string; headers?: Record<string, unknown> }>();

    let statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'Internal server error';
    let errors: unknown;

    if (exception instanceof HttpException) {
      statusCode = exception.getStatus();
      const payload = exception.getResponse();
      if (typeof payload === 'string') {
        message = payload;
      } else if (payload && typeof payload === 'object') {
        const body = payload as Record<string, unknown>;
        if (Array.isArray(body.message)) {
          message = 'Validation failed';
          errors = body.message;
        } else if (typeof body.message === 'string') {
          message = body.message;
        } else {
          message = exception.message;
        }
        if (body.errors) {
          errors = body.errors;
        }
      }
    } else if (
      exception &&
      typeof exception === 'object' &&
      (exception as { code?: number }).code === 11000
    ) {
      statusCode = HttpStatus.CONFLICT;
      message = 'Duplicate key';
    }

    const path = String(req?.originalUrl || '');
    if (statusCode >= 500 && !path.startsWith('/api/v1/telemetry')) {
      const stack = exception instanceof Error ? exception.stack : undefined;
      void this.telemetry
        .ingest({
          kind: 'crash',
          channel: 'api',
          message,
          stack,
          url: path,
          userAgent: String(req?.headers?.['user-agent'] || ''),
        })
        .catch(() => undefined);
    }

    res.status(statusCode).json({
      success: false,
      statusCode,
      message,
      ...(errors !== undefined ? { errors } : {}),
    });
  }
}
