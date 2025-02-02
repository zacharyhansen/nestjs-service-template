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
export class AppRouter {
    greeting(name) {
        return {
            message: `Hello ${name}!`
        };
    }
}
_ts_decorate([
    Query({
        input: z.object({
            name: z.string()
        }),
        output: z.object({
            message: z.string()
        })
    }),
    _ts_param(0, Input('name')),
    _ts_metadata("design:type", Function),
    _ts_metadata("design:paramtypes", [
        String
    ]),
    _ts_metadata("design:returntype", void 0)
], AppRouter.prototype, "greeting", null);
AppRouter = _ts_decorate([
    Router({
        alias: 'app'
    })
], AppRouter);

//# sourceMappingURL=app.router.js.map