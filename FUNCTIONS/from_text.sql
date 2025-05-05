CREATE OR REPLACE FUNCTION emojigresql.from_text(text)
RETURNS text
IMMUTABLE
STRICT
LANGUAGE sql AS $$
SELECT emojigresql.encode(convert_to($1,'utf8'))
$$;
