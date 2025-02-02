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
import { Input, Mutation, Query, Router } from "nestjs-trpc";
import { z } from "zod";
import { Inject } from "@nestjs/common";
import { ViewService } from "./view.service.js";
import { ViewDefinition } from "./view.types.js";
export class ViewRouter {
    constructor(viewService){
        this.viewService = viewService;
    }
    viewDefinition(id, name) {
        return this.viewService.viewDefinition({
            viewName: name,
            id
        });
    }
    async mutateViewsForRoles(rootViewName, columnEnabledRecords) {
        await this.viewService.mutateRoleViews({
            columnEnabledRecords,
            rootViewName,
            schema: 'foundation'
        });
        return 'ok';
    }
}
_ts_decorate([
    Query({
        input: z.object({
            name: z.string(),
            id: z.string()
        }),
        output: ViewDefinition
    }),
    _ts_param(0, Input('id')),
    _ts_param(1, Input('name')),
    _ts_metadata("design:type", Function),
    _ts_metadata("design:paramtypes", [
        String,
        String
    ]),
    _ts_metadata("design:returntype", void 0)
], ViewRouter.prototype, "viewDefinition", null);
_ts_decorate([
    Mutation({
        input: z.object({
            rootViewName: z.string(),
            columnEnabledRecords: z.object({
                name: z.string()
            }).catchall(z.any()).array()
        }),
        output: z.literal('ok')
    }),
    _ts_param(0, Input('rootViewName')),
    _ts_param(1, Input('columnEnabledRecords')),
    _ts_metadata("design:type", Function),
    _ts_metadata("design:paramtypes", [
        Object,
        Array
    ]),
    _ts_metadata("design:returntype", Promise)
], ViewRouter.prototype, "mutateViewsForRoles", null);
ViewRouter = _ts_decorate([
    Router({
        alias: 'view'
    }),
    _ts_param(0, Inject(ViewService)),
    _ts_metadata("design:type", Function),
    _ts_metadata("design:paramtypes", [
        typeof ViewService === "undefined" ? Object : ViewService
    ])
], ViewRouter);

//# sourceMappingURL=view.router.js.map