import { Controller, Get } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { Public } from '../common/decorators/public.decorator';
import { HomeService } from './home.service';

@SkipThrottle()
@Controller('home')
export class HomeController {
  constructor(private readonly home: HomeService) {}

  @Public()
  @Get()
  feed() {
    return this.home.feed();
  }
}
