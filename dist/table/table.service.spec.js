import { Test } from "@nestjs/testing";
import { TableService } from "./table.service.js";
describe('TableService', ()=>{
    let service;
    beforeEach(async ()=>{
        const module = await Test.createTestingModule({
            providers: [
                TableService
            ]
        }).compile();
        service = module.get(TableService);
    });
    it('should be defined', ()=>{
        expect(service).toBeDefined();
    });
});

//# sourceMappingURL=table.service.spec.js.map