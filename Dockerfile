# Use an official PostgreSQL runtime as a parent image
FROM postgres:16-alpine

# Install build dependencies (will be removed later)
RUN apk add --no-cache --virtual .build-deps \
    build-base \
    postgresql-dev \
    git \
    curl \
    make \
    gcc \
    musl-dev

# Create source directory and set as working directory
RUN mkdir /src
WORKDIR /src

# Copy the local code into the container
COPY . /src

# Fix line endings for script and make executable
RUN sed -i 's/\r$//' fetch-chars.sh && chmod +x fetch-chars.sh

# Build/install the extension using Makefile and remove build dependencies
RUN make install && \
    apk del .build-deps

WORKDIR /

# Optional: Explain how to auto-enable the extension using init scripts
# Mount an init script to /docker-entrypoint-initdb.d/ to automatically run
# 'CREATE EXTENSION IF NOT EXISTS emojigresql;' on first DB startup.
# Example script (e.g., init.sh):
# #!/bin/bash
# set -e
# psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
#     CREATE EXTENSION IF NOT EXISTS emojigresql;
# EOSQL

# Expose the default PostgreSQL port
EXPOSE 5432

# Default command to run postgres is inherited from the base image 