-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION emoji" to load this file. \quit
CREATE TABLE emojigresql.chars (
emoji_id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
emoji_bits varbit NOT NULL GENERATED ALWAYS AS ((emoji_id-1)::bit(10)) STORED,
emoji_char char NOT NULL,
PRIMARY KEY (emoji_id),
UNIQUE (emoji_bits),
UNIQUE (emoji_char)
);
CREATE OR REPLACE FUNCTION emojigresql.encode(bytea)
RETURNS text
IMMUTABLE
STRICT
LANGUAGE sql AS $$
WITH
q1 AS (
  SELECT
    $1 AS input,
    10 AS nbits,
    sha512($1)
),
q2 AS (
  SELECT
    right(input::text,-1)::varbit AS bitstring
  FROM q1
),
q3 AS (
  SELECT
    repeat('0',nbits-length(bitstring)%nbits)::varbit || bitstring AS padded_bitstring
  FROM q1,q2
),
q4 AS (
  SELECT array_agg(substring(padded_bitstring,1+i*nbits,nbits)) AS emoji_bitss
  FROM q1
  CROSS JOIN q3
  CROSS JOIN LATERAL generate_series(0,length(padded_bitstring)/nbits-1) AS i
)
SELECT
  checksum.emoji_char || array_to_string(array_agg(chars.emoji_char ORDER BY ORDINALITY),'')
FROM q1
CROSS JOIN q4
CROSS JOIN unnest(emoji_bitss) WITH ORDINALITY
JOIN emojigresql.chars ON chars.emoji_bits = unnest
JOIN emojigresql.chars AS checksum ON checksum.emoji_bits = ((length(input)*8)%10 <= 2)::integer::bit||get_byte(sha512,0)::bit(8)||get_byte(sha512,1)::bit(1)
GROUP BY checksum.emoji_char
$$;
CREATE OR REPLACE FUNCTION emojigresql.decode(text)
RETURNS bytea
IMMUTABLE
STRICT
LANGUAGE sql AS $$
WITH
q1 AS (
  SELECT
    $1 AS input,
    10 AS nbits
),
q2 AS (
  SELECT string_agg(chars.emoji_bits::text,'' ORDER BY i)::varbit AS bits
  FROM q1
  CROSS JOIN generate_series(1,length(input)-1) AS i
  JOIN emojigresql.chars ON chars.emoji_char = substr(input,1+i,1)
),
q3 AS (
  SELECT decode(string_agg(lpad(to_hex(substring(bits,1+length(bits)%8+i*8,8)::bit(8)::integer),2,'0'),'' ORDER BY i),'hex') AS padded
  FROM q2
  CROSS JOIN generate_series(0,length(bits)/8-1) AS i
),
q4 AS (
  SELECT
    CASE
      WHEN get_bit(emoji_bits,0) = 1 AND get_byte(padded,0) = 0 THEN substring(padded,2)
      WHEN get_bit(emoji_bits,0) = 0 THEN padded
    END AS decoded,
    substring(emoji_bits,2) AS checksum
  FROM q1
  CROSS JOIN q3
  JOIN emojigresql.chars AS checksum ON checksum.emoji_char = substr(input,1,1)
),
q5 AS (
  SELECT
    decoded,
    checksum,
    sha512(decoded)
  FROM q4
)
SELECT decoded
FROM q5
WHERE checksum = get_byte(sha512,0)::bit(8)||get_byte(sha512,1)::bit(1)
$$;
CREATE OR REPLACE FUNCTION emojigresql.from_text(text)
RETURNS text
IMMUTABLE
STRICT
LANGUAGE sql AS $$
SELECT emojigresql.encode(convert_to($1,'utf8'))
$$;
CREATE OR REPLACE FUNCTION emojigresql.to_text(text)
RETURNS text
IMMUTABLE
STRICT
LANGUAGE sql AS $$
SELECT convert_from(emojigresql.decode($1),'utf8')
$$;
