function _ts_decorate(decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for(var i = decorators.length - 1; i >= 0; i--)if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
}
import { Injectable, Logger } from "@nestjs/common";
import { tap } from "rxjs/operators";
export class LogTimerInterceptor {
    intercept(context, next) {
        const start = Date.now(); // Capture start time
        console.log('started');
        return next.handle().pipe(tap(()=>{
            console.log('ended');
            const end = Date.now(); // Capture end time
            const duration = end - start; // Calculate duration
            this.logger.log(`Method ${context.getHandler().name} took ${duration}ms`);
        }));
    }
    constructor(){
        this.logger = new Logger(LogTimerInterceptor.name);
    }
}
LogTimerInterceptor = _ts_decorate([
    Injectable()
], LogTimerInterceptor);

//# sourceMappingURL=log.timer.interceptor.js.map