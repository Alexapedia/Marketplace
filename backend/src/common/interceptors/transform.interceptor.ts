import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable, map } from 'rxjs';

@Injectable()
export class TransformInterceptor implements NestInterceptor {
  intercept(_context: ExecutionContext, next: CallHandler): Observable<unknown> {
    return next.handle().pipe(
      map((value) => {
        if (value && typeof value === 'object' && 'success' in value) {
          return value;
        }
        if (
          value &&
          typeof value === 'object' &&
          'data' in value &&
          ('meta' in value || 'message' in value)
        ) {
          const { data, meta, message } = value as {
            data: unknown;
            meta?: unknown;
            message?: string;
          };
          return {
            success: true,
            data,
            ...(message ? { message } : {}),
            ...(meta ? { meta } : {}),
          };
        }
        return { success: true, data: value ?? null };
      }),
    );
  }
}
