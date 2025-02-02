function _ts_decorate(decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for(var i = decorators.length - 1; i >= 0; i--)if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
}
import { Module } from "@nestjs/common";
import { ViewService } from "./view.service.js";
import { DatabaseModule } from "../database/database.module.js";
import { QueryModule } from "../query/query.module.js";
import { SchematicModule } from "../schematic/schematic.module.js";
export class ViewModule {
}
ViewModule = _ts_decorate([
    Module({
        exports: [
            ViewService
        ],
        imports: [
            DatabaseModule,
            QueryModule,
            SchematicModule
        ],
        providers: [
            ViewService
        ]
    })
], ViewModule);

//# sourceMappingURL=view.module.js.map