function _ts_decorate(decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for(var i = decorators.length - 1; i >= 0; i--)if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
}
import { Injectable, Logger } from "@nestjs/common";
import { clerkClient } from "@clerk/clerk-sdk-node";
import { TRPCError } from "@trpc/server";
export class AppContext {
    async create({ req, res }) {
        const token = req.headers.authorization?.split(' ')[1];
        if (!token) {
            throw new TRPCError({
                code: 'UNAUTHORIZED',
                message: 'Missing token'
            });
        }
        try {
            const clerkclaims = await clerkClient.verifyToken(token);
            if (!token) {
                throw new TRPCError({
                    code: 'UNAUTHORIZED',
                    message: 'Missing token'
                });
            }
            if (!clerkclaims.environment) {
                throw new TRPCError({
                    code: 'UNAUTHORIZED',
                    message: 'Missing environment'
                });
            }
            return {
                clerkclaims
            };
        } catch (error) {
            this.logger.error(`Invalid clerk token: ${error}`);
            throw new TRPCError({
                code: 'UNAUTHORIZED',
                message: 'Invalid token'
            });
        }
    }
    constructor(){
        this.logger = new Logger(AppContext.name);
    }
}
AppContext = _ts_decorate([
    Injectable()
], AppContext);

//# sourceMappingURL=clerk-context.js.map