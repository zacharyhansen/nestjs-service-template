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
import { Inject, Injectable } from "@nestjs/common";
import { Database } from "../database/database.js";
export class DatasetService {
    constructor(database){
        this.database = database;
    }
    async insertRootDataview({ rootDataview, schema, userId }) {
        await this.database.transaction().execute(async (trx)=>{
            const dataview = await trx.insertInto('configuration.dataview').values({
                schema,
                constraint: 'placeholder',
                dataset_id: rootDataview.datasetId,
                role_view_name: rootDataview.role_view_name,
                created_by_id: userId
            }).returningAll().executeTakeFirstOrThrow();
            await trx.updateTable('configuration.dataset').where('id', '=', dataview.dataset_id).where('schema', '=', schema).set({
                dataview_id: dataview.id
            }).execute();
        });
        return this.dataset({
            datasetId: rootDataview.datasetId,
            schema
        });
    }
    async dataset({ datasetId, schema = 'foundation' }) {
        const [dataset, dataviews] = await Promise.all([
            this.database.selectFrom('configuration.dataset').selectAll().where('schema', '=', schema).where('id', '=', datasetId).executeTakeFirstOrThrow(),
            this.database.selectFrom('configuration.dataview').selectAll().where('schema', '=', schema).where('dataset_id', '=', datasetId).execute()
        ]);
        if (dataviews.length === 0) {
            return {
                ...dataset,
                roleViews: null,
                dataview: null
            };
        }
        const columns = await this.database.selectFrom('configuration.dataview_column').where('schema', '=', schema).where('dataview_id', 'in', dataviews.map((dataview)=>dataview.id)).selectAll().orderBy('order', 'asc').execute();
        const dataviewsWithColumns = dataviews.map((dataview)=>({
                ...dataview,
                dataview_column: columns.filter((column)=>column.dataview_id === dataview.id)
            }));
        const result = {
            ...dataset,
            dataview: DatasetService.resolveDataview({
                rootDataview: dataviewsWithColumns.find((dataview)=>dataview.id === dataset.dataview_id),
                dataviewsWithColumns
            }),
            roleViews: Array.from(new Set(dataviews.map((view)=>view.role_view_name)))
        };
        await this.generateQuery({
            datasetId: result.id,
            dataset: result
        });
        return result;
    }
    async generateQuery({ datasetId, schema = 'foundation', dataset }) {
        const ds = dataset ?? await this.dataset({
            datasetId,
            schema
        });
        if (!ds.dataview) {
            throw new Error('No root dataview exists for the dataset.');
        }
        ds.query = DatasetService.processDataviewQuery({
            dataview: ds.dataview
        });
        await this.database.updateTable('configuration.dataset').where('schema', '=', schema).where('id', '=', datasetId).set({
            query: ds.query
        }).execute();
        return ds;
    }
    static processDataviewQuery({ dataview }) {
        const columns = dataview.dataview_column?.map((column)=>column.role_column_name);
        const relations = dataview.dataview?.map((dataview)=>`${dataview.role_view_name}!${dataview.constraint}(${DatasetService.processDataviewQuery({
                dataview
            })})`);
        return [
            ...columns ?? [],
            ...relations ?? []
        ].join(`,\n`);
    }
    static resolveDataview({ rootDataview, dataviewsWithColumns }) {
        if (!rootDataview) return null;
        const queue = [
            {
                ...rootDataview
            }
        ];
        const result = queue[0];
        while(queue.length > 0){
            const currentDataview = queue.pop();
            if (!currentDataview) return result;
            currentDataview.dataview = dataviewsWithColumns.filter((dataview)=>dataview.parent_dataview_id === currentDataview.id);
            queue.push(...currentDataview.dataview);
        }
        return result;
    }
}
DatasetService = _ts_decorate([
    Injectable(),
    _ts_param(0, Inject(Database)),
    _ts_metadata("design:type", Function),
    _ts_metadata("design:paramtypes", [
        typeof Database === "undefined" ? Object : Database
    ])
], DatasetService);

//# sourceMappingURL=dataset.service.js.map