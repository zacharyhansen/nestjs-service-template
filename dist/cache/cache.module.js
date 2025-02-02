function _ts_decorate(decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for(var i = decorators.length - 1; i >= 0; i--)if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
}
import { CacheModule as NestCacheModule } from "@nestjs/cache-manager";
import { Module } from "@nestjs/common";
import { CacheService } from "./cache.service.js";
export class CacheModule {
}
CacheModule = _ts_decorate([
    Module({
        imports: [
            NestCacheModule.register({
                isGlobal: true
            })
        ],
        providers: [
            CacheService
        ],
        exports: [
            CacheService
        ]
    })
], CacheModule);

//# sourceMappingURL=cache.module.js.map