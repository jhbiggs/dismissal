CREATE OR REPLACE FUNCTION notify_event() RETURNS TRIGGER AS $$

DECLARE
  data json;
  notification json;

BEGIN

  -- Convert the old or new row to JSON, based on the kind of action.
  -- Action = DELETE? -> OLD row
  -- Action = INSERT or UPDATE? -> NEW row
  IF (TG_OP = 'DELETE') THEN
    data = row_to_json(OLD);
  ELSE
    data = row_to_json(NEW);
  END IF;

  -- Contruct the notification as a JSON string.
  notification = json_build_object(
    'table', TG_TABLE_NAME,
    'action', TG_OP,
    'data', data
  );

  -- Execute pg_notify(channel, notification)
  PERFORM pg_notify('events', notification::text);

  -- Result is ignored since this is an AFTER trigger
  RETURN NULL;
END;

$$ LANGUAGE plpgsql;