
CREATE OR REPLACE FUNCTION if_modified_func() RETURNS TRIGGER AS $body$
DECLARE
  audit_row events;
  query_text text;
  all_rows json[] := '{}';
  anyrow RECORD;
BEGIN
  IF TG_WHEN <> 'AFTER' THEN
     RAISE EXCEPTION 'if_modified_func() may only run as an AFTER trigger';
  END IF;

  audit_row = ROW (
              TG_TABLE_SCHEMA::TEXT,               -- nspname
              TG_TABLE_NAME::TEXT,                 -- relname
              session_user::TEXT,                  -- usename
              transaction_timestamp(),             -- trans_ts
              txid_current(),                      -- trans_id
              1,                                   -- trans_sq
              TG_OP,                               -- operation
              NULL                                 -- rowdata
  );

  IF    (TG_OP = 'UPDATE') THEN
    audit_row.rowdata = array_to_json(ARRAY[row_to_json(OLD), row_to_json(NEW)]);  -- save both rows
  ELSIF (TG_OP = 'DELETE') THEN
    audit_row.rowdata = row_to_json(OLD);                                            -- save old row
  ELSIF (TG_OP = 'INSERT') THEN
    audit_row.rowdata = row_to_json(NEW);                                            -- save new row
  ELSIF (TG_OP = 'TRUNCATE') THEN                                                    -- save all rows
    query_text = 'SELECT *  FROM ' || quote_ident(TG_TABLE_SCHEMA) || '.' || quote_ident(TG_TABLE_NAME) ;
    FOR anyrow IN EXECUTE query_text LOOP
        all_rows =  all_rows || row_to_json(anyrow);
    END LOOP;
    audit_row.rowdata = array_to_json(all_rows);
  ELSE
    RAISE EXCEPTION '[if_modified_func] - Trigger func added as trigger for unhandled case: %, %',TG_OP, TG_LEVEL;
    RETURN NULL;
  END IF;

  -- multiple events in the same transaction must be ordered
  LOOP
    BEGIN
      INSERT INTO events VALUES (audit_row.*);
      EXIT; -- successful insert
    EXCEPTION WHEN unique_violation THEN
      -- add and loop to try the UPDATE again
      audit_row.trans_sq :=  audit_row.trans_sq + 1;
    END;
  END LOOP;
  RETURN NULL;
END;
$body$
LANGUAGE plpgsql
SECURITY DEFINER;


COMMENT ON FUNCTION if_modified_func() IS $body$
Track changes to a table at the row level.
Note that the user name logged is the login role for the session. The audit trigger
cannot obtain the active role because it is reset by the SECURITY DEFINER invocation
of the audit trigger its self.
$body$;

