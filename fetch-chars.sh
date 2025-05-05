#!/bin/sh
# Output file for generated INSERT statements
FILE=emojigresql-chars.sql

# Schema name
SCHEMA=emojigresql

if [ ! -f "$FILE" ]; then
  echo "❗️ Modifying the emoji list can cause compatibility problems. ❗️"
  echo "🌐 Fetching emoji list from unicode.org..."
  curl -s https://unicode.org/Public/emoji/13.1/emoji-test.txt \
  | grep -E '^[0-9A-F]{4,5} +;' \
  | head -n 1024 \
  | awk -v schema="$SCHEMA" '{print "INSERT INTO " schema ".chars (emoji_char) VALUES ('\''"$5"'\'');"}' > "$FILE"
  echo "✅ Generated $FILE"
fi
