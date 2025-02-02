function _ts_decorate(decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for(var i = decorators.length - 1; i >= 0; i--)if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
}
import { Global, Module } from "@nestjs/common";
import { PostgresDialect } from "kysely";
import { ConfigService } from "@nestjs/config";
import { Pool } from "pg";
import { Database } from "./database.js";
import { fetchGCPSecrets } from "../env/gcp-secrets/fetch-secrets.js";
export class DatabaseModule {
}
DatabaseModule = _ts_decorate([
    Global(),
    Module({
        exports: [
            Database,
            'PoolReadOnly'
        ],
        providers: [
            {
                inject: [
                    ConfigService
                ],
                provide: Database,
                useFactory: async (configService)=>{
                    console.log({
                        SECRET_SOURCE: configService.get('SECRET_SOURCE')
                    });
                    if (configService.get('SECRET_SOURCE') === 'LOCAL' || !configService.get('SECRET_SOURCE')) {
                        return new Database({
                            dialect: new PostgresDialect({
                                pool: new Pool({
                                    database: process.env.DATABASE_NAME,
                                    host: process.env.DATABASE_HOST,
                                    password: process.env.DATABASE_PASSWORD,
                                    port: Number.parseInt(process.env.DATABASE_PORT.toString()),
                                    user: process.env.DATABASE_USER
                                })
                            })
                        });
                    }
                    const secrets = await fetchGCPSecrets();
                    return new Database({
                        dialect: new PostgresDialect({
                            pool: new Pool({
                                database: secrets.DATABASE_NAME,
                                host: secrets.DATABASE_HOST,
                                password: secrets.DATABASE_PASSWORD,
                                port: Number.parseInt(secrets.DATABASE_PORT.toString()),
                                user: secrets.DATABASE_USER
                            })
                        })
                    });
                }
            },
            {
                inject: [
                    ConfigService
                ],
                provide: 'PoolReadOnly',
                useFactory: async (configService)=>{
                    console.log({
                        SECRET_SOURCE: configService.get('SECRET_SOURCE')
                    });
                    if (configService.get('SECRET_SOURCE') === 'LOCAL' || !configService.get('SECRET_SOURCE')) {
                        return new Pool({
                            database: process.env.DATABASE_NAME,
                            host: process.env.DATABASE_HOST,
                            password: process.env.DATABASE_PASSWORD,
                            port: Number.parseInt(process.env.DATABASE_PORT.toString()),
                            user: process.env.DATABASE_USER
                        });
                    }
                    const secrets = await fetchGCPSecrets();
                    return new Pool({
                        database: secrets.DATABASE_NAME,
                        host: secrets.DATABASE_HOST,
                        password: secrets.DATABASE_PASSWORD,
                        port: Number.parseInt(secrets.DATABASE_PORT.toString()),
                        user: secrets.DATABASE_USER
                    });
                }
            }
        ]
    })
], DatabaseModule);

//# sourceMappingURL=database.module.js.map