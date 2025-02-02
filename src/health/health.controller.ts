import { Controller, Get, Req, Res } from '@nestjs/common';
import { type Request, type Response } from 'express';

import { Public } from '../auth/decorators/public.decorator';

@Controller('health')
export class HealthController {
  @Get()
  @Public()
  health(@Req() _request: Request, @Res() response: Response) {
    return response.send('OK');
  }
}
