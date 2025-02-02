-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "auth";

-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "configuration";

-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "foundation";

-- CreateEnum
CREATE TYPE "auth"."tenant" AS ENUM ('foundation');

-- CreateEnum
CREATE TYPE "auth"."schema" AS ENUM ('foundation');

-- CreateEnum
CREATE TYPE "configuration"."view_type" AS ENUM ('product', 'custom');

-- CreateEnum
CREATE TYPE "configuration"."link_type" AS ENUM ('M2O', 'O2M', 'M2M', 'O2O');

-- CreateEnum
CREATE TYPE "configuration"."field_type" AS ENUM ('text', 'combobox', 'checkbox', 'number', 'comboboxMulti', 'switch', 'password', 'textarea', 'datePicker', 'dateRangePicker', 'phone', 'tiptap', 'slider', 'user');

-- CreateEnum
CREATE TYPE "configuration"."cell_type" AS ENUM ('text', 'combobox', 'comboboxMulti', 'checkbox', 'switch', 'number', 'textarea', 'datePicker', 'phone', 'user');

-- CreateEnum
CREATE TYPE "configuration"."ag_cell_data_type" AS ENUM ('text', 'percentage', 'usd', 'date', 'timestamp', 'user');

-- CreateEnum
CREATE TYPE "configuration"."ag_pinned" AS ENUM ('left', 'right');

-- CreateEnum
CREATE TYPE "configuration"."supported_pg_data_type" AS ENUM ('unknown', 'array_integer', 'array_json', 'array_jsonb', 'array_text', 'array_boolean', 'array_numeric', 'array_varchar', 'array_date', 'array_timestamp', 'bigint', 'bigserial', 'bit', 'bit_varying', 'boolean', 'box', 'bytea', 'character', 'character_varying', 'cidr', 'circle', 'date', 'double_precision', 'enum', 'float4', 'float8', 'inet', 'integer', 'interval', 'json', 'jsonb', 'line', 'lseg', 'macaddr', 'money', 'numeric', 'path', 'point', 'polygon', 'real', 'serial', 'smallint', 'smallserial', 'text', 'time', 'time_with_time_zone', 'timestamp', 'timestamp_with_time_zone', 'timestamp_without_time_zone', 'tsquery', 'tsvector', 'txid_snapshot', 'uuid', 'xml');

-- CreateEnum
CREATE TYPE "public"."property_type" AS ENUM ('commercial', 'residential');

-- CreateEnum
CREATE TYPE "public"."building_type" AS ENUM ('condo', 'multi_family', 'single_family');

-- CreateEnum
CREATE TYPE "public"."environment_type" AS ENUM ('production', 'uat');

-- CreateEnum
CREATE TYPE "public"."state_usa" AS ENUM ('AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY');

-- CreateEnum
CREATE TYPE "public"."deal_event_type" AS ENUM ('update', 'state_change', 'event', 'error', 'info');

-- CreateTable
CREATE TABLE "auth"."organization" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" VARCHAR(255) NOT NULL,
    "tenant" "auth"."tenant" NOT NULL,
    "external_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "clerk_id" VARCHAR(255) NOT NULL,

    CONSTRAINT "organization_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth"."environment" (
    "schema" "auth"."schema" NOT NULL,
    "tenant" "auth"."tenant" NOT NULL,
    "organization_id" UUID NOT NULL,
    "environment_type" "public"."environment_type" NOT NULL DEFAULT 'uat',

    CONSTRAINT "environment_pkey" PRIMARY KEY ("schema")
);

-- CreateTable
CREATE TABLE "auth"."user" (
    "clerk_id" VARCHAR(255) NOT NULL,
    "external_id" TEXT,
    "email" VARCHAR(255) NOT NULL,
    "joined" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated" TIMESTAMP(3) NOT NULL,
    "address" TEXT,
    "address_line_2" TEXT,
    "city" VARCHAR(255),
    "zip" VARCHAR(255),
    "state" "public"."state_usa",
    "county" TEXT,
    "name" TEXT,
    "phone" VARCHAR(255),
    "ssn" VARCHAR(9),
    "date_of_birth" DATE,
    "credit_score" INTEGER,

    CONSTRAINT "user_pkey" PRIMARY KEY ("clerk_id")
);

-- CreateTable
CREATE TABLE "configuration"."schematic" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "version" INTEGER NOT NULL DEFAULT 0,
    "schema" "auth"."schema" NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "definition" JSONB NOT NULL,

    CONSTRAINT "schematic_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "configuration"."role" (
    "name" TEXT NOT NULL,
    "schema" "auth"."schema" NOT NULL,

    CONSTRAINT "role_pkey" PRIMARY KEY ("schema","name")
);

-- CreateTable
CREATE TABLE "configuration"."view" (
    "name" TEXT NOT NULL,
    "type" "configuration"."view_type" NOT NULL,
    "schema" "auth"."schema" NOT NULL,
    "pg_primary_table" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "pgt_deletable" BOOLEAN NOT NULL,
    "pgt_description" TEXT,
    "pgt_insertable" BOOLEAN NOT NULL,
    "pgt_is_view" BOOLEAN NOT NULL,
    "pgt_updatable" BOOLEAN NOT NULL,
    "pgt_pk_cols" TEXT[],

    CONSTRAINT "view_pkey" PRIMARY KEY ("schema","name")
);

-- CreateTable
CREATE TABLE "configuration"."column" (
    "name" TEXT NOT NULL,
    "schema" "auth"."schema" NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "view_name" TEXT NOT NULL,
    "cell_type" "configuration"."cell_type" NOT NULL,
    "field_type" "configuration"."field_type" NOT NULL,
    "pgt_default" TEXT,
    "pgt_description" TEXT,
    "pgt_enum" TEXT[],
    "pgt_max_len" INTEGER,
    "pgt_name" TEXT,
    "pgt_nominal_type" TEXT,
    "pgt_nullable" BOOLEAN NOT NULL,
    "pgt_type" TEXT NOT NULL,
    "data_type" "configuration"."supported_pg_data_type" NOT NULL,
    "is_pk" BOOLEAN NOT NULL DEFAULT false,
    "oid" INTEGER NOT NULL,
    "is_updatable" BOOLEAN NOT NULL DEFAULT false,
    "is_unique" BOOLEAN NOT NULL DEFAULT false,
    "pg_table" TEXT,
    "pg_column" TEXT,
    "table_id" INTEGER NOT NULL,
    "column_id" INTEGER NOT NULL,

    CONSTRAINT "column_pkey" PRIMARY KEY ("schema","view_name","name")
);

-- CreateTable
CREATE TABLE "configuration"."link" (
    "type" "configuration"."link_type" NOT NULL,
    "schema" "auth"."schema" NOT NULL,
    "constraint" TEXT NOT NULL,
    "pgt_columns" TEXT[],
    "source_view_name" TEXT NOT NULL,
    "source_column_name" TEXT NOT NULL,
    "target_view_name" TEXT NOT NULL,
    "target_column_name" TEXT NOT NULL,
    "pgt_is_self" BOOLEAN NOT NULL,
    "constraint_2" TEXT,
    "pgt_columns_2" TEXT[],
    "junction_view_name" TEXT,
    "junction_source_column_name" TEXT,
    "junction_target_column_name" TEXT,
    "display_name" TEXT NOT NULL,

    CONSTRAINT "link_pkey" PRIMARY KEY ("schema","source_view_name","source_column_name","target_view_name","target_column_name")
);

-- CreateTable
CREATE TABLE "configuration"."role_view" (
    "name" TEXT NOT NULL,
    "schema" "auth"."schema" NOT NULL,
    "role_name" TEXT NOT NULL,
    "view_name" TEXT NOT NULL,

    CONSTRAINT "role_view_pkey" PRIMARY KEY ("schema","name")
);

-- CreateTable
CREATE TABLE "configuration"."role_column" (
    "name" TEXT NOT NULL,
    "schema" "auth"."schema" NOT NULL,
    "role_view_name" TEXT NOT NULL,
    "view_name" TEXT NOT NULL,

    CONSTRAINT "role_column_pkey" PRIMARY KEY ("schema","role_view_name","name")
);

-- CreateTable
CREATE TABLE "configuration"."role_link" (
    "type" "configuration"."link_type" NOT NULL,
    "schema" "auth"."schema" NOT NULL,
    "constraint" TEXT NOT NULL,
    "pgt_columns" TEXT[],
    "source_view_name" TEXT NOT NULL,
    "source_column_name" TEXT NOT NULL,
    "target_view_name" TEXT NOT NULL,
    "target_column_name" TEXT NOT NULL,
    "pgt_is_self" BOOLEAN NOT NULL,
    "constraint_2" TEXT,
    "pgt_columns_2" TEXT[],
    "junction_view_name" TEXT,
    "junction_source_column_name" TEXT,
    "junction_target_column_name" TEXT,
    "display_name" TEXT NOT NULL,

    CONSTRAINT "role_link_pkey" PRIMARY KEY ("schema","source_view_name","source_column_name","target_view_name","target_column_name")
);

-- CreateTable
CREATE TABLE "configuration"."form" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "schema" "auth"."schema" NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "title" TEXT,
    "tags" TEXT[],
    "created_by_id" TEXT NOT NULL,

    CONSTRAINT "form_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "configuration"."form_version" (
    "id" SERIAL NOT NULL,
    "schema" "auth"."schema" NOT NULL,
    "version" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_latest_published" BOOLEAN NOT NULL DEFAULT false,
    "is_draft" BOOLEAN NOT NULL DEFAULT false,
    "form_id" UUID NOT NULL,
    "created_by_id" TEXT NOT NULL,

    CONSTRAINT "form_version_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "configuration"."field" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "schema" "auth"."schema" NOT NULL,
    "name" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "required" BOOLEAN NOT NULL DEFAULT true,
    "field_type" "configuration"."field_type" NOT NULL,
    "name_locked" BOOLEAN NOT NULL DEFAULT false,
    "label" TEXT,
    "description" TEXT,
    "placeholder" TEXT,
    "default_value" TEXT,
    "options" JSONB NOT NULL DEFAULT '[]',
    "form_version_id" INTEGER NOT NULL,

    CONSTRAINT "field_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "configuration"."form_instance" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "schema" "auth"."schema" NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "content" TEXT NOT NULL DEFAULT '',
    "values" JSONB NOT NULL DEFAULT '{}',
    "form_id" UUID NOT NULL,
    "form_version_id" INTEGER NOT NULL,
    "created_by_id" TEXT NOT NULL,

    CONSTRAINT "form_instance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "configuration"."dataset" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "version" INTEGER NOT NULL DEFAULT 1,
    "published" BOOLEAN NOT NULL DEFAULT false,
    "latest" BOOLEAN NOT NULL DEFAULT true,
    "published_at" TIMESTAMP(3),
    "published_by_id" TEXT,
    "created_by_id" TEXT NOT NULL,
    "original_id" UUID,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "query" TEXT,
    "dataview_id" UUID,
    "schema" "auth"."schema" NOT NULL,

    CONSTRAINT "dataset_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "configuration"."dataview" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "dataset_id" UUID NOT NULL,
    "role_view_name" TEXT NOT NULL,
    "constraint" TEXT NOT NULL,
    "schema" "auth"."schema" NOT NULL,
    "parent_dataview_id" UUID,
    "created_by_id" TEXT NOT NULL,

    CONSTRAINT "dataview_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "configuration"."dataview_column" (
    "dataview_id" UUID NOT NULL,
    "role_column_name" TEXT NOT NULL,
    "role_view_name" TEXT NOT NULL,
    "schema" "auth"."schema" NOT NULL,
    "label" TEXT,
    "ag_cell_data_type" "configuration"."ag_cell_data_type" NOT NULL,
    "ag_width" INTEGER NOT NULL DEFAULT 200,
    "ag_minWidth" INTEGER NOT NULL DEFAULT 50,
    "ag_flex" INTEGER,
    "ag_editable" BOOLEAN NOT NULL DEFAULT false,
    "ag_resizable" BOOLEAN NOT NULL DEFAULT true,
    "ag_pinned" "configuration"."ag_pinned",
    "order" INTEGER NOT NULL DEFAULT 0,
    "description" TEXT,

    CONSTRAINT "dataview_column_pkey" PRIMARY KEY ("dataview_id","role_view_name","role_column_name")
);

-- CreateTable
CREATE TABLE "foundation"."environment_user" (
    "user_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "schema" "auth"."schema" NOT NULL DEFAULT 'foundation',
    "role_name" TEXT NOT NULL,

    CONSTRAINT "environment_user_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "foundation"."deal_state" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "external_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "order" INTEGER NOT NULL,
    "label" TEXT NOT NULL,

    CONSTRAINT "deal_state_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "foundation"."opportunity" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "external_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "label" TEXT,
    "active_deal_id" UUID,
    "assignee_id" TEXT,
    "created_by_id" TEXT NOT NULL,
    "borrower_user_id" TEXT,
    "borrower_business_id" UUID,
    "agent_id" TEXT,

    CONSTRAINT "opportunity_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "foundation"."deal" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "external_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "source" TEXT,
    "winnability" INTEGER,
    "appetite" INTEGER,
    "loan_amount" DECIMAL(14,3),
    "interest_rate" DECIMAL(7,6),
    "loan_processing_fee" DECIMAL(10,3),
    "label" TEXT NOT NULL,
    "opportunity_id" UUID NOT NULL,
    "assignee_id" TEXT,
    "created_by_id" TEXT NOT NULL,
    "deal_state_id" UUID NOT NULL,
    "ssbs_score" INTEGER,

    CONSTRAINT "deal_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "foundation"."task_status" (
    "id" SERIAL NOT NULL,
    "external_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "label" TEXT NOT NULL,

    CONSTRAINT "task_status_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "foundation"."task_priority" (
    "id" SERIAL NOT NULL,
    "external_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "label" TEXT NOT NULL,

    CONSTRAINT "task_priority_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "foundation"."task" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "external_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "assignee_id" TEXT,
    "created_by_id" TEXT NOT NULL,
    "deal_id" UUID NOT NULL,
    "status_id" INTEGER NOT NULL,
    "priority_id" INTEGER NOT NULL,

    CONSTRAINT "task_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "foundation"."property" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "external_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "address" TEXT,
    "address_line_2" TEXT,
    "city" VARCHAR(255),
    "zip" VARCHAR(255),
    "state" "public"."state_usa",
    "county" TEXT,
    "building_type" "public"."building_type",
    "type" "public"."property_type",
    "tags" TEXT[],
    "year_built" INTEGER,
    "description" TEXT,
    "amenities" TEXT[],
    "area_sq_km" DOUBLE PRECISION,
    "last_census_at" TIMESTAMP(3),
    "deal_id" UUID NOT NULL,

    CONSTRAINT "property_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "foundation"."deal_user" (
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "user_id" TEXT NOT NULL,
    "deal_id" UUID NOT NULL,

    CONSTRAINT "deal_user_pkey" PRIMARY KEY ("deal_id","user_id")
);

-- CreateTable
CREATE TABLE "foundation"."business" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "external_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "duns" VARCHAR(9),
    "dba" VARCHAR(255),
    "tin" VARCHAR(9),
    "email" VARCHAR(255),
    "address" TEXT,
    "address_line_2" TEXT,
    "city" VARCHAR(255),
    "zip" VARCHAR(255),
    "state" "public"."state_usa",
    "county" TEXT,
    "name_display" TEXT,
    "name_legal" TEXT,
    "phone" TEXT,
    "business_type" TEXT,
    "industry" TEXT,
    "date_business_began" DATE,
    "revenue_average" DOUBLE PRECISION,
    "debt" DOUBLE PRECISION,

    CONSTRAINT "business_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "foundation"."business_user" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "business_id" UUID NOT NULL,
    "user_id" TEXT NOT NULL,
    "job_title" TEXT,
    "owernship" DOUBLE PRECISION,
    "income_average_monthly" DOUBLE PRECISION,
    "expense_average_monthly" DOUBLE PRECISION,

    CONSTRAINT "business_user_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "foundation"."deal_event" (
    "id" BIGSERIAL NOT NULL,
    "timestamp" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT NOT NULL,
    "deal_id" UUID NOT NULL,
    "type" "public"."deal_event_type" NOT NULL DEFAULT 'info',
    "message" TEXT NOT NULL,
    "metadata" JSONB,
    "source" VARCHAR(255),

    CONSTRAINT "deal_event_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "organization_external_id_key" ON "auth"."organization"("external_id");

-- CreateIndex
CREATE UNIQUE INDEX "organization_clerk_id_key" ON "auth"."organization"("clerk_id");

-- CreateIndex
CREATE UNIQUE INDEX "organization_tenant_name_key" ON "auth"."organization"("tenant", "name");

-- CreateIndex
CREATE UNIQUE INDEX "environment_tenant_organization_id_environment_type_key" ON "auth"."environment"("tenant", "organization_id", "environment_type");

-- CreateIndex
CREATE UNIQUE INDEX "user_clerk_id_key" ON "auth"."user"("clerk_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_external_id_key" ON "auth"."user"("external_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_email_key" ON "auth"."user"("email");

-- CreateIndex
CREATE INDEX "view_schema_name_idx" ON "configuration"."view"("schema", "name");

-- CreateIndex
CREATE INDEX "link_schema_source_view_name_idx" ON "configuration"."link"("schema", "source_view_name");

-- CreateIndex
CREATE INDEX "form_schema_id_idx" ON "configuration"."form"("schema", "id");

-- CreateIndex
CREATE INDEX "form_version_schema_form_id_is_latest_published_idx" ON "configuration"."form_version"("schema", "form_id", "is_latest_published");

-- CreateIndex
CREATE UNIQUE INDEX "form_version_schema_form_id_version_key" ON "configuration"."form_version"("schema", "form_id", "version");

-- CreateIndex
CREATE INDEX "field_schema_id_idx" ON "configuration"."field"("schema", "id");

-- CreateIndex
CREATE UNIQUE INDEX "field_schema_form_version_id_name_key" ON "configuration"."field"("schema", "form_version_id", "name");

-- CreateIndex
CREATE INDEX "form_instance_schema_form_id_id_idx" ON "configuration"."form_instance"("schema", "form_id", "id");

-- CreateIndex
CREATE UNIQUE INDEX "dataset_dataview_id_key" ON "configuration"."dataset"("dataview_id");

-- CreateIndex
CREATE INDEX "dataset_original_id_published_idx" ON "configuration"."dataset"("original_id", "published");

-- CreateIndex
CREATE UNIQUE INDEX "dataset_original_id_published_schema_key" ON "configuration"."dataset"("original_id", "published", "schema");

-- CreateIndex
CREATE UNIQUE INDEX "dataset_original_id_latest_schema_key" ON "configuration"."dataset"("original_id", "latest", "schema");

-- CreateIndex
CREATE INDEX "dataview_dataset_id_idx" ON "configuration"."dataview"("dataset_id");

-- CreateIndex
CREATE UNIQUE INDEX "dataview_dataset_id_parent_dataview_id_role_view_name_const_key" ON "configuration"."dataview"("dataset_id", "parent_dataview_id", "role_view_name", "constraint");

-- CreateIndex
CREATE UNIQUE INDEX "environment_user_user_id_key" ON "foundation"."environment_user"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "deal_state_external_id_key" ON "foundation"."deal_state"("external_id");

-- CreateIndex
CREATE UNIQUE INDEX "deal_state_label_key" ON "foundation"."deal_state"("label");

-- CreateIndex
CREATE UNIQUE INDEX "opportunity_external_id_key" ON "foundation"."opportunity"("external_id");

-- CreateIndex
CREATE UNIQUE INDEX "opportunity_active_deal_id_key" ON "foundation"."opportunity"("active_deal_id");

-- CreateIndex
CREATE UNIQUE INDEX "deal_external_id_key" ON "foundation"."deal"("external_id");

-- CreateIndex
CREATE UNIQUE INDEX "task_status_external_id_key" ON "foundation"."task_status"("external_id");

-- CreateIndex
CREATE UNIQUE INDEX "task_status_label_key" ON "foundation"."task_status"("label");

-- CreateIndex
CREATE UNIQUE INDEX "task_priority_external_id_key" ON "foundation"."task_priority"("external_id");

-- CreateIndex
CREATE UNIQUE INDEX "task_priority_label_key" ON "foundation"."task_priority"("label");

-- CreateIndex
CREATE UNIQUE INDEX "task_external_id_key" ON "foundation"."task"("external_id");

-- CreateIndex
CREATE UNIQUE INDEX "property_external_id_key" ON "foundation"."property"("external_id");

-- CreateIndex
CREATE UNIQUE INDEX "business_external_id_key" ON "foundation"."business"("external_id");

-- CreateIndex
CREATE UNIQUE INDEX "business_duns_key" ON "foundation"."business"("duns");

-- CreateIndex
CREATE UNIQUE INDEX "business_dba_key" ON "foundation"."business"("dba");

-- CreateIndex
CREATE UNIQUE INDEX "business_tin_key" ON "foundation"."business"("tin");

-- CreateIndex
CREATE UNIQUE INDEX "business_user_business_id_user_id_key" ON "foundation"."business_user"("business_id", "user_id");

-- CreateIndex
CREATE INDEX "deal_event_timestamp_id_idx" ON "foundation"."deal_event"("timestamp" DESC, "id" DESC);

-- CreateIndex
CREATE INDEX "deal_event_type_timestamp_id_idx" ON "foundation"."deal_event"("type", "timestamp" DESC, "id" DESC);

-- CreateIndex
CREATE INDEX "deal_event_source_timestamp_id_idx" ON "foundation"."deal_event"("source", "timestamp" DESC, "id" DESC);

-- AddForeignKey
ALTER TABLE "auth"."environment" ADD CONSTRAINT "environment_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "auth"."organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."column" ADD CONSTRAINT "column_schema_view_name_fkey" FOREIGN KEY ("schema", "view_name") REFERENCES "configuration"."view"("schema", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."link" ADD CONSTRAINT "link_schema_source_view_name_fkey" FOREIGN KEY ("schema", "source_view_name") REFERENCES "configuration"."view"("schema", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."link" ADD CONSTRAINT "link_schema_target_view_name_fkey" FOREIGN KEY ("schema", "target_view_name") REFERENCES "configuration"."view"("schema", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."link" ADD CONSTRAINT "link_schema_target_view_name_target_column_name_fkey" FOREIGN KEY ("schema", "target_view_name", "target_column_name") REFERENCES "configuration"."column"("schema", "view_name", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."link" ADD CONSTRAINT "link_schema_source_view_name_source_column_name_fkey" FOREIGN KEY ("schema", "source_view_name", "source_column_name") REFERENCES "configuration"."column"("schema", "view_name", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."link" ADD CONSTRAINT "link_schema_junction_view_name_fkey" FOREIGN KEY ("schema", "junction_view_name") REFERENCES "configuration"."view"("schema", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."link" ADD CONSTRAINT "link_schema_junction_view_name_junction_source_column_name_fkey" FOREIGN KEY ("schema", "junction_view_name", "junction_source_column_name") REFERENCES "configuration"."column"("schema", "view_name", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."link" ADD CONSTRAINT "link_schema_junction_view_name_junction_target_column_name_fkey" FOREIGN KEY ("schema", "junction_view_name", "junction_target_column_name") REFERENCES "configuration"."column"("schema", "view_name", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."role_view" ADD CONSTRAINT "role_view_schema_view_name_fkey" FOREIGN KEY ("schema", "view_name") REFERENCES "configuration"."view"("schema", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."role_view" ADD CONSTRAINT "role_view_schema_role_name_fkey" FOREIGN KEY ("schema", "role_name") REFERENCES "configuration"."role"("schema", "name") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."role_column" ADD CONSTRAINT "role_column_schema_role_view_name_fkey" FOREIGN KEY ("schema", "role_view_name") REFERENCES "configuration"."role_view"("schema", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."role_column" ADD CONSTRAINT "role_column_schema_view_name_name_fkey" FOREIGN KEY ("schema", "view_name", "name") REFERENCES "configuration"."column"("schema", "view_name", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."role_column" ADD CONSTRAINT "role_column_schema_view_name_fkey" FOREIGN KEY ("schema", "view_name") REFERENCES "configuration"."view"("schema", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."role_link" ADD CONSTRAINT "role_link_schema_source_view_name_fkey" FOREIGN KEY ("schema", "source_view_name") REFERENCES "configuration"."role_view"("schema", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."role_link" ADD CONSTRAINT "role_link_schema_source_view_name_source_column_name_fkey" FOREIGN KEY ("schema", "source_view_name", "source_column_name") REFERENCES "configuration"."role_column"("schema", "role_view_name", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."role_link" ADD CONSTRAINT "role_link_schema_target_view_name_fkey" FOREIGN KEY ("schema", "target_view_name") REFERENCES "configuration"."role_view"("schema", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."role_link" ADD CONSTRAINT "role_link_schema_target_view_name_target_column_name_fkey" FOREIGN KEY ("schema", "target_view_name", "target_column_name") REFERENCES "configuration"."role_column"("schema", "role_view_name", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."role_link" ADD CONSTRAINT "role_link_schema_junction_view_name_fkey" FOREIGN KEY ("schema", "junction_view_name") REFERENCES "configuration"."role_view"("schema", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."role_link" ADD CONSTRAINT "role_link_schema_junction_view_name_junction_source_column_fkey" FOREIGN KEY ("schema", "junction_view_name", "junction_source_column_name") REFERENCES "configuration"."role_column"("schema", "role_view_name", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."role_link" ADD CONSTRAINT "role_link_schema_junction_view_name_junction_target_column_fkey" FOREIGN KEY ("schema", "junction_view_name", "junction_target_column_name") REFERENCES "configuration"."role_column"("schema", "role_view_name", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."form" ADD CONSTRAINT "form_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "auth"."user"("clerk_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."form_version" ADD CONSTRAINT "form_version_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "auth"."user"("clerk_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."form_version" ADD CONSTRAINT "form_version_form_id_fkey" FOREIGN KEY ("form_id") REFERENCES "configuration"."form"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."field" ADD CONSTRAINT "field_form_version_id_fkey" FOREIGN KEY ("form_version_id") REFERENCES "configuration"."form_version"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."form_instance" ADD CONSTRAINT "form_instance_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "auth"."user"("clerk_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."form_instance" ADD CONSTRAINT "form_instance_form_version_id_fkey" FOREIGN KEY ("form_version_id") REFERENCES "configuration"."form_version"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."dataset" ADD CONSTRAINT "dataset_dataview_id_fkey" FOREIGN KEY ("dataview_id") REFERENCES "configuration"."dataview"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."dataset" ADD CONSTRAINT "dataset_original_id_fkey" FOREIGN KEY ("original_id") REFERENCES "configuration"."dataset"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."dataset" ADD CONSTRAINT "dataset_published_by_id_fkey" FOREIGN KEY ("published_by_id") REFERENCES "auth"."user"("clerk_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."dataset" ADD CONSTRAINT "dataset_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "auth"."user"("clerk_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."dataview" ADD CONSTRAINT "dataview_parent_dataview_id_fkey" FOREIGN KEY ("parent_dataview_id") REFERENCES "configuration"."dataview"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."dataview" ADD CONSTRAINT "dataview_dataset_id_fkey" FOREIGN KEY ("dataset_id") REFERENCES "configuration"."dataset"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."dataview" ADD CONSTRAINT "dataview_schema_role_view_name_fkey" FOREIGN KEY ("schema", "role_view_name") REFERENCES "configuration"."role_view"("schema", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."dataview" ADD CONSTRAINT "dataview_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "auth"."user"("clerk_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."dataview_column" ADD CONSTRAINT "dataview_column_dataview_id_fkey" FOREIGN KEY ("dataview_id") REFERENCES "configuration"."dataview"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "configuration"."dataview_column" ADD CONSTRAINT "dataview_column_schema_role_view_name_role_column_name_fkey" FOREIGN KEY ("schema", "role_view_name", "role_column_name") REFERENCES "configuration"."role_column"("schema", "role_view_name", "name") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."environment_user" ADD CONSTRAINT "environment_user_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."user"("clerk_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "foundation"."environment_user" ADD CONSTRAINT "environment_user_role_name_schema_fkey" FOREIGN KEY ("role_name", "schema") REFERENCES "configuration"."role"("name", "schema") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."opportunity" ADD CONSTRAINT "opportunity_active_deal_id_fkey" FOREIGN KEY ("active_deal_id") REFERENCES "foundation"."deal"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."opportunity" ADD CONSTRAINT "opportunity_agent_id_fkey" FOREIGN KEY ("agent_id") REFERENCES "foundation"."environment_user"("user_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."opportunity" ADD CONSTRAINT "opportunity_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "foundation"."environment_user"("user_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."opportunity" ADD CONSTRAINT "opportunity_borrower_business_id_fkey" FOREIGN KEY ("borrower_business_id") REFERENCES "foundation"."business"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."opportunity" ADD CONSTRAINT "opportunity_borrower_user_id_fkey" FOREIGN KEY ("borrower_user_id") REFERENCES "foundation"."environment_user"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."opportunity" ADD CONSTRAINT "opportunity_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "foundation"."environment_user"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."deal" ADD CONSTRAINT "deal_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "foundation"."environment_user"("user_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."deal" ADD CONSTRAINT "deal_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "foundation"."environment_user"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."deal" ADD CONSTRAINT "deal_opportunity_id_fkey" FOREIGN KEY ("opportunity_id") REFERENCES "foundation"."opportunity"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."deal" ADD CONSTRAINT "deal_deal_state_id_fkey" FOREIGN KEY ("deal_state_id") REFERENCES "foundation"."deal_state"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."task" ADD CONSTRAINT "task_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "foundation"."environment_user"("user_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."task" ADD CONSTRAINT "task_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "foundation"."environment_user"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."task" ADD CONSTRAINT "task_deal_id_fkey" FOREIGN KEY ("deal_id") REFERENCES "foundation"."deal"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."task" ADD CONSTRAINT "task_priority_id_fkey" FOREIGN KEY ("priority_id") REFERENCES "foundation"."task_priority"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."task" ADD CONSTRAINT "task_status_id_fkey" FOREIGN KEY ("status_id") REFERENCES "foundation"."task_status"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."property" ADD CONSTRAINT "property_deal_id_fkey" FOREIGN KEY ("deal_id") REFERENCES "foundation"."deal"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."deal_user" ADD CONSTRAINT "deal_user_deal_id_fkey" FOREIGN KEY ("deal_id") REFERENCES "foundation"."deal"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."deal_user" ADD CONSTRAINT "deal_user_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "foundation"."environment_user"("user_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."business_user" ADD CONSTRAINT "business_user_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "foundation"."business"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "foundation"."business_user" ADD CONSTRAINT "business_user_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "foundation"."environment_user"("user_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "foundation"."deal_event" ADD CONSTRAINT "deal_event_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "foundation"."environment_user"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "foundation"."deal_event" ADD CONSTRAINT "deal_event_deal_id_fkey" FOREIGN KEY ("deal_id") REFERENCES "foundation"."deal"("id") ON DELETE CASCADE ON UPDATE CASCADE;
