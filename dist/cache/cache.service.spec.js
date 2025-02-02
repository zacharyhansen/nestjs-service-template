import { Test } from "@nestjs/testing";
import { CacheService } from "./cache.service.js";
describe('CacheService', ()=>{
    let service;
    beforeEach(async ()=>{
        const module = await Test.createTestingModule({
            providers: [
                CacheService
            ]
        }).compile();
        service = module.get(CacheService);
    });
    it('should be defined', ()=>{
        expect(service).toBeDefined();
    });
});

//# sourceMappingURL=cache.service.spec.js.map