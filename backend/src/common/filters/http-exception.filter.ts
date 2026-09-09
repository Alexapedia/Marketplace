import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const res = host.switchToHttp().getResponse<Response>();

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

    res.status(statusCode).json({
      success: false,
      statusCode,
      message,
      ...(errors !== undefined ? { errors } : {}),
    });
  }
}
