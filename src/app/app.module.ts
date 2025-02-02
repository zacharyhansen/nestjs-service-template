import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TRPCModule } from 'nestjs-trpc';
import superjson from 'superjson';

import { AppRouter } from './app.router';

import { ViewRouter } from '~/view/view.router';
import { ViewModule } from '~/view/view.module';
import { DatabaseModule } from '~/database/database.module';
import getConfigService from '~/env/gcp-secrets/get-config-service';
import { QueryModule } from '~/query/query.module';
import { QueryRouter } from '~/query/query.router';
import { CacheModule } from '~/cache/cache.module';
import { envSchema } from '~/env/env.schema';
import { EnvModule } from '~/env/env.module';
import { SchematicModule } from '~/schematic/schematic.module';
import { DatasetRouter } from '~/dataset/dataset.router';
import { DatasetModule } from '~/dataset/dataset.module';
import { AppContext } from '~/auth/trpc/clerk-context';

@Module({
  imports: [
    TRPCModule.forRoot({
      autoSchemaFile: './@generated',
      context: AppContext,
      transformer: superjson,
    }),
    ConfigModule.forRoot({
      load: [getConfigService],
      validate: env => envSchema.parse(env),
      isGlobal: true,
    }),
    EnvModule,
    CacheModule,
    DatabaseModule,
    DatasetModule,
    QueryModule,
    SchematicModule,
    ViewModule,
  ],
  providers: [AppRouter, ViewRouter, QueryRouter, DatasetRouter, AppContext],
})
export class AppModule {}
