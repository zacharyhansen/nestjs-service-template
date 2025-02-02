import { Test } from "@nestjs/testing";
import { DatasetService } from "./dataset.service.js";
describe('DatasetService', ()=>{
    let service;
    beforeEach(async ()=>{
        const module = await Test.createTestingModule({
            providers: [
                DatasetService
            ]
        }).compile();
        service = module.get(DatasetService);
    });
    it('should be defined', ()=>{
        expect(service).toBeDefined();
    });
});

//# sourceMappingURL=dataset.service.spec.js.map