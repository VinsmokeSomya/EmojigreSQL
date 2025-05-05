# 🐘 EmojigreSQL Documentation

## 1. Introduction ℹ️

EmojigreSQL is a pure SQL PostgreSQL extension that provides functions to encode binary data (`bytea`) or text (`text`) into a sequence of emojis, and decode them back. It uses a fixed lookup table of 1024 emojis and includes a simple checksum for basic data integrity verification.

## 2. Installation ⚙️

Please refer to the [README.md](./README.md) for detailed installation instructions, covering both the recommended Docker method and manual installation steps for different operating systems.

**Quick Summary:**

*   **Docker (Recommended):** Build the image using `docker build` and run it using `docker run`. See README for details.
*   **Manual (Linux/macOS/WSL/Git Bash):** Requires `make` and PostgreSQL development headers. Use `make && sudo make install`.
*   **Manual (Windows Native):** Requires PowerShell. Run `.\build.ps1` and manually copy the generated `.sql` and `.control` files to your PostgreSQL installation.

## 3. Usage 💡

Once the extension files are installed (either manually or via the Docker image build), you need to enable the extension within the specific database you want to use it in.

Connect to your database using `psql` or another client and run:

```sql
CREATE EXTENSION emojigresql;
```

This command creates the `emojigresql` schema and the necessary functions and tables.

## 4. API Reference 📚

The extension provides the following SQL functions under the `emojigresql` schema:

### `emojigresql.encode(input_bytea bytea) → text`

*   **Description:** Encodes binary data (`bytea`) into a string of emojis (`text`).
*   **Details:** The input `bytea` is treated as a stream of bits. It's divided into 10-bit chunks. Each chunk maps to an emoji from the internal lookup table. A header emoji is prepended, containing a flag for padding and a 9-bit checksum of the input data.
*   **Example:**
    ```sql
    SELECT emojigresql.encode('\x0123456789abcdef'::bytea);
    -- Result: '👦😀🥺🪀🦠🖖🌌🥚' (Example output, actual emojis may vary slightly)
    ```

### `emojigresql.decode(input_emojis text) → bytea`

*   **Description:** Decodes a string of emojis (`text`) previously encoded by `emojigresql.encode` back into binary data (`bytea`).
*   **Details:** It reads the header emoji to verify the checksum against the decoded data. If the checksum is invalid (indicating potential corruption or modification), the function returns `NULL`. It uses the remaining emojis to reconstruct the original bit sequence and converts it back to `bytea`.
*   **Example:**
    ```sql
    SELECT emojigresql.decode('👦😀🥺🪀🦠🖖🌌🥚');
    -- Result: '\x0123456789abcdef'

    SELECT emojigresql.decode('👦😀🥺🪀🦠🖖🌌'); -- Incorrect/incomplete input
    -- Result: NULL
    ```

### `emojigresql.from_text(input_text text) → text`

*   **Description:** Encodes a standard UTF-8 text string into an emoji string.
*   **Details:** This is a convenience function. It first converts the input `text` to `bytea` using UTF-8 encoding, then calls `emojigresql.encode()` on the result.
*   **Example:**
    ```sql
    SELECT emojigresql.from_text('Hello 🌎!');
    -- Result: '🦳🥺🐞🕰🎐🎗📷🧂🎖🫖' (Example output)
    ```

### `emojigresql.to_text(input_emojis text) → text`

*   **Description:** Decodes an emoji string (presumably created by `emojigresql.from_text`) back into a standard UTF-8 text string.
*   **Details:** This is a convenience function. It calls `emojigresql.decode()` on the input emoji string to get the `bytea` result, and then converts that `bytea` back to `text` assuming UTF-8 encoding. If the decode step returns `NULL` (e.g., due to checksum failure), this function will also return `NULL`.
*   **Example:**
    ```sql
    SELECT emojigresql.to_text('🦳🥺🐞🕰🎐🎗📷🧂🎖🫖');
    -- Result: 'Hello 🌎!'
    ```

## 5. Technical Details 🛠️

*   **Encoding:** Uses a fixed lookup table (`emojigresql.chars`) containing the first 1024 emojis from the Unicode 13.1 emoji test file. Each emoji maps to a unique 10-bit value (0-1023).
*   **Header/Checksum:** The first emoji in an encoded string acts as a header. The first bit indicates if zero-padding was added to the *end* of the original bitstream to make it a multiple of 10 bits. The remaining 9 bits are derived from the first 9 bits of the SHA512 hash of the original input `bytea`, providing a basic integrity check.
*   **Pure SQL:** The extension logic is written entirely in SQL functions and relies on standard PostgreSQL features.

## 6. Building from Source 🧱

Refer to the [README.md](./README.md) for instructions on using `make` (Linux/macOS/WSL/Git Bash) or `build.ps1` (Windows Native PowerShell) to prepare the extension files from the source code.

## 7. Contributing 🙌

Contributions are welcome! Please refer to the repository guidelines (if any) or open an issue to discuss potential changes or features. 