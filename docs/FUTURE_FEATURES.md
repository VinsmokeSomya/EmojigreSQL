# 🚀 Future Feature Ideas for EmojigreSQL

This file lists potential ideas for enhancing the EmojigreSQL extension in future versions.

## Customization & Flexibility ✨

*   **Configurable Emoji Set:** Allow users to provide their own mapping table (user-defined table or config file) instead of the fixed Unicode set. This could enable:
    *   Using newer emoji sets.
    *   Using specific subsets (animals, faces, etc.).
    *   Using non-emoji character sets.
*   **Support Different Unicode Emoji Versions:** Update fetch/build scripts to allow specifying different Unicode Emoji version URLs (e.g., v14.0, v15.0).
*   **Variable Bit Length:** Explore options for different bit lengths (e.g., 8-bit for 256 emojis, 11-bit for 2048), trading off emoji count vs. output length.

## Enhanced Features & Error Handling 💪

*   **Stronger Checksum:** Optionally add support for stronger checksum algorithms (e.g., CRC32 via C or `pgcrypto`) for increased data integrity, likely increasing output length.
*   **Checksum for Text Functions:** Add an optional checksum mechanism to `from_text`/`to_text` functions.
*   **Validation Function:** Implement `emojigresql.is_valid(text)` to quickly check if a string appears to be a valid encoded string without a full decode.
*   **Error Reporting Decode:** Provide a decode variant or separate function that returns specific error codes/messages (e.g., 'invalid checksum', 'unknown character') instead of just `NULL`.

## Encoding/Decoding Variants 🎭

*   **Case-Insensitive Decode:** Option to allow decoding if emoji case has been altered (less common).
*   **URL-Safe Variant:** Create `encode_urlsafe` using a subset of characters guaranteed safe for URLs without encoding.
*   **Different Base Encodings:** Explore Base64-like variants using the emoji set (e.g., mapping 6 bits per emoji).
*   **Length Prefixing:** Option to add a character/emoji indicating the original byte length.

## Usability & Integration 🧩

*   **Data Type Casting:** Create PostgreSQL `CAST`s for easier conversion between `bytea`/`text` and a hypothetical `emojitext` type (e.g., `SELECT '\xDEADBEEF'::bytea::emojitext;`).
*   **Aggregate Functions:** Implement aggregate functions like `emoji_agg(bytea)` to combine and encode multiple rows.
*   **Helper Functions:**
    *   `emojigresql.get_emoji_set() -> TABLE(...)`: Return the current emoji mapping table.
    *   `emojigresql.version() -> text`: Return the extension version.

## Performance ⚡

*   **(Optional) C Implementation:** Rewrite core encode/decode logic in C for significant speedups on large data (loses "pure SQL" nature).

## Security & Robustness 🔒

*   **Salted Checksum:** Allow incorporating an optional `salt` into the checksum calculation.

## Tooling & Documentation 🛠️

*   **Client-Side Libraries:** Develop helper libraries (Python, JS, etc.) for client-side encoding/decoding.
*   **Formal Documentation:** Create dedicated documentation (Sphinx, MkDocs, etc.), possibly hosted on GitHub Pages.
*   **Benchmarking:** Provide performance benchmarks against Base64 and other methods.
*   **PGXN Packaging:** Package for easy installation via the PostgreSQL Extension Network.
*   **More Robust Testing:** Expand the SQL test suite (`sql/test.sql`) to cover more edge cases and invalid inputs.
*   **Continuous Integration (CI):** Set up GitHub Actions for automated testing against different PostgreSQL versions. 