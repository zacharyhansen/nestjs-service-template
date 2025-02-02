-- AlterTable
ALTER TABLE "configuration"."dataview_column" ALTER COLUMN "ag_cell_data_type" DROP NOT NULL,
ALTER COLUMN "ag_cell_data_type" SET DEFAULT 'text';
