import { Input, Mutation, Query, Router, Ctx } from 'nestjs-trpc';
import { z } from 'zod';
import { Inject } from '@nestjs/common';

import {
  DatasetOutputSchema,
  RootDataViewInputSchema,
  type RootDataViewInput,
} from './dataset.types';
import { DatasetService } from './dataset.service';

import type { AppTrpcContext, ClerkClaims } from '~/auth/types';
import type { AppContext } from '~/auth/trpc/clerk-context';

@Router({ alias: 'dataset' })
export class DatasetRouter {
  constructor(@Inject(DatasetService) private datasetService: DatasetService) {}

  @Query({
    input: z.object({
      datasetId: z.string(),
    }),
    output: DatasetOutputSchema,
  })
  dataset(@Input('datasetId') datasetId: string) {
    return this.datasetService.dataset({ datasetId });
  }

  @Mutation({
    input: z.object({
      rootDataview: RootDataViewInputSchema,
    }),
    output: DatasetOutputSchema,
  })
  async insertRootDataview(
    @Ctx() context: AppTrpcContext,
    @Input('rootDataview') rootDataview: RootDataViewInput
  ) {
    return this.datasetService.insertRootDataview({
      rootDataview,
      userId: context.clerkclaims.sub,
      schema: context.clerkclaims.environment,
    });
  }
}
