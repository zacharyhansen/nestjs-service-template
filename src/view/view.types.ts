import type {
  ConfigurationCellType,
  ConfigurationFieldType,
  ConfigurationSupportedPgDataType,
} from 'kysely-codegen';
import { z } from 'zod';

export const PGDataFieldMap: Record<
  ConfigurationSupportedPgDataType,
  ConfigurationFieldType
> = {
  unknown: 'text',

  array_integer: 'comboboxMulti',
  array_text: 'comboboxMulti',
  array_json: 'comboboxMulti',
  array_jsonb: 'comboboxMulti',
  array_boolean: 'comboboxMulti',
  array_numeric: 'comboboxMulti',
  array_varchar: 'comboboxMulti',
  array_date: 'comboboxMulti',
  array_timestamp: 'comboboxMulti',
  bigint: 'number',
  bigserial: 'number',
  bit: 'text',
  bit_varying: 'text',
  boolean: 'checkbox',
  box: 'text',
  bytea: 'text',
  character: 'text',
  character_varying: 'text',
  cidr: 'text',
  circle: 'text',
  date: 'datePicker',
  double_precision: 'number',
  enum: 'combobox',
  float4: 'number',
  float8: 'number',
  inet: 'text',
  integer: 'number',
  interval: 'text',
  json: 'text',
  jsonb: 'text',
  line: 'text',
  lseg: 'text',
  macaddr: 'text',
  money: 'number',
  numeric: 'number',
  path: 'text',
  point: 'text',
  polygon: 'text',
  real: 'number',
  serial: 'number',
  smallint: 'number',
  smallserial: 'number',
  text: 'text',
  time: 'datePicker',
  time_with_time_zone: 'datePicker',
  timestamp: 'datePicker',
  timestamp_with_time_zone: 'datePicker',
  timestamp_without_time_zone: 'datePicker',
  tsquery: 'text',
  tsvector: 'text',
  txid_snapshot: 'text',
  uuid: 'text',
  xml: 'text',
};

export const PGDataCellMap: Record<
  ConfigurationSupportedPgDataType,
  ConfigurationCellType
> = {
  unknown: 'text',

  array_integer: 'comboboxMulti',
  array_text: 'comboboxMulti',
  array_json: 'comboboxMulti',
  array_jsonb: 'comboboxMulti',
  array_boolean: 'comboboxMulti',
  array_numeric: 'comboboxMulti',
  array_varchar: 'comboboxMulti',
  array_date: 'comboboxMulti',
  array_timestamp: 'comboboxMulti',
  bigint: 'number',
  bigserial: 'number',
  bit: 'text',
  bit_varying: 'text',
  boolean: 'checkbox',
  box: 'text',
  bytea: 'text',
  character: 'text',
  character_varying: 'text',
  cidr: 'text',
  circle: 'text',
  date: 'datePicker',
  double_precision: 'number',
  enum: 'combobox',
  float4: 'number',
  float8: 'number',
  inet: 'text',
  integer: 'number',
  interval: 'text',
  json: 'text',
  jsonb: 'text',
  line: 'text',
  lseg: 'text',
  macaddr: 'text',
  money: 'number',
  numeric: 'number',
  path: 'text',
  point: 'text',
  polygon: 'text',
  real: 'number',
  serial: 'number',
  smallint: 'number',
  smallserial: 'number',
  text: 'text',
  time: 'datePicker',
  time_with_time_zone: 'datePicker',
  timestamp: 'datePicker',
  timestamp_with_time_zone: 'datePicker',
  timestamp_without_time_zone: 'datePicker',
  tsquery: 'text',
  tsvector: 'text',
  txid_snapshot: 'text',
  uuid: 'text',
  xml: 'text',
};

export const PostgresSupportedDataTypeIdMap: Record<
  number,
  ConfigurationSupportedPgDataType
> = {
  20: 'bigint',
  1560: 'bit',
  1562: 'bit_varying',
  16: 'boolean',
  603: 'box',
  17: 'bytea',
  1042: 'character',
  1043: 'character_varying',
  650: 'cidr',
  718: 'circle',
  1082: 'date',
  701: 'double_precision',
  700: 'float4',
  869: 'inet',
  23: 'integer',
  1186: 'interval',
  114: 'json',
  3802: 'jsonb',
  628: 'line',
  601: 'lseg',
  829: 'macaddr',
  790: 'money',
  1700: 'numeric',
  602: 'path',
  600: 'point',
  604: 'polygon',
  25: 'text',
  1083: 'time',
  1266: 'time_with_time_zone',
  1114: 'timestamp_without_time_zone',
  1184: 'timestamp_with_time_zone',
  3615: 'tsquery',
  3614: 'tsvector',
  2970: 'txid_snapshot',
  2950: 'uuid',
  142: 'xml',
  1007: 'array_integer', // Array of integers
  1009: 'array_text', // Array of text
  199: 'array_json', // Array of JSON
  3807: 'array_jsonb', // Array of JSONB
  1005: 'array_boolean', // Array of booleans
  1028: 'array_numeric', // Array of numeric
  1016: 'array_varchar', // Array of varchar (character varying)
  1029: 'array_date', // Array of dates
  1011: 'array_timestamp', // Array of timestamps
};

// enum custom_column_type {
//   // Text
//   text
//   jsonb
//   array_text
//   // Numbers
//   int
//   double_precision
//   numeric
//   array_numeric
//   // Dates
//   timestamp_with_time_zone
//   date
//   // Random
//   boolean
//   uuid

//   @@schema("configuration")
// }

export const ViewDefinition = z.object({
  table_name: z.string(),
  view_definition: z.string().nullable(),
  table_schema: z.string(),
});
