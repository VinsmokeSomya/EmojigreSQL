EXTENSION = emojigresql
DATA = emojigresql--1.0.sql
# Generated emoji chars file
GENERATED_CHARS_SQL = emojigresql-chars.sql

REGRESS = test
EXTRA_CLEAN = $(DATA) $(GENERATED_CHARS_SQL)

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

all: $(DATA)

SQL_SRC = \
  complain_header.sql \
  TABLES/chars.sql \
  FUNCTIONS/encode.sql \
  FUNCTIONS/decode.sql \
  FUNCTIONS/from_text.sql \
  FUNCTIONS/to_text.sql

# Original rule (for Linux/Unix env like inside Docker)
$(DATA): $(SQL_SRC)
	sh ./fetch-chars.sh
	cat $(SQL_SRC) > $@
	cat $(GENERATED_CHARS_SQL) >> $@

# Clean rule might need adjustment depending on environment
# EXTRA_CLEAN already handles generated files
