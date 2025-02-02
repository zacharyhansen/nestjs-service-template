function _ts_decorate(decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for(var i = decorators.length - 1; i >= 0; i--)if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
}
import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { TRPCModule } from "nestjs-trpc";
import superjson from "superjson";
import { AppRouter } from "./app.router.js";
import { ViewRouter } from "../view/view.router.js";
import { ViewModule } from "../view/view.module.js";
import { DatabaseModule } from "../database/database.module.js";
import getConfigService from "../env/gcp-secrets/get-config-service.js";
import { QueryModule } from "../query/query.module.js";
import { QueryRouter } from "../query/query.router.js";
import { CacheModule } from "../cache/cache.module.js";
import { envSchema } from "../env/env.schema.js";
import { EnvModule } from "../env/env.module.js";
import { SchematicModule } from "../schematic/schematic.module.js";
import { DatasetRouter } from "../dataset/dataset.router.js";
import { DatasetModule } from "../dataset/dataset.module.js";
import { AppContext } from "../auth/trpc/clerk-context.js";
export class AppModule {
}
AppModule = _ts_decorate([
    Module({
        imports: [
            TRPCModule.forRoot({
                autoSchemaFile: './@generated',
                context: AppContext,
                transformer: superjson
            }),
            ConfigModule.forRoot({
                load: [
                    getConfigService
                ],
                validate: (env)=>envSchema.parse(env),
                isGlobal: true
            }),
            EnvModule,
            CacheModule,
            DatabaseModule,
            DatasetModule,
            QueryModule,
            SchematicModule,
            ViewModule
        ],
        providers: [
            AppRouter,
            ViewRouter,
            QueryRouter,
            DatasetRouter,
            AppContext
        ]
    })
], AppModule);

//# sourceMappingURL=app.module.js.map