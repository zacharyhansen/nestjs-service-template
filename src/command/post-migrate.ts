import { NestFactory } from '@nestjs/core';

import { AppModule } from '../app';
import { ViewService } from '../view/view.service';

import type { TDatabase } from '~/database/database';

const CLIENT_SCHEMAS: TDatabase['configuration.view']['schema'][] = [
  'foundation',
];

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const viewMetadataService = app.get(ViewService);

  try {
    await viewMetadataService.syncViews({ schemas: CLIENT_SCHEMAS });
    console.log('View metadata sync completed successfully');
  } catch (error) {
    console.error('Error during view metadata sync:', error);
    throw error;
  } finally {
    await app.close();
  }
}

bootstrap().catch((error: unknown) => {
  console.error('Migration failed:', error);
  // eslint-disable-next-line unicorn/no-process-exit
  process.exit(1);
});
