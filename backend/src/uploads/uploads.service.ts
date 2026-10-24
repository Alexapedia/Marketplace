import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { diskStorage } from 'multer';
import { existsSync, mkdirSync } from 'fs';
import { join } from 'path';
import { randomUUID } from 'crypto';
import {
  ALLOWED_UPLOAD_MIMES,
  MAX_UPLOAD_BYTES,
  MIME_EXTENSIONS,
} from '../common/constants';
import { uploadPath } from '../common/utils/upload-url';

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
    return uploadPath(filename);
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
        // The extension comes from the validated MIME type, so a client cannot
        // store e.g. an .html or .js file that the server would then execute.
        cb(null, `${randomUUID()}${MIME_EXTENSIONS[file.mimetype] ?? '.bin'}`);
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
