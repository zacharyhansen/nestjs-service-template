import { Logger } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

import { AppModule } from '~/app';
import { EnvService } from '~/env/env.service';

async function bootstrap() {
  const logger = new Logger('EntryPoint');

  const app = await NestFactory.create(AppModule, {
    cors: true,
  });

  const envService = app.get(EnvService);

  app.enableCors({
    credentials: true,
    origin: [envService.get('CLIENT_ORIGIN')],
  });

  const config = new DocumentBuilder()
    .setTitle('Tracker')
    .setDescription('Api Docs')
    .setVersion('1.0')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('docs', app, document);

  await app.listen(envService.get('PORT'));
  logger.log(`Server running on ${envService.get('PORT')} `);
}

bootstrap();
