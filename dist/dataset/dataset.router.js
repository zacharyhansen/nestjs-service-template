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
import { Input, Mutation, Query, Router, Ctx } from "nestjs-trpc";
import { z } from "zod";
import { Inject } from "@nestjs/common";
import { DatasetOutputSchema, RootDataViewInputSchema } from "./dataset.types.js";
import { DatasetService } from "./dataset.service.js";
export class DatasetRouter {
    constructor(datasetService){
        this.datasetService = datasetService;
    }
    dataset(datasetId) {
        return this.datasetService.dataset({
            datasetId
        });
    }
    async insertRootDataview(context, rootDataview) {
        return this.datasetService.insertRootDataview({
            rootDataview,
            userId: context.clerkclaims.sub,
            schema: context.clerkclaims.environment
        });
    }
}
_ts_decorate([
    Query({
        input: z.object({
            datasetId: z.string()
        }),
        output: DatasetOutputSchema
    }),
    _ts_param(0, Input('datasetId')),
    _ts_metadata("design:type", Function),
    _ts_metadata("design:paramtypes", [
        String
    ]),
    _ts_metadata("design:returntype", void 0)
], DatasetRouter.prototype, "dataset", null);
_ts_decorate([
    Mutation({
        input: z.object({
            rootDataview: RootDataViewInputSchema
        }),
        output: DatasetOutputSchema
    }),
    _ts_param(0, Ctx()),
    _ts_param(1, Input('rootDataview')),
    _ts_metadata("design:type", Function),
    _ts_metadata("design:paramtypes", [
        typeof AppTrpcContext === "undefined" ? Object : AppTrpcContext,
        typeof RootDataViewInput === "undefined" ? Object : RootDataViewInput
    ]),
    _ts_metadata("design:returntype", Promise)
], DatasetRouter.prototype, "insertRootDataview", null);
DatasetRouter = _ts_decorate([
    Router({
        alias: 'dataset'
    }),
    _ts_param(0, Inject(DatasetService)),
    _ts_metadata("design:type", Function),
    _ts_metadata("design:paramtypes", [
        typeof DatasetService === "undefined" ? Object : DatasetService
    ])
], DatasetRouter);

//# sourceMappingURL=dataset.router.js.map