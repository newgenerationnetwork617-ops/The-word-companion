# English Bible translation library

The Word Companion is English-only and offline-first. The reader must support multiple independently installed translations, not a single fixed version. Each translation is stored under its own version ID and can be selected from the reader.

## Initial translation targets

| ID | Display name | Abbreviation | Rights / handling |
|---|---|---|---|
| `kjv` | King James Version (1769 standard text) | KJV | Public domain outside the United Kingdom; do not redistribute into the UK without resolving Crown rights. |
| `web` | World English Bible (2020 stable text) | WEB | Public domain. Preserve the exact text; use the WEB name only for a faithful, unmodified copy. |
| `bsb` | Berean Standard Bible | BSB | Dedicated to the public domain by its publisher on 30 April 2023. |
| `asv` | American Standard Version (1901) | ASV | Public domain. |
| `ylt` | Young's Literal Translation (1898 edition) | YLT | Public domain. |
| `dby` | Darby Translation (1890 edition) | DBY | Public domain. |
| `erv` | English Revised Version (1885) | ERV | Public domain. |
| `gen` | Geneva Bible (1599 edition) | GNV | Public domain; preserve the chosen edition and its spelling. |

These are the first candidate editions for bundled offline text. Before adding each full text, pin the exact source edition, verify its source and redistribution terms, preserve its wording, and record the checksum and attribution in the package manifest.

## Later candidates

Webster's Revision, Julia E. Smith Translation, and other demonstrably public-domain English editions can be assessed after the first set. The catalogue should grow only when a complete, trustworthy text and its rights status have been checked.

## Copyrighted translations

Do not bundle or redistribute NIV, NKJV, ESV, NLT, NASB, or other copyrighted translations without permission from the relevant rights holder. The package importer may accept a user-provided translation package only when that package includes its own valid source and licence metadata; importing must not be presented as permission to redistribute copyrighted text.

## Package and offline requirements

- One stable package ID per translation; never overwrite another translation just because the abbreviation is similar.
- English locale only (`en` or an `en-*` locale).
- Every package records source name and URL, licence name and URL, attribution, version, and SHA-256 checksum.
- Verse references must map to the canonical 66-book catalogue. Editions with a different book canon or versification need a separately designed mapping before import.
- Scripture text is stored locally in SQLite after installation. Reading, search, bookmarks, highlights, and notes must not require a network connection.
- WEB text must remain verbatim to retain the World English Bible name. Commentary and app-authored study notes are separate content and must never be inserted into the translation text.

## Authoritative rights references

- World English Bible copyright and redistribution statement: https://www.ebible.org/eng-web/copyright.htm
- Berean Bible free licensing: https://berean.bible/licensing.htm
- Berean Bible terms: https://berean.bible/terms.htm
- KJV public-domain status outside the UK and UK Crown-rights exception: https://guides.library.yale.edu/newtestament/kjv

This file is a rights and implementation checklist, not a claim that the full translation texts are already bundled in the app.
