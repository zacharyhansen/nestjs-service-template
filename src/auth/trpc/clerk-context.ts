import { Injectable, Logger } from '@nestjs/common';
import { type ContextOptions, type TRPCContext } from 'nestjs-trpc';
import { clerkClient } from '@clerk/clerk-sdk-node';
import { TRPCError } from '@trpc/server';

@Injectable()
export class AppContext implements TRPCContext {
  private readonly logger = new Logger(AppContext.name);

  async create({ req, res }: ContextOptions): Promise<Record<string, unknown>> {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      throw new TRPCError({ code: 'UNAUTHORIZED', message: 'Missing token' });
    }
    try {
      const clerkclaims = await clerkClient.verifyToken(token);
      if (!token) {
        throw new TRPCError({ code: 'UNAUTHORIZED', message: 'Missing token' });
      }

      if (!clerkclaims.environment) {
        throw new TRPCError({
          code: 'UNAUTHORIZED',
          message: 'Missing environment',
        });
      }

      return {
        clerkclaims,
      };
    } catch (error) {
      this.logger.error(`Invalid clerk token: ${error}`);
      throw new TRPCError({ code: 'UNAUTHORIZED', message: 'Invalid token' });
    }
  }
}
