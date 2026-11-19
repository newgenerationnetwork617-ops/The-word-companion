# Offline hymn library

The Android APK bundles two English hymn collections and installs them into the local SQLite database during first launch. Hymn browsing and reading do not require internet access.

## Bundled collections

- **Songs of Praise** — four original devotional hymn texts.
- **Scripture Songs** — four original devotional hymn texts based on broad biblical themes.

These are original text-only compositions written for The Word Companion. They are not transcriptions of existing hymn books, and no existing melody, tune, arrangement, or recording is included. Users should not assume a familiar melody is attached to these words.

## Build and integrity

`tool/build_bundled_hymns.py` generates both JSON packages under `assets/hymns/`. Each package includes English language metadata, source and licence information, attribution, package version, and SHA-256 checksum. `BundledHymnInstaller` validates and installs the packages on device without network access. The test suite loads each bundled asset and runs the same package validation used by the app.

## Adding future collections

Only add complete English texts that are original or have independently verified redistribution rights for the intended distribution countries. Preserve the exact source edition, author/translator attribution, licence URL, and package checksum. Do not copy modern hymn-book edits, arrangements, or translations without permission.
