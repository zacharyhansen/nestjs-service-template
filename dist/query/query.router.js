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
import { Input, Query, Router } from "nestjs-trpc";
import { z } from "zod";
import { Inject } from "@nestjs/common";
import { sql } from "kysely";
import { QueryService } from "./query.service.js";
import { Database } from "../database/database.js";
export class QueryRouter {
    constructor(queryService, database){
        this.queryService = queryService;
        this.database = database;
    }
    async execute(query) {
        return this.queryService.execute({
            query: sql.raw(query).compile(this.database)
        });
    }
}
_ts_decorate([
    Query({
        input: z.object({
            query: z.string()
        }),
        output: z.any()
    }),
    _ts_param(0, Input('query')),
    _ts_metadata("design:type", Function),
    _ts_metadata("design:paramtypes", [
        String
    ]),
    _ts_metadata("design:returntype", Promise)
], QueryRouter.prototype, "execute", null);
QueryRouter = _ts_decorate([
    Router({
        alias: 'query'
    }),
    _ts_param(0, Inject(QueryService)),
    _ts_param(1, Inject(Database)),
    _ts_metadata("design:type", Function),
    _ts_metadata("design:paramtypes", [
        typeof QueryService === "undefined" ? Object : QueryService,
        typeof Database === "undefined" ? Object : Database
    ])
], QueryRouter);

//# sourceMappingURL=query.router.js.map