import {
  BadRequestException,
  Controller,
  Post,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiBody, ApiConsumes, ApiTags } from '@nestjs/swagger';
import { PlatformJwtGuard } from './platform-jwt.guard';
import { UploadsService } from '../uploads/uploads.service';

/** Store logos and other branding images uploaded by the platform holder. */
@ApiTags('platform')
@ApiBearerAuth()
@UseGuards(PlatformJwtGuard)
@Controller('platform/uploads')
export class PlatformUploadsController {
  constructor(private readonly uploads: UploadsService) {}

  @Post()
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: { file: { type: 'string', format: 'binary' } },
    },
  })
  @UseInterceptors(FileInterceptor('file'))
  upload(@UploadedFile() file?: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('file is required');
    }
    if (!file.mimetype.startsWith('image/')) {
      throw new BadRequestException('Only images can be used for branding');
    }
    return { url: this.uploads.toUrl(file.filename) };
  }
}
