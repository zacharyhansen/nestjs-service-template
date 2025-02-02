-- One to one relations
ALTER TABLE configuration.dataset
    ADD UNIQUE (dataview_id);

ALTER TABLE configuration.dataset
    ADD UNIQUE (dataview_id);

-- POSTGREST --------------------------------------------------
CREATE SCHEMA IF NOT EXISTS postgrest;

CREATE OR REPLACE FUNCTION create_role_if_not_exists(
    role_name text,
    with_login boolean DEFAULT false,
    with_noinherit boolean DEFAULT false,
    with_password text DEFAULT NULL
) RETURNS void AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = role_name) THEN
        DECLARE
            create_role_stmt text := format('CREATE ROLE %I', role_name);
        BEGIN
            IF with_noinherit THEN
                create_role_stmt := create_role_stmt || ' NOINHERIT';
            END IF;
            IF with_login THEN
                create_role_stmt := create_role_stmt || ' LOGIN';
            END IF;
            IF with_password IS NOT NULL THEN
                create_role_stmt := create_role_stmt || format(' PASSWORD %L', with_password);
            END IF;
            
            EXECUTE create_role_stmt;
            RAISE NOTICE 'Role "%" has been created', role_name;
        END;
    ELSE
        RAISE NOTICE 'Role "%" already exists, no action taken', role_name;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE
OR REPLACE FUNCTION postgrest.pre_config() RETURNS void AS $$
SELECT
    set_config(
        'pgrst.jwt_secret',
        'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvnOiPTCR4APnNVFXDWdRZjgKkGFUQbU7DarpWVK66eGUUoTtKfYUK40vvwwTH7gNYPitBqHvxdVPHhqbjYnKYF8HEebqsX9B4O8LAOoeqq9jX/L/hYzVqmAaxeZHAH1GM4WCA7TQ6w/Tj2A4AcVv+vD28WX/GnbCtDui17UZ1CJCyc4JME6PqnZUXRJ4vNjQwo+5dIKtUY/KLtEa3K9Hs/HUedASkn8TPRXHKv7zBMXg2I1VWMSk5Qg+JCF0/eQHZnN3+U1Pzp8IcQW+T+bSdRLGEXsy9JyD53ItMU1PQ3J3M16CFEH3d4BsTSq4kwIFFVAUqW5w8MsN8udGAZLebQIDAQAB',
        true
    ),
    set_config(
        'pgrst.db_schemas',
        string_agg(nspname, ','),
        true
    )
from
    (
        -- select the relavant schema we watch for
        SELECT
            nspname
        FROM
            pg_namespace
        WHERE
            nspname LIKE 'tenant_%'
        UNION ALL
        SELECT
            'public'
        UNION ALL
        SELECT
            'foundation'
          UNION ALL
        SELECT
            'configuration'
    ) AS namespaces;
$$ language sql;

-- watch CREATE and ALTER
CREATE
OR REPLACE FUNCTION pgrst_ddl_watch() RETURNS event_trigger AS $$ DECLARE cmd record;
BEGIN FOR cmd IN
SELECT
    *
FROM
    pg_event_trigger_ddl_commands() LOOP IF cmd.command_tag IN (
        'CREATE SCHEMA',
        'ALTER SCHEMA',
        'CREATE TABLE',
        'CREATE TABLE AS',
        'SELECT INTO',
        'ALTER TABLE',
        'CREATE FOREIGN TABLE',
        'ALTER FOREIGN TABLE',
        'CREATE VIEW',
        'ALTER VIEW',
        'CREATE MATERIALIZED VIEW',
        'ALTER MATERIALIZED VIEW',
        'CREATE FUNCTION',
        'ALTER FUNCTION',
        'CREATE TRIGGER',
        'CREATE TYPE',
        'ALTER TYPE',
        'CREATE RULE',
        'COMMENT'
    ) -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct
from
    'pg_temp' THEN NOTIFY pgrst,
    'reload schema';
END IF;
END LOOP;
END;
$$ LANGUAGE plpgsql;
-- watch DROP
CREATE
OR REPLACE FUNCTION pgrst_drop_watch() RETURNS event_trigger AS $$ DECLARE obj record;
BEGIN FOR obj IN
SELECT
    *
FROM
    pg_event_trigger_dropped_objects() LOOP IF obj.object_type IN (
        'schema',
        'table',
        'foreign table',
        'view',
        'materialized view',
        'function',
        'trigger',
        'type',
        'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN NOTIFY pgrst,
    'reload schema';
END IF;
END LOOP;
END;
$$ LANGUAGE plpgsql;
CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end EXECUTE PROCEDURE pgrst_ddl_watch();
CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop EXECUTE PROCEDURE pgrst_drop_watch();

-- TODO: Need to inject this somehow
SELECT create_role_if_not_exists('authenticator', true, true, 'secretpassword');

SELECT create_role_if_not_exists('super_admin', false, false);
GRANT super_admin TO authenticator;

SELECT create_role_if_not_exists('anonymous', false, false);
GRANT anonymous TO authenticator;

-- start super_admin role privileges
GRANT USAGE ON SCHEMA public TO super_admin;
GRANT ALL ON ALL TABLES IN SCHEMA public TO super_admin;
GRANT ALL ON ALL ROUTINES IN SCHEMA public TO super_admin;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO super_admin;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO super_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO super_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON ROUTINES TO super_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO super_admin;

GRANT USAGE ON SCHEMA auth TO super_admin;
GRANT ALL ON ALL TABLES IN SCHEMA auth TO super_admin;
GRANT ALL ON ALL ROUTINES IN SCHEMA auth TO super_admin;
GRANT ALL ON ALL SEQUENCES IN SCHEMA auth TO super_admin;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA auth TO super_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA auth GRANT ALL ON TABLES TO super_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA auth GRANT ALL ON ROUTINES TO super_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA auth GRANT ALL ON SEQUENCES TO super_admin;

GRANT USAGE ON SCHEMA configuration TO super_admin;
GRANT ALL ON ALL TABLES IN SCHEMA configuration TO super_admin;
GRANT ALL ON ALL ROUTINES IN SCHEMA configuration TO super_admin;
GRANT ALL ON ALL SEQUENCES IN SCHEMA configuration TO super_admin;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA configuration TO super_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA configuration GRANT ALL ON TABLES TO super_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA configuration GRANT ALL ON ROUTINES TO super_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA configuration GRANT ALL ON SEQUENCES TO super_admin;
-- end super_admin role privileges

-- SCHEMA/TENANT Setup ----------------------------------------------------------------------------------------------------------------

-- FUNCTION TO SET UP schema roles and usage ----------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION create_default_roles_and_grant_access_to_schemas(schema_list TEXT[])
RETURNS VOID AS $$
DECLARE
    schema_name TEXT;
BEGIN
    FOREACH schema_name IN ARRAY schema_list
    LOOP
        -- Create role for the schema admin
        EXECUTE format('SELECT create_role_if_not_exists (''admin_%s'', false, false);', schema_name);

        -- Grant access to the super admin
        EXECUTE format('GRANT USAGE ON SCHEMA %I TO super_admin;', schema_name);
        EXECUTE format('GRANT ALL ON ALL TABLES IN SCHEMA %I TO super_admin;', schema_name);
        EXECUTE format('GRANT ALL ON ALL ROUTINES IN SCHEMA %I TO super_admin;', schema_name);
        EXECUTE format('GRANT ALL ON ALL SEQUENCES IN SCHEMA %I TO super_admin;', schema_name);
        EXECUTE format('GRANT ALL ON ALL FUNCTIONS IN SCHEMA %I TO super_admin;', schema_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA %I GRANT ALL ON TABLES TO super_admin;', schema_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA %I GRANT ALL ON ROUTINES TO super_admin;', schema_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA %I GRANT ALL ON SEQUENCES TO super_admin;', schema_name);

        -- Grant access to the schema admin
        EXECUTE format('GRANT USAGE ON SCHEMA %I TO admin_%s;', schema_name, schema_name);
        EXECUTE format('GRANT ALL ON ALL TABLES IN SCHEMA %I TO admin_%s;', schema_name, schema_name);
        EXECUTE format('GRANT ALL ON ALL ROUTINES IN SCHEMA %I TO admin_%s;', schema_name, schema_name);
        EXECUTE format('GRANT ALL ON ALL SEQUENCES IN SCHEMA %I TO admin_%s;', schema_name, schema_name);
        EXECUTE format('GRANT ALL ON ALL FUNCTIONS IN SCHEMA %I TO admin_%s;', schema_name, schema_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA %I GRANT ALL ON TABLES TO admin_%s;', schema_name, schema_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA %I GRANT ALL ON ROUTINES TO admin_%s;', schema_name, schema_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA %I GRANT ALL ON SEQUENCES TO admin_%s;', schema_name, schema_name);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- FUNCTION TO CREATE AUTH VIEWS
CREATE OR REPLACE FUNCTION create_auth_views(schema_list TEXT[])
RETURNS void AS $$
DECLARE
    schema_name TEXT;
    role_name TEXT;
    role_id TEXT;
    view_sql TEXT;
BEGIN
    -- Loop through each schema provided in the input list
    FOREACH schema_name IN ARRAY schema_list
    LOOP
        -- User View
        -- We specifically select here to NOT include the auth.user.id column to prevent weird links showing up in the shcematic for our _p_user
        view_sql := 'CREATE OR REPLACE VIEW ' || schema_name || '._p_user AS ' ||
                    'SELECT auth.user.external_id, auth.user.clerk_id, auth.user.email, auth.user.joined, auth.user.updated, auth.user.address, auth.user.address_line_2, auth.user.city, auth.user.zip, auth.user.state, auth.user.county, auth.user.name, auth.user.phone, auth.user.ssn, auth.user.date_of_birth, auth.user.credit_score, ' ||  schema_name || '.environment_user.* ' ||
                    'FROM ' || schema_name || '.environment_user ' ||
                    'LEFT JOIN auth.user ON auth.user.clerk_id = ' || schema_name || '.environment_user.user_id';
        EXECUTE view_sql;

        -- Organization View
        view_sql := 'CREATE OR REPLACE VIEW ' || schema_name || '._p_organization AS ' ||
                    'SELECT auth.organization.* ' ||
                    'FROM auth.organization ' ||
                    'WHERE auth.organization.tenant = ''' || schema_name || '''';
        EXECUTE view_sql;

        -- Environment View
        view_sql := 'CREATE OR REPLACE VIEW ' || schema_name || '._p_environment AS ' ||
                    'SELECT auth.environment.* ' ||
                    'FROM auth.environment ' ||
                    'WHERE auth.environment.schema = ''' || schema_name || '''';
        EXECUTE view_sql;

        -- Role-Specific User Views
        FOR role_name IN
            EXECUTE format('SELECT name FROM configuration.role WHERE schema = %L', schema_name)
        LOOP
            view_sql := 'CREATE OR REPLACE VIEW ' || schema_name || '.' || '_p_' || role_name || ' AS ' ||
                        'SELECT auth.user.* ' ||
                        'FROM auth.user ' ||
                        'INNER JOIN ' || schema_name || '.environment_user ON auth.user.clerk_id = ' || schema_name || '.environment_user.user_id ' ||
                        'WHERE ' || schema_name || '.environment_user.role_name = ''' || role_name || '''';
            EXECUTE view_sql;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;



-- FUNCTION TO CREATE MASTER TABLE VIEWS --------------------------------------------------------------------
CREATE OR REPLACE FUNCTION create_table_master_views(schema_list TEXT[])
RETURNS void AS $$
DECLARE
    schema_name TEXT;
    table_name TEXT;
    view_sql TEXT;
BEGIN
    -- Loop through each schema provided in the input list
    FOREACH schema_name IN ARRAY schema_list
    LOOP
        -- Loop through the specified tables for the current schema
        FOR table_name IN
            SELECT t.table_name
            FROM information_schema.tables t
            WHERE t.table_schema = schema_name
              AND table_type = 'BASE TABLE'
        LOOP
            -- Construct the dynamic SQL for creating the view
            view_sql := 'CREATE OR REPLACE VIEW ' || schema_name || '._p_' || table_name ||
                        ' AS SELECT * FROM ' || schema_name || '.' || table_name;

            -- Execute the SQL to create or replace the view
            EXECUTE view_sql;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- FUNCTION TO CREATE VIEW FOR DATASET COLUMNS ----------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION create_schema_columns_views(schema_list text[])
    RETURNS void AS
$$
DECLARE
    schema_name text;
    view_query text;
BEGIN
    FOREACH schema_name IN ARRAY schema_list
        LOOP
            -- Construct the materialized view creation query
            view_query := format(
                    'CREATE OR REPLACE VIEW %I.schema_columns AS
                    WITH primary_keys AS (
                        SELECT
                            tc.table_schema,
                            tc.table_name,
                            kcu.column_name
                        FROM information_schema.table_constraints tc
                        JOIN information_schema.key_column_usage kcu
                            ON tc.constraint_name = kcu.constraint_name
                            AND tc.table_schema = kcu.table_schema
                        WHERE tc.constraint_type = ''PRIMARY KEY''
                    ),
                    foreign_keys AS (
                        SELECT
                            kcu.table_schema,
                            kcu.table_name,
                            kcu.column_name,
                            ccu.table_name AS foreign_table_name
                        FROM information_schema.table_constraints tc
                        JOIN information_schema.key_column_usage kcu
                            ON tc.constraint_name = kcu.constraint_name
                            AND tc.table_schema = kcu.table_schema
                        JOIN information_schema.constraint_column_usage ccu
                            ON ccu.constraint_name = tc.constraint_name
                            AND ccu.table_schema = tc.table_schema
                        WHERE tc.constraint_type = ''FOREIGN KEY''
                    ),
                    unique_indexes AS (
                        SELECT
                            schemaname,
                            tablename,
                            array_agg(indexdef::text) as index_definitions
                        FROM pg_indexes
                        WHERE indexdef LIKE ''%%UNIQUE%%''
                        GROUP BY schemaname, tablename
                    )
                    SELECT
                        c.table_name,
                        table_type,
                        c.column_name,
                        c.data_type,
                        c.is_nullable,
                        c.column_default,
                        c.character_maximum_length,
                        c.numeric_precision,
                        c.numeric_scale,
                        CASE WHEN pk.column_name IS NOT NULL THEN true ELSE false END as is_pk,
                        fk.foreign_table_name as references_table,
                        CASE
                            WHEN ui.index_definitions IS NOT NULL
                            AND array_to_string(ui.index_definitions, '' '') LIKE ''%%'' || c.column_name || ''%%''
                            THEN true
                            ELSE false
                        END as has_unique_index,
                        c.is_updatable,
                        c.table_schema,
                        pg_class.oid AS table_id,
                        pg_attribute.attnum AS column_id
                    FROM information_schema.columns c
                    JOIN information_schema.tables t
                        ON c.table_name = t.table_name
                        AND c.table_schema = t.table_schema
                    LEFT JOIN primary_keys pk
                        ON c.table_name = pk.table_name
                        AND c.column_name = pk.column_name
                        AND c.table_schema = pk.table_schema
                    LEFT JOIN foreign_keys fk
                        ON c.table_name = fk.table_name
                        AND c.column_name = fk.column_name
                        AND c.table_schema = fk.table_schema
                    LEFT JOIN unique_indexes ui
                        ON c.table_schema = ui.schemaname
                        AND c.table_name = ui.tablename
                    JOIN pg_class ON pg_class.relname = c.table_name
                        AND pg_class.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = c.table_schema)
                    JOIN pg_attribute ON pg_attribute.attrelid = pg_class.oid
                        AND pg_attribute.attname = c.column_name
                    WHERE c.table_schema IN (%L, ''auth'')
                    ORDER BY
                        c.table_name,
                        c.ordinal_position;',
                    schema_name,
                    schema_name
                          );

            -- Execute the materialized view creation
            BEGIN
                EXECUTE view_query;
            -- EXCEPTION
            --     WHEN duplicate_table THEN
            --         -- If the materialized view already exists, drop it and recreate
            --         EXECUTE format('DROP MATERIALIZED VIEW IF EXISTS %I.schema_columns', schema_name);
            --         EXECUTE view_query;
            END;

            RAISE NOTICE 'Created materialized view schema_columns in schema %', schema_name;
        END LOOP;
END;
$$ LANGUAGE plpgsql;


-- FUNCTION TO CREATE CONFIGURATION VIEWS ----------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION create_configuration_schema_views(schema_list TEXT[])
RETURNS void AS $$
DECLARE
    schema_name text;
    table_record record;
BEGIN
    -- Loop through each schema
    FOREACH schema_name IN ARRAY schema_list
    LOOP
        -- Get all tables from the configuration schema
        FOR table_record IN 
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'configuration' 
            AND table_type = 'BASE TABLE'
        LOOP
            -- Create or replace view in the current schema
            EXECUTE format(
                'CREATE OR REPLACE VIEW %I.%I AS 
                 SELECT * FROM configuration.%I 
                 WHERE schema = %L',
                schema_name,
                table_record.table_name,
                table_record.table_name,
                schema_name
            );
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- DEFAULT VALUES FUNCTION FOR NEW INSTANCE ----------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION initialize_schema_data(schema_list TEXT[])
RETURNS VOID AS $$
DECLARE
    schema_name TEXT;
BEGIN
    -- Loop over the array of schema names
    FOREACH schema_name IN ARRAY schema_list
    LOOP
        -- Insert roles
        EXECUTE format(
            'INSERT INTO configuration.role (schema, name)
             VALUES
               (%L, ''admin''),
               (%L, ''underwriter''),
               (%L, ''agent''),
               (%L, ''auditor''),
               (%L, ''borrower'')
             ON CONFLICT (schema, name) DO NOTHING;',
            schema_name, schema_name, schema_name, schema_name, schema_name
        );

        -- Insert task statuses
        EXECUTE format(
            'INSERT INTO %I.task_status (id, label, updated_at)
             VALUES
               (0, ''Backlog'', NOW()),
               (1, ''Todo'', NOW()),
               (2, ''In Progress'', NOW()),
               (3, ''In Review'', NOW()),
               (4, ''Done'', NOW()),
               (5, ''Cancelled'', NOW())
             ON CONFLICT (id) DO NOTHING;',
            schema_name
        );

        -- Insert task priorities
        EXECUTE format(
            'INSERT INTO %I.task_priority (id, label, updated_at)
             VALUES
               (0, ''Urgent'', NOW()),
               (1, ''High'', NOW()),
               (2, ''Medium'', NOW()),
               (3, ''Low'', NOW()),
               (4, ''No Priority'', NOW())
             ON CONFLICT (id) DO NOTHING;',
            schema_name
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION create_admin_views(schemas TEXT[])
RETURNS VOID AS $$
DECLARE
    schema_name TEXT;
    view_name TEXT;
    admin_view_name TEXT;
    view_definition TEXT;
BEGIN
    -- Loop through each schema provided in the input
    FOREACH schema_name IN ARRAY schemas LOOP
        -- Search for views starting with '_p_' or '_c_' in the current schema
        FOR view_name IN
            SELECT table_name
            FROM information_schema.views
            WHERE table_schema = schema_name
              AND (table_name LIKE '_p_%' OR table_name LIKE '_c_%')
        LOOP
            -- Construct the admin view name
            admin_view_name := view_name || '__admin';
            
            -- Get the definition of the existing view
            SELECT definition
            INTO view_definition
            FROM pg_views
            WHERE schemaname = schema_name
              AND viewname = view_name;

            -- Use dynamic SQL to create or replace the admin view
            EXECUTE format(
                'CREATE OR REPLACE VIEW %I.%I AS %s',
                schema_name,
                admin_view_name,
                view_definition
            );
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_role_permissions(schemas TEXT[]) RETURNS VOID AS $$
DECLARE
    schema_name TEXT;
    role_names TEXT;
    dynamic_sql TEXT;
BEGIN
    -- Loop through each schema provided in the array
    FOREACH schema_name IN ARRAY schemas LOOP
            -- Fetch all role names dynamically for the given schema
            SELECT string_agg(
            'COALESCE(bool_or(rc.name IS NOT NULL) FILTER (WHERE rv.role_name = ' || quote_literal(name) || '), false) AS ' || quote_ident(name),
            ', '
                   )
            INTO role_names
            FROM (SELECT name FROM configuration.role WHERE configuration.role.schema::TEXT = schema_name) roles;

            -- Construct the dynamic SQL query for creating the view
            dynamic_sql := format('
    CREATE OR REPLACE VIEW %I.column_role_permission AS
    SELECT
        c.*,
        %s
    FROM configuration.column c
    LEFT JOIN configuration.role_column rc
        ON c.schema = rc.schema
        AND c.view_name = rc.view_name
        AND c.name = rc.name
    LEFT JOIN configuration.role_view rv
        ON rv.name = rc.role_view_name
        AND rv.schema::TEXT = rc.schema::TEXT
    WHERE c.schema = %L  -- Substituting schema name dynamically
    GROUP BY c.schema, c.view_name, c.name;',
                                  schema_name, role_names, schema_name);

            -- Execute the generated SQL
            EXECUTE dynamic_sql;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

-- This is needed for postgREST to preoperly identify one to one relations
CREATE OR REPLACE FUNCTION add_unique_indexes(
    schema_names TEXT[], 
    table_column_pairs TEXT[][]
) RETURNS VOID AS
$$
DECLARE
    v_schema_name TEXT;
    v_table_name TEXT;
    v_column_name TEXT;
    v_constraint_name TEXT;
    v_query TEXT;
    v_constraint_exists BOOLEAN;
    i INTEGER;
BEGIN
    -- Loop through each schema
    FOREACH v_schema_name IN ARRAY schema_names LOOP
        -- Loop through table/column pairs using array index
        FOR i IN 1..array_length(table_column_pairs, 1) LOOP
            -- Extract table and column names from the pair
            v_table_name := table_column_pairs[i][1];
            v_column_name := table_column_pairs[i][2];
            
            -- Generate constraint name
            v_constraint_name := format('%I_%I_unique_idx', v_table_name, v_column_name);
            
            -- Check if the constraint already exists
            SELECT EXISTS (
                SELECT 1 
                FROM information_schema.table_constraints tc
                WHERE tc.table_schema = v_schema_name 
                AND tc.table_name = v_table_name 
                AND tc.constraint_name = v_constraint_name
                AND tc.constraint_type = 'UNIQUE'
            ) INTO v_constraint_exists;
            
            -- Add the constraint only if it does not exist
            IF NOT v_constraint_exists THEN
                v_query := format(
                    'ALTER TABLE %I.%I ADD CONSTRAINT %I UNIQUE (%I);',
                    v_schema_name, v_table_name, v_constraint_name, v_column_name
                );

                -- Execute the query
                EXECUTE v_query;
            END IF;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- FUNCTION TO SET UP NEW SCHMA WITH ALL VIEWS ----------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_up_schemas(schema_list TEXT[])
RETURNS void AS $$
BEGIN
    PERFORM initialize_schema_data(schema_list);

    PERFORM create_default_roles_and_grant_access_to_schemas(schema_list);

    PERFORM create_configuration_schema_views(schema_list);

    PERFORM create_schema_columns_views(schema_list);

    PERFORM create_table_master_views(schema_list);

    PERFORM create_auth_views(schema_list);

    PERFORM create_admin_views(schema_list);

    PERFORM create_role_permissions(schema_list);

    PERFORM add_unique_indexes(schema_list, ARRAY[ARRAY['opportunity', 'active_deal_id']]::TEXT[][]);
END;
$$ LANGUAGE plpgsql;

-- SETUP FOUNDATION ----------------------------------------------------------------------------------------------------------------
SELECT set_up_schemas(ARRAY['foundation']::TEXT[]);