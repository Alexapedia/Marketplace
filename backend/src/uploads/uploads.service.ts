import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { diskStorage } from 'multer';
import { existsSync, mkdirSync } from 'fs';
import { extname, join } from 'path';
import { randomUUID } from 'crypto';
import { ALLOWED_UPLOAD_MIMES, MAX_UPLOAD_BYTES } from '../common/constants';

@Injectable()
export class UploadsService {
  readonly dest: string;

  constructor(private readonly config: ConfigService) {
    this.dest = join(
      process.cwd(),
      this.config.get<string>('UPLOAD_DIR') || './uploads',
    );
    if (!existsSync(this.dest)) {
      mkdirSync(this.dest, { recursive: true });
    }
  }

  toUrl(filename: string) {
    const publicBase = (
      this.config.get<string>('PUBLIC_URL') ||
      `http://localhost:${this.config.get('PORT') || 3000}`
    ).replace(/\/$/, '');
    return `${publicBase}/uploads/${filename}`;
  }
}

export function multerOptions(dest: string) {
  if (!existsSync(dest)) {
    mkdirSync(dest, { recursive: true });
  }
  return {
    storage: diskStorage({
      destination: dest,
      filename: (
        _req: unknown,
        file: Express.Multer.File,
        cb: (error: Error | null, filename: string) => void,
      ) => {
        cb(null, `${randomUUID()}${extname(file.originalname).toLowerCase()}`);
      },
    }),
    limits: { fileSize: MAX_UPLOAD_BYTES },
    fileFilter: (
      _req: unknown,
      file: Express.Multer.File,
      cb: (error: Error | null, accept: boolean) => void,
    ) => {
      if (!ALLOWED_UPLOAD_MIMES.includes(file.mimetype)) {
        cb(
          new HttpException('Unsupported file type', HttpStatus.BAD_REQUEST),
          false,
        );
        return;
      }
      cb(null, true);
    },
  };
}
