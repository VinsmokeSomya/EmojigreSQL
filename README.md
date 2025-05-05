<h1 align="center" id="top">🐘 EmojigreSQL 🐘</h1>

<p align="center">
  <strong>A pure SQL PostgreSQL extension to weave binary data and text into the colorful tapestry of emojis! ✨</strong>
</p>

---

## 📜 Table of Contents

1.  [About](#about) ℹ️
2.  [Dependencies](#dependencies) 🔗
3.  [Installation & Usage (Docker - Recommended)](#installation-docker) 🐳
4.  [Installation (Manual)](#installation-manual) ⚙️
5.  [Usage](#usage) 💡
6.  [Documentation](#documentation) 📚
7.  [Project Structure](#file-structure) 📁

---

<h2 id="about">ℹ️ 1. About</h2>

`EmojigreSQL` is a **pure SQL** [PostgreSQL](https://www.postgresql.org/) extension designed to seamlessly encode/decode `bytea` (binary data) and `text` to/from emojis.

It utilizes a lookup table constructed from the first 1024 emojis sourced from the [Unicode Emoji Test File v13.1](https://unicode.org/Public/emoji/13.1/emoji-test.txt). Each emoji in this table uniquely maps to a 10-bit sequence.

**How it works:**
1.  Input data is fragmented into 10-bit chunks.
2.  Each chunk is mapped to its corresponding emoji from the lookup table.
3.  The **first emoji** in the resulting sequence acts as a header:
    *   The first bit indicates if zero-padding was applied (1 for true).
    *   The remaining 9 bits form a checksum derived from the input data.

> **Note:** If the checksum is invalid during the decoding process (e.g., due to data corruption or an incomplete sequence), the function will return `NULL`.

---

<h2 id="dependencies">🔗 2. Dependencies</h2>

✅ None! This extension is self-contained.

---

<h2 id="installation-docker">🐳 3a. Installation & Usage (Docker - Recommended)</h2>

This is the easiest way to get started, as it handles all dependencies and build steps within a container.

1.  **Ensure Docker Desktop is running.**

2.  **Build the Image:**
    Open your terminal in the project root directory and run:
    ```bash
    docker build -t emojigresql-image .
    ```

3.  **Run the Container:**
    ```bash
    # Replace YOUR_STRONG_PASSWORD with a password of your choice
    docker run --name emojigresql-db -e POSTGRES_PASSWORD=YOUR_STRONG_PASSWORD -p 5432:5432 -d emojigresql-image
    ```

4.  **Enable the Extension:**
    Connect to the running container's PostgreSQL instance and enable the extension for your desired database (e.g., the default `postgres` database):
    ```bash
    # Connect to psql inside the container (enter your password when prompted)
    docker exec -it emojigresql-db psql -U postgres

    # Inside psql (prompt looks like postgres=#), run:
    CREATE EXTENSION emojigresql;

    # You can now exit psql by typing \q
    ```

5.  **Connect:**
    You can now connect to the database running in Docker using any standard PostgreSQL client with these details:
    *   **Host:** `localhost`
    *   **Port:** `5432`
    *   **Database:** `postgres` (or any other database you create)
    *   **User:** `postgres`
    *   **Password:** The `YOUR_STRONG_PASSWORD` you set in step 3.
    *   **Connection URI:** `postgresql://postgres:YOUR_STRONG_PASSWORD@localhost:5432/postgres`

---

<h2 id="installation-manual">⚙️ 4. Installation (Manual)</h2>

There are two ways to manually install the extension if you have PostgreSQL installed locally, depending on your operating system and available tools.

**4a. For Linux/macOS (or Windows with Git Bash/WSL/MSYS2)**

This method uses the standard `make` utility.

*   **Prerequisites:**
    *   `git`, `curl`
    *   `make` (usually pre-installed or available via package managers like `apt`, `yum`, `brew`)
    *   PostgreSQL server development package (e.g., `postgresql-server-dev-XX`, `postgresqlXX-devel`) for your PostgreSQL version.
    *   Ensure `pg_config` from your PostgreSQL installation is in your system's PATH.

*   **Steps:**
    ```bash
    # 1. Clone the repository
    git clone https://github.com/VinsmokeSomya/EmojigreSQL.git

    # 2. Navigate into the project directory
    cd EmojigreSQL

    # 3. Compile/Generate the extension files
    make

    # 4. Install the extension (may require sudo/admin privileges)
    # On Linux/macOS:
    sudo make install
    # On Windows (Git Bash/WSL run as Admin):
    # make install

    # 5. (Optional) Run the installation checks
    make installcheck
    ```

**4b. For Windows Native (CMD/PowerShell)**

This method uses a PowerShell script to generate the necessary SQL file, avoiding the need for `make` or a Linux-like environment. It does *not* automatically install the files into your PostgreSQL directory.

*   **Prerequisites:**
    *   `git`
    *   PowerShell (usually built-in)
    *   PostgreSQL server installed (development headers not strictly required for this script, but needed to *use* the extension).

*   **Steps:**
    ```powershell
    # 1. Clone the repository
    git clone https://github.com/VinsmokeSomya/EmojigreSQL.git

    # 2. Navigate into the project directory
    cd EmojigreSQL

    # 3. Run the PowerShell build script
    .\build.ps1
    ```
*   **Manual File Installation:** After the script runs successfully, it will create `emojigresql--1.0.sql` and potentially `emojigresql-chars.sql`.
    You need to manually copy these files, along with `emojigresql.control`, to your PostgreSQL installation's extension directory.
    1.  Find your PostgreSQL share directory (often `C:\Program Files\PostgreSQL\XX\share`). You can run `pg_config --sharedir` in a CMD/PowerShell if `pg_config` is in your PATH to find it.
    2.  Copy `emojigresql.control` to the `extension` sub-directory (e.g., `...\share\extension`).
    3.  Copy `emojigresql--1.0.sql` to the `extension` sub-directory.
    *(Administrative privileges will likely be required to copy files into the Program Files directory)*

*   **Enable in Database:** Once the files are copied, connect to your database using `psql` or another client and run `CREATE EXTENSION emojigresql;`.

---

<h2 id="usage">💡 5. Usage</h2>

Activate the extension within your PostgreSQL database:

1.  Connect to your database using `psql` or your preferred client.
2.  Execute the following SQL command:

```sql
CREATE EXTENSION emoji;
```

Now you're ready to use the `EmojigreSQL` functions!

---

<h2 id="documentation">📚 6. DOCUMENTATION</h2>

Detailed documentation for all functions (`encode`, `decode`, `from_text`, `to_text`) can be found in the [DOCUMENTATION.md](./docs/DOCUMENTATION.md#4-api-reference-) file.

---

<h2 id="file-structure">📁 7. Project Structure</h2>

```
.
├── Dockerfile                # 🐳 Defines the Docker build process
├── Makefile                  # 🛠️ Build instructions for the extension
├── README.md                 # 📖 This file
├── build.ps1                 # 🪟 Windows PowerShell build script
├── complain_header.sql       # ⚠️ SQL header included in the extension script
├── emojigresql.control       # 🔩 Extension control file
├── fetch-chars.sh            # 🌐 Script to download emoji list for the table
├── emoji-chars.sql           # 🗑️ (Old generated file, can be ignored/deleted)
├── FUNCTIONS/                # ✨ Directory containing SQL function definitions
│   ├── decode.sql            # ➡️ Decodes emojis to data
│   ├── encode.sql            # ⬅️ Encodes data to emojis
│   ├── from_text.sql         # 📝 Encodes text to emojis
│   └── to_text.sql           # 📖 Decodes emojis to text
├── sql/                      # 🧪 Directory for test SQL scripts
│   └── test.sql              # ▶️ Main test script
├── TABLES/                   # 📊 Directory for table definitions
│   └── chars.sql             # 📋 Emoji character lookup table definition
├── expected/                 # ✅ Expected output for tests
├── results/                  # 📉 Actual output from tests
├── .git/                     # 📁 Git directory
└── .gitignore                # 🙈 Files ignored by Git (if present)
```

*by VinsmokeSomya*