import { Module } from '@nestjs/common';
import { AdsAdminController } from './ads-admin.controller';
import { AdsController } from './ads.controller';
import { AdsService } from './ads.service';

@Module({
  controllers: [AdsController, AdsAdminController],
  providers: [AdsService],
  exports: [AdsService],
})
export class AdsModule {}
