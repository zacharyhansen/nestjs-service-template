import { initTRPC } from "@trpc/server";
import { z } from "zod";

const t = initTRPC.create();
const publicProcedure = t.procedure;

const appRouter = t.router({
  app: t.router({ greeting: publicProcedure.input(z.object({ name: z.string() })).output(z.object({ message: z.string() })).query(async () => "PLACEHOLDER_DO_NOT_REMOVE" as any) }),
  view: t.router({
    viewDefinition: publicProcedure.input(z.object({ name: z.string(), id: z.string() })).output(z.object({
      table_name: z.string(),
      view_definition: z.string().nullable(),
      table_schema: z.string(),
    })).query(async () => "PLACEHOLDER_DO_NOT_REMOVE" as any),
    mutateViewsForRoles: publicProcedure.input(z.object({
      rootViewName: z.string(),
      columnEnabledRecords: z
        .object({
          name: z.string(),
        })
        .catchall(z.any())
        .array(),
    })).output(z.literal('ok')).mutation(async () => "PLACEHOLDER_DO_NOT_REMOVE" as any)
  }),
  query: t.router({ execute: publicProcedure.input(z.object({ query: z.string() })).output(z.any()).query(async () => "PLACEHOLDER_DO_NOT_REMOVE" as any) }),
  dataset: t.router({
    dataset: publicProcedure.input(z.object({
      datasetId: z.string(),
    })).output(z.object({
      id: z.string(),
      version: z.number(),
      published: z.boolean(),
      latest: z.boolean(),
      published_at: z.date().nullable(),
      published_by_id: z.string().nullable(),
      created_by_id: z.string(),
      original_id: z.string().nullable(),
      created_at: z.date(),
      name: z.string(),
      description: z.string().nullable(),
      query: z.string().nullable(),
      dataview_id: z.string().nullable(),
      dataview: z.object({
        id: z.string(),
        dataset_id: z.string(),
        role_view_name: z.string(),
        constraint: z.string(),
        schema: z.string(),
        parent_dataview_id: z.string().nullable(),
        created_by_id: z.string(),
        dataview_column: z.array(DataviewColumnOuputSchema).nullable(),
      }).extend({
        dataview: z.lazy(() => DataviewOutputSchema.array()).optional(),
      }).nullable(),
      roleViews: z.array(z.string()).nullable(), // API adds this
    })).query(async () => "PLACEHOLDER_DO_NOT_REMOVE" as any),
    insertRootDataview: publicProcedure.input(z.object({
      rootDataview: z.object({
        datasetId: z.string(),
        role_view_name: z.string(),
      }),
    })).output(z.object({
      id: z.string(),
      version: z.number(),
      published: z.boolean(),
      latest: z.boolean(),
      published_at: z.date().nullable(),
      published_by_id: z.string().nullable(),
      created_by_id: z.string(),
      original_id: z.string().nullable(),
      created_at: z.date(),
      name: z.string(),
      description: z.string().nullable(),
      query: z.string().nullable(),
      dataview_id: z.string().nullable(),
      dataview: z.object({
        id: z.string(),
        dataset_id: z.string(),
        role_view_name: z.string(),
        constraint: z.string(),
        schema: z.string(),
        parent_dataview_id: z.string().nullable(),
        created_by_id: z.string(),
        dataview_column: z.array(DataviewColumnOuputSchema).nullable(),
      }).extend({
        dataview: z.lazy(() => DataviewOutputSchema.array()).optional(),
      }).nullable(),
      roleViews: z.array(z.string()).nullable(), // API adds this
    })).mutation(async () => "PLACEHOLDER_DO_NOT_REMOVE" as any)
  })
});
export type AppRouter = typeof appRouter;

