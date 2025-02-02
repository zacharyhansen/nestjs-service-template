import { Test } from "@nestjs/testing";
import { DealLifecycleService } from "./deal-lifecycle.service.js";
describe('DealLifecycleService', ()=>{
    let service;
    beforeEach(async ()=>{
        const module = await Test.createTestingModule({
            providers: [
                DealLifecycleService
            ]
        }).compile();
        service = module.get(DealLifecycleService);
    });
    it('should be defined', ()=>{
        expect(service).toBeDefined();
    });
});

//# sourceMappingURL=deal-lifecycle.service.spec.js.map