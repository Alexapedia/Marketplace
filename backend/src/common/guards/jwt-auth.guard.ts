import { ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from '@nestjs/passport';
import { Observable, from, isObservable, of } from 'rxjs';
import { catchError, map } from 'rxjs/operators';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private readonly reflector: Reflector) {
    super();
  }

  canActivate(context: ExecutionContext) {
    if (context.getType() !== 'http') {
      return true;
    }
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (context.getType() === 'http') {
      const path = context.switchToHttp().getRequest().originalUrl?.split('?')[0] || '';
      if (path.startsWith('/api/v1/platform') || path.startsWith('/api/v1/telemetry')) {
        return true;
      }
    }
    const result = super.canActivate(context);
    if (!isPublic) {
      return result;
    }
    const stream: Observable<boolean> = isObservable(result)
      ? (result as Observable<boolean>)
      : from(Promise.resolve(result as boolean | Promise<boolean>));
    return stream.pipe(
      map(() => true),
      catchError(() => of(true)),
    );
  }
}
