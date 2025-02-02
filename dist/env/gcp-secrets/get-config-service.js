import { ConfigService } from "@nestjs/config";
import { fetchGCPSecrets } from "./fetch-secrets.js";
export default async function getConfigService() {
    const config = new ConfigService();
    // If loading from local we dont get any extra env variables
    if (config.get('SECRET_SOURCE') === 'LOCAL') {
        return {};
    }
    const secrets = await fetchGCPSecrets();
    // TODO: validate secrets
    return {
        ...secrets
    };
}

//# sourceMappingURL=get-config-service.js.map