/*
    Migration script from version 0.1.10 to 0.1.10 (or higher if tool doesn't find other migration scripts)
 */

CREATE TABLE IF NOT EXISTS {schema_name}.ddl_changes_log
(
    ddl_change_id SERIAL NOT NULL,
    dpl_ev_id INTEGER,
    ddl_change_user NAME DEFAULT current_user,
    ddl_change TEXT,
    ddl_change_txid BIGINT DEFAULT txid_current(),
    ddl_change_created TIMESTAMP DEFAULT NOW(),
    CONSTRAINT ddl_change_pkey PRIMARY KEY (ddl_change_id)
);
COMMENT ON TABLE {schema_name}.ddl_changes_log IS
    'Log of changes of DDL in database linked to deployment events if happened through deployment';

DROP EVENT TRIGGER IF EXISTS ddl_change_trigger;
CREATE EVENT TRIGGER ddl_change_trigger
ON ddl_command_end
WHEN TAG IN (
'ALTER AGGREGATE',
'ALTER COLLATION',
'ALTER CONVERSION',
'ALTER DOMAIN',
'ALTER EXTENSION',
'ALTER FOREIGN DATA WRAPPER',
'ALTER FOREIGN TABLE',
'ALTER FUNCTION',
'ALTER LANGUAGE',
'ALTER OPERATOR',
'ALTER OPERATOR CLASS',
'ALTER OPERATOR FAMILY',
'ALTER SCHEMA',
'ALTER SEQUENCE',
'ALTER SERVER',
'ALTER TABLE',
'ALTER TEXT SEARCH CONFIGURATION',
'ALTER TEXT SEARCH DICTIONARY',
'ALTER TEXT SEARCH PARSER',
'ALTER TEXT SEARCH TEMPLATE',
'ALTER TRIGGER',
'ALTER TYPE',
'ALTER USER MAPPING',
'ALTER VIEW',
'CREATE AGGREGATE',
'CREATE CAST',
'CREATE COLLATION',
'CREATE CONVERSION',
'CREATE DOMAIN',
'CREATE EXTENSION',
'CREATE FOREIGN DATA WRAPPER',
'CREATE FOREIGN TABLE',
'CREATE FUNCTION',
'CREATE INDEX',
'CREATE LANGUAGE',
'CREATE OPERATOR',
'CREATE OPERATOR CLASS',
'CREATE OPERATOR FAMILY',
'CREATE RULE',
'CREATE SCHEMA',
'CREATE SEQUENCE',
'CREATE SERVER',
'CREATE TABLE',
'CREATE TABLE AS',
'CREATE TEXT SEARCH CONFIGURATION',
'CREATE TEXT SEARCH DICTIONARY',
'CREATE TEXT SEARCH PARSER',
'CREATE TEXT SEARCH TEMPLATE',
'CREATE TRIGGER',
'CREATE TYPE',
'CREATE USER MAPPING',
'CREATE VIEW',
'DROP AGGREGATE',
'DROP CAST',
'DROP COLLATION',
'DROP CONVERSION',
'DROP DOMAIN',
'DROP EXTENSION',
'DROP FOREIGN DATA WRAPPER',
'DROP FOREIGN TABLE',
'DROP FUNCTION',
'DROP INDEX',
'DROP LANGUAGE',
'DROP OPERATOR',
'DROP OPERATOR CLASS',
'DROP OPERATOR FAMILY',
'DROP OWNED',
'DROP RULE',
'DROP SCHEMA',
'DROP SEQUENCE',
'DROP SERVER',
'DROP TABLE',
'DROP TEXT SEARCH CONFIGURATION',
'DROP TEXT SEARCH DICTIONARY',
'DROP TEXT SEARCH PARSER',
'DROP TEXT SEARCH TEMPLATE',
'DROP TRIGGER',
'DROP TYPE',
'DROP USER MAPPING',
'DROP VIEW')
EXECUTE PROCEDURE {schema_name}._log_ddl_change();