CREATE OR REPLACE FUNCTION emojigresql.to_text(text)
RETURNS text
IMMUTABLE
STRICT
LANGUAGE sql AS $$
SELECT convert_from(emojigresql.decode($1),'utf8')
$$;
