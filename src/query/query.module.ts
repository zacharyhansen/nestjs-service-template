import { Module } from '@nestjs/common';

import { QueryService } from './query.service';

import { DatabaseModule } from '~/database/database.module';

@Module({
  exports: [QueryService],
  imports: [DatabaseModule],
  providers: [QueryService],
})
export class QueryModule {}
