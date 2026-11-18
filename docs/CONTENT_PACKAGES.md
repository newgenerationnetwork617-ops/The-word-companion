# Offline content packages — schema v1

The first installer accepts a UTF-8 JSON file for one Bible translation. The app does not fetch Scripture text from a server. A user can receive a package file and install it locally; after installation, reading works from SQLite without internet access.

## Package structure

```json
{
  "manifest": {
    "schema_version": 1,
    "package_type": "bible_translation",
    "package_id": "translation-language",
    "display_name": "Translation display name",
    "abbreviation": "ABC",
    "language_code": "en",
    "source_name": "Publisher or repository",
    "source_url": "https://publisher.example/source",
    "licence_name": "Exact licence name",
    "licence_url": "https://publisher.example/licence",
    "attribution_text": "Required attribution statement",
    "package_version": 1,
    "checksum_sha256": "SHA-256 of the UTF-8 jsonEncode(content) object"
  },
  "content": {
    "verses": [
      {
        "book_id": 1,
        "chapter_number": 1,
        "verse_number": 1,
        "text": "Verse text"
      }
    ]
  }
}
```

The checksum is calculated over the JSON encoding of the complete `content` object, excluding the manifest. The checksum detects accidental corruption; it is not a digital signature and does not prove who published a package.

## Validation and installation

- Only schema version 1 and `bible_translation` packages are accepted by this first importer.
- Required metadata includes source, source URL, exact licence, licence URL and attribution.
- SHA-256 is checked before any database changes.
- Book IDs must match the canonical 66-book catalogue; chapter numbers must be within the book's chapter count; verse numbers must be positive; duplicate references and empty text are rejected.
- Translation and verse rows, search entries, package record and attribution are written in one SQLite transaction. A failure rolls the entire installation back.
- Existing translation IDs or abbreviations are rejected rather than silently overwritten.
- Personal notes, bookmarks, highlights and reading progress are not touched.

## Licensing and trust

A URL being publicly accessible does not grant redistribution rights. Verify the exact translation's current licence and whether it permits offline redistribution, modification, and any intended commercial use. Preserve all required copyright notices and attribution. The app must not ship sample or placeholder verse text as a real translation.

The checksum is an integrity check only. Before publishing official packages, add a publisher signature or trusted release manifest so users can verify package origin as well as file integrity.
