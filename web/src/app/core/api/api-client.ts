import { HttpClient, HttpErrorResponse, HttpParams } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { catchError, map, Observable, throwError } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiEnvelope, PageMeta } from '../models/models';

export interface QueryParams {
  [key: string]: string | number | boolean | undefined | null;
}

export interface ApiResult<T> {
  data: T;
  meta?: PageMeta;
  message?: string;
}

export class ApiError extends Error {
  constructor(
    message: string,
    readonly status = 0,
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

@Injectable({ providedIn: 'root' })
export class ApiClient {
  private readonly http = inject(HttpClient);
  private readonly base = environment.apiUrl;

  get<T>(path: string, params?: QueryParams): Observable<ApiResult<T>> {
    return this.http
      .get<ApiEnvelope<T>>(`${this.base}${path}`, { params: this.toParams(params) })
      .pipe(map((res) => this.unwrap<T>(res)), catchError((err) => this.handle(err)));
  }

  post<T>(path: string, body: unknown = {}): Observable<ApiResult<T>> {
    return this.http
      .post<ApiEnvelope<T>>(`${this.base}${path}`, body)
      .pipe(map((res) => this.unwrap<T>(res)), catchError((err) => this.handle(err)));
  }

  postForm<T>(path: string, body: FormData): Observable<ApiResult<T>> {
    return this.http
      .post<ApiEnvelope<T>>(`${this.base}${path}`, body)
      .pipe(map((res) => this.unwrap<T>(res)), catchError((err) => this.handle(err)));
  }

  patch<T>(path: string, body: unknown = {}): Observable<ApiResult<T>> {
    return this.http
      .patch<ApiEnvelope<T>>(`${this.base}${path}`, body)
      .pipe(map((res) => this.unwrap<T>(res)), catchError((err) => this.handle(err)));
  }

  delete<T>(path: string): Observable<ApiResult<T>> {
    return this.http
      .delete<ApiEnvelope<T>>(`${this.base}${path}`)
      .pipe(map((res) => this.unwrap<T>(res)), catchError((err) => this.handle(err)));
  }

  upload<T = { url: string }>(file: File, path = '/uploads'): Observable<ApiResult<T>> {
    const body = new FormData();
    body.append('file', file);
    return this.postForm<T>(path, body);
  }

  private toParams(params?: QueryParams): HttpParams {
    let httpParams = new HttpParams();
    if (!params) return httpParams;
    for (const key of Object.keys(params)) {
      const value = params[key];
      if (value === undefined || value === null || value === '') continue;
      httpParams = httpParams.set(key, String(value));
    }
    return httpParams;
  }

  private unwrap<T>(res: ApiEnvelope<T> | T): ApiResult<T> {
    if (res && typeof res === 'object' && 'success' in res && 'data' in res) {
      const envelope = res as ApiEnvelope<T>;
      return { data: envelope.data, meta: envelope.meta, message: envelope.message };
    }
    return { data: res as T };
  }

  private handle(err: HttpErrorResponse): Observable<never> {
    if (err.status === 0 || err.status === 502 || err.status === 503 || err.status === 504) {
      return throwError(
        () =>
          new ApiError('Cannot reach the API. Run the backend on http://localhost:3000', err.status),
      );
    }
    const body = err.error as ApiEnvelope<unknown> | undefined;
    const message =
      body?.message ||
      (typeof err.error === 'string' ? err.error : undefined) ||
      err.message ||
      'Request failed';
    return throwError(() => new ApiError(String(message), err.status));
  }
}
