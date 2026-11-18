# Architecture — Stage 1

## Layers
- Presentation: Flutter Material 3 screens and navigation.
- Features: home, Bible reader, study, hymns, and settings.
- Data: local SQLite database, content package importer, and preferences.
- Platform: Android storage and future local notifications.

## Offline boundary
Installed Scripture, commentary, cross-references, hymns, notes, bookmarks, highlights, and reading progress must work without a network connection. No authentication, Firebase, Supabase, analytics SDK, or cloud database is in the initial architecture.

An internet connection may optionally be used later to obtain a content package. After validation and installation, it is stored locally and remains usable offline.

## Data
SQLite stores installed structured content and personal study data. Scripture search will use SQLite FTS5. Personal notes and reading progress remain on the device.

## Accuracy
Cross-references must be curated, classified by relationship, explained, and traceable to their source. Commentary must be reviewed and attached to a defined passage range. No content should be labelled verified until checked.

## Stage 1 limitations
Bible, Study, Hymns, and Settings screens are structural placeholders. No translation, commentary, cross-reference dataset, or hymn lyrics are bundled yet.
