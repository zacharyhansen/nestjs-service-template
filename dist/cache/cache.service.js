function _ts_decorate(decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for(var i = decorators.length - 1; i >= 0; i--)if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
}
function _ts_metadata(k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
}
function _ts_param(paramIndex, decorator) {
    return function(target, key) {
        decorator(target, key, paramIndex);
    };
}
import { Cache, CACHE_MANAGER } from "@nestjs/cache-manager";
import { Inject, Injectable } from "@nestjs/common";
export class CacheService {
    constructor(cacheManager){
        this.cacheManager = cacheManager;
    }
    async get(key) {
        return this.cacheManager.get(key);
    }
    async set(key, value, ttl) {
        return this.cacheManager.set(key, value, ttl);
    }
    del(key) {
        return this.cacheManager.del(key);
    }
    clear() {
        return this.cacheManager.clear();
    }
}
CacheService = _ts_decorate([
    Injectable(),
    _ts_param(0, Inject(CACHE_MANAGER)),
    _ts_metadata("design:type", Function),
    _ts_metadata("design:paramtypes", [
        typeof Cache === "undefined" ? Object : Cache
    ])
], CacheService);

//# sourceMappingURL=cache.service.js.map