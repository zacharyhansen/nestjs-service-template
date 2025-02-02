import { Test } from "@nestjs/testing";
import { SchematicService } from "./schematic.service.js";
describe('SchematicService', ()=>{
    let service;
    beforeEach(async ()=>{
        const module = await Test.createTestingModule({
            providers: [
                SchematicService
            ]
        }).compile();
        service = module.get(SchematicService);
    });
    it('should be defined', ()=>{
        expect(service).toBeDefined();
    });
});

//# sourceMappingURL=schematic.service.spec.js.map