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
import { Controller, Get, Query, Req, Res } from "@nestjs/common";
import { Database } from "../database/database.js";
import { Public } from "./decorators/public.decorator.js";
export class AuthController {
    constructor(database){
        this.database = database;
    }
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    testPublic(query) {
        return this.database.selectFrom(`${query.schema}.role`).selectAll().execute();
    }
    testPrivate(request, response) {
        return response.send('OK');
    }
}
_ts_decorate([
    Get('test-public'),
    Public(),
    _ts_param(0, Query()),
    _ts_metadata("design:type", Function),
    _ts_metadata("design:paramtypes", [
        Object
    ]),
    _ts_metadata("design:returntype", typeof Promise === "undefined" ? Object : Promise)
], AuthController.prototype, "testPublic", null);
_ts_decorate([
    Get('test-private'),
    _ts_param(0, Req()),
    _ts_param(1, Res()),
    _ts_metadata("design:type", Function),
    _ts_metadata("design:paramtypes", [
        typeof Request === "undefined" ? Object : Request,
        typeof Response === "undefined" ? Object : Response
    ]),
    _ts_metadata("design:returntype", void 0)
], AuthController.prototype, "testPrivate", null);
AuthController = _ts_decorate([
    Controller('auth'),
    _ts_metadata("design:type", Function),
    _ts_metadata("design:paramtypes", [
        typeof Database === "undefined" ? Object : Database
    ])
], AuthController);

//# sourceMappingURL=auth.controller.js.map