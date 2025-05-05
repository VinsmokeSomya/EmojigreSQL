# PowerShell Build Script for EmojigreSQL (Windows Native)

Write-Host "Starting EmojigreSQL build process..."

# --- Configuration ---
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue" # Suppress Invoke-WebRequest progress bar

$ExtensionName = "emojigresql"
$Version = "1.0"
$OutputSqlFile = "$($ExtensionName)--$($Version).sql"
$GeneratedCharsSql = "$($ExtensionName)-chars.sql"
$SchemaName = $ExtensionName
$EmojiSourceUrl = "https://unicode.org/Public/emoji/13.1/emoji-test.txt"
$MaxEmojis = 1024

$SqlSrcFiles = @(
    "complain_header.sql",
    "TABLES/chars.sql",
    "FUNCTIONS/encode.sql",
    "FUNCTIONS/decode.sql",
    "FUNCTIONS/from_text.sql",
    "FUNCTIONS/to_text.sql"
)

# --- Step 1: Fetch Emoji Characters and Generate Inserts ---
Write-Host "Checking for existing emoji character file ($GeneratedCharsSql)..."
if (-not (Test-Path $GeneratedCharsSql)) {
    Write-Host "❗️ Modifying the emoji list can cause compatibility problems. ❗️"
    Write-Host "🌐 Fetching emoji list from $EmojiSourceUrl..."
    try {
        # Download the emoji list
        $response = Invoke-WebRequest -Uri $EmojiSourceUrl -UseBasicParsing
        if ($response.StatusCode -ne 200) {
            Write-Error "Failed to download emoji list. Status code: $($response.StatusCode)"
            exit 1
        }
        $emojiLines = $response.Content -split '\r?\n'

        $sqlInserts = @()
        $count = 0

        # Process lines
        foreach ($line in $emojiLines) {
            if ($count -ge $MaxEmojis) {
                break
            }
            if ($line -match '^([0-9A-F]{4,5})\s+;\s+\w+\s+#\s+(.)\s+.*$') {
                $emojiChar = $matches[2]
                $escapedEmojiChar = $emojiChar -replace "'", "''" # Escape single quotes
                $sqlInserts += "INSERT INTO $($SchemaName).chars (emoji_char) VALUES ('$($escapedEmojiChar)');"
                $count++
            }
        }

        # Write the SQL statements to the output file
        $sqlInserts | Set-Content -Path $GeneratedCharsSql -Encoding UTF8
        Write-Host "✅ Generated $GeneratedCharsSql with $count emojis."

    } catch {
        Write-Error "An error occurred fetching/processing emojis: $_"
        exit 1
    }
} else {
    Write-Host "✅ $GeneratedCharsSql already exists. Skipping download."
}

# --- Step 2: Concatenate SQL Files ---
Write-Host "Concatenating SQL source files into $OutputSqlFile..."
try {
    # Check if all source files exist
    $missingFiles = @()
    foreach ($file in $SqlSrcFiles) {
        if (-not (Test-Path $file)) {
            $missingFiles += $file
        }
    }
    if ($missingFiles.Count -gt 0) {
        Write-Error "Missing source files: $($missingFiles -join ', ')"
        exit 1
    }

    # Concatenate main sources
    Get-Content -Path $SqlSrcFiles -Raw | Set-Content -Path $OutputSqlFile -Encoding UTF8 -NoNewline

    # Append generated characters file
    Get-Content -Path $GeneratedCharsSql -Raw | Add-Content -Path $OutputSqlFile -Encoding UTF8

    Write-Host "✅ Successfully created $OutputSqlFile."

} catch {
    Write-Error "An error occurred concatenating SQL files: $_"
    exit 1
}

Write-Host "Build script finished."
Write-Host "You can now use '$OutputSqlFile' and '$($ExtensionName).control' to install the extension manually,"
Write-Host "or consider using PGXN for easier distribution." 