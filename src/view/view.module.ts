import { Module } from '@nestjs/common';

import { ViewService } from './view.service';

import { DatabaseModule } from '~/database/database.module';
import { QueryModule } from '~/query/query.module';
import { SchematicModule } from '~/schematic/schematic.module';

@Module({
  exports: [ViewService],
  imports: [DatabaseModule, QueryModule, SchematicModule],
  providers: [ViewService],
})
export class ViewModule {}
