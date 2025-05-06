<!-- RELEASE_NOTES.md -->

# 🎉 EmojigreSQL v1.0.4 🎉


## 📜 Overview

EmojigreSQL is a pure SQL PostgreSQL extension that allows you to seamlessly encode and decode data into colorful emoji sequences! 🐘➡️💖

*   **Encode:** Convert `bytea` (binary data) or `text` into a sequence of emojis.
*   **Decode:** Convert a sequence of emojis back into the original `bytea` or `text`.
*   **Lookup Table:** Utilizes a table of 1024 standard emojis, each mapping to a unique 10-bit sequence.
*   **Validation:** Includes a simple checksum within a header emoji to help detect incomplete or corrupted sequences during decoding.

## 🚀 Key Features

*   **Pure SQL:** No external dependencies needed besides PostgreSQL itself! ✅
*   **Binary & Text:** Handles both `bytea` and `text` data types.
*   **Checksum:** Basic integrity check for decoding.
*   **Docker Support:** Easy setup using the provided `Dockerfile` and published container image.

## 🐳 Get Started (Docker - Recommended)

```bash
# Pull the image for this release
docker pull ghcr.io/vinsmokesomya/emojigresql:v1.0.4
```

```bash
# Run the container (replace YOUR_STRONG_PASSWORD)
docker run --name emojigresql-db -e POSTGRES_PASSWORD=YOUR_STRONG_PASSWORD -p 5432:5432 -d ghcr.io/vinsmokesomya/emojigresql:v1.0.4
```

```bash
# Connect and enable the extension
docker exec -it emojigresql-db psql -U postgres
```

```bash
# Inside psql:
CREATE EXTENSION emojigresql;
```

See the main `README.md` for more detailed installation and usage instructions.

Enjoy weaving emojis into your data! 🥳 