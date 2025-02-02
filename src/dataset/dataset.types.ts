import { z } from 'zod';
// TODO: This while file is repeated in packages/utils so the FE can have access to the recursive types
// DOnt have time right now to figure out the importingissue of utls into nestjs

// Inputs
const DataviewColumnInputSchema = z.object({
  role_column_name: z.string(),
});

const DataviewInputSchema: z.ZodType = z.lazy(() =>
  z.object({
    role_view_name: z.string(),
    constraint: z.string(),
    dataview_column: z.array(DataviewColumnInputSchema),
    dataview: z.array(DataviewInputSchema),
  })
);

const DatasetInputSchema = z.object({
  name: z.string(),
  id: z.string().optional(),
  dataview_id: DataviewInputSchema,
});

const RootDataViewInputSchema = z.object({
  datasetId: z.string(),
  role_view_name: z.string(),
});

// Outputs
const DataviewColumnOuputSchema = z.object({
  role_column_name: z.string(),
  role_view_name: z.string(),
  dataview_id: z.string(),
  label: z.string().nullable(),
  order: z.number(),
  ag_cell_data_type: z
    .enum(['text', 'percentage', 'usd', 'date', 'timestamp', 'user'])
    .nullable(), // TODO: get these enums from BE
  ag_pinned: z.enum(['left', 'right']).nullable(),
  ag_width: z.number(),
  ag_minWidth: z.number(),
  ag_flex: z.number().nullable(),
  ag_editable: z.boolean(),
  ag_resizable: z.boolean(),
});

const BaseDataviewOutputSchema = z.object({
  id: z.string(),
  dataset_id: z.string(),
  role_view_name: z.string(),
  constraint: z.string(),
  schema: z.string(),
  parent_dataview_id: z.string().nullable(),
  created_by_id: z.string(),
  dataview_column: z.array(DataviewColumnOuputSchema).nullable(),
});

const DataviewOutputSchema: z.ZodType<DataviewOutput> =
  BaseDataviewOutputSchema.extend({
    dataview: z.lazy(() => DataviewOutputSchema.array()).optional(),
  });

const DatasetOutputSchema = z.object({
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
  dataview: DataviewOutputSchema.nullable(),
  roleViews: z.array(z.string()).nullable(), // API adds this
});

type DatasetInput = z.infer<typeof DatasetInputSchema>;
type DatasetOutput = z.infer<typeof DatasetOutputSchema>;
type DataviewOutput = z.infer<typeof BaseDataviewOutputSchema> & {
  dataview?: DataviewOutput[];
};
type RootDataViewInput = z.infer<typeof RootDataViewInputSchema>;

export {
  DatasetInputSchema,
  type DatasetInput,
  DatasetOutputSchema,
  type DatasetOutput,
  type DataviewOutput,
  DataviewOutputSchema,
  RootDataViewInputSchema,
  type RootDataViewInput,
};
