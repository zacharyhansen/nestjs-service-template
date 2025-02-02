function _ts_decorate(decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for(var i = decorators.length - 1; i >= 0; i--)if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
}
function _ts_metadata(k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
}
import { Injectable, Logger } from "@nestjs/common";
import { isM2MRelationCardinality } from "./schematic.types.js";
import { EnvService } from "../env/env.service.js";
const SchematicIsNotRoleViewMatch = /^(?!.*__).*$/;
export class SchematicService {
    constructor(envService){
        this.envService = envService;
        this.logger = new Logger(SchematicService.name);
    }
    async schemaCache() {
        // @ts-expect-error typeing for this
        const schemaCache = await fetch(`${this.envService.get('POSTGREST_ORIGIN')}/schema_cache`, {
            headers: {
                'Accept-Profile': 'foundation'
            }
        }).then((response)=>response.json());
        return schemaCache;
    }
    async rootSchematic({ schema }) {
        return this.schematic({
            schema,
            tableMatcher: (tableName)=>SchematicService.isSchematicView(tableName)
        });
    }
    async roleSchematic({ schema, roleName, views }) {
        return this.schematic({
            schema,
            tableMatcher: (tableName)=>SchematicService.isSchematicRoleView(tableName, roleName),
            views
        });
    }
    /**
   * Gets a relevant schematic
   * @param schema schema to build a schematic for
   * @param tableMatcher Matched that determines if tables or relationships are relevant to the schematic
   * @param views A set of views to only do the schematic for (to filter the schematic for)
   */ async schematic({ schema, tableMatcher, views }) {
        const schemaCache = await this.schemaCache();
        const schemaCacheMap = new Map(schemaCache.dbTables.map((table)=>[
                table[0].qiName,
                table[1]
            ]));
        const tableFilter = (tableName, schema)=>views ? tableMatcher(tableName) && views.includes(tableName) : tableMatcher(tableName);
        return {
            schemaCacheMap,
            schematicViews: schemaCache.dbTables.filter((table)=>tableFilter(table[0].qiName, table[0].qiSchema)),
            schematicLinks: schemaCache.dbRelationships// remove links for anthing but those product or custom views we want to expose
            .filter((link)=>tableFilter(link[0][0].qiName, link[0][1])).flatMap((link)=>{
                // filter links to only those product or custom views we want to expose
                const applicableLinks = link[1].filter((linkItem)=>{
                    return isM2MRelationCardinality(linkItem.relCardinality) ? tableFilter(linkItem.relCardinality.contents.junTable.qiName, linkItem.relCardinality.contents.junTable.qiSchema) && tableFilter(linkItem.relForeignTable.qiName, linkItem.relForeignTable.qiSchema) : tableFilter(linkItem.relForeignTable.qiName, linkItem.relForeignTable.qiSchema);
                });
                return applicableLinks.map((linkItem)=>{
                    if (isM2MRelationCardinality(linkItem.relCardinality)) {
                        return {
                            type: linkItem.relCardinality.tag,
                            pgt_columns: linkItem.relCardinality.contents.junColsSource[0],
                            pgt_columns_2: linkItem.relCardinality.contents.junColsTarget[0],
                            constraint: linkItem.relCardinality.contents.junConstraint1,
                            constraint_2: linkItem.relCardinality.contents.junConstraint2,
                            source_view_name: linkItem.relTable.qiName,
                            source_column_name: linkItem.relCardinality.contents.junColsSource[0][0],
                            target_view_name: linkItem.relForeignTable.qiName,
                            target_column_name: linkItem.relCardinality.contents.junColsTarget[0][0],
                            junction_view_name: linkItem.relCardinality.contents.junTable.qiName,
                            junction_source_column_name: linkItem.relCardinality.contents.junColsSource[0][1],
                            junction_target_column_name: linkItem.relCardinality.contents.junColsTarget[0][1],
                            pgt_is_self: linkItem.relIsSelf,
                            display_name: linkItem.relCardinality.tag,
                            schema
                        };
                    }
                    return {
                        type: linkItem.relCardinality.tag,
                        pgt_columns: linkItem.relCardinality.relColumns[0],
                        constraint: linkItem.relCardinality.relCons,
                        source_view_name: linkItem.relTable.qiName,
                        source_column_name: linkItem.relCardinality.relColumns[0][0],
                        target_view_name: linkItem.relForeignTable.qiName,
                        target_column_name: linkItem.relCardinality.relColumns[0][1],
                        pgt_is_self: linkItem.relIsSelf,
                        display_name: linkItem.relCardinality.tag,
                        schema
                    };
                });
            })
        };
    }
    static isSchematicView(viewName) {
        return (viewName.startsWith('_p_') || viewName.startsWith('_c_')) && SchematicIsNotRoleViewMatch.test(viewName);
    }
    static isSchematicRoleView(viewName, role) {
        const roleRegex = new RegExp(`__${role}$`);
        return (viewName.startsWith('_p_') || viewName.startsWith('_c_')) && roleRegex.test(viewName);
    }
    static viewType(viewName) {
        return viewName.startsWith('_p_') ? 'product' : 'custom';
    }
    static hasUnderlyingTable(viewName) {
        return viewName.startsWith('_p_');
    }
    /** Deterministic name of the view based on the role and source view */ static roleViewName({ rootViewName, role }) {
        return `${rootViewName}__${role.name}`;
    }
    /** Deterministic name of the root view that role vq_view's are created from */ static rootViewName({ tableName }) {
        return `_p_${tableName}`;
    }
    static rootViewFromRoleView({ rootView }) {
        return rootView.replace(/__.*/, '');
    }
}
SchematicService = _ts_decorate([
    Injectable(),
    _ts_metadata("design:type", Function),
    _ts_metadata("design:paramtypes", [
        typeof EnvService === "undefined" ? Object : EnvService
    ])
], SchematicService);

//# sourceMappingURL=schematic.service.js.map