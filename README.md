# The Word Companion

**Read the Word. Understand the Word. Live the Word.**

An offline-first Android Bible reading and study application.

## Stage 1 status
This commit establishes the Flutter application shell, five-section navigation, visual theme, local SQLite schema, and content-package specification. The Bible, Study, Hymns, and Settings screens are foundations; actual content and full features arrive in later stages.

## Principles
- Android-first and offline-first.
- No accounts, Firebase, Supabase, or cloud database.
- Installed Scripture and study content remains available offline.
- Every content package must include source and licence metadata.
- Only public-domain or appropriately licensed Bible translations, hymn lyrics, and reference material may be distributed.
- Cross-references and commentary must be reviewed for accuracy.

## Stack
Flutter / Dart, SQLite using sqflite, local app storage using path_provider, and local preferences using shared_preferences.

## Run
Install Flutter and Android Studio, then run flutter pub get followed by flutter run with an Android device or emulator connected.

See docs/ARCHITECTURE.md and docs/CONTENT_PACKAGES.md.
