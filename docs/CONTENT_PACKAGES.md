# Offline content packages — draft v1

Packages will be versioned archives installed into the local application.

## Required manifest fields
- package_id
- package_type (bible_translation, commentary, cross_references, hymn_collection, reference_data)
- display_name
- language_code
- package_version
- minimum_app_version
- source_name and source_url
- licence_name and licence_url
- attribution_text
- checksum_sha256

## Validation
1. Reject missing or unsupported package types and schema versions.
2. Verify SHA-256 before importing.
3. Validate required fields and Scripture references.
4. Reject duplicate package IDs unless performing an explicit update.
5. Preserve source, licence, and attribution metadata.
6. Import inside a database transaction and roll back on failure.
7. Never overwrite personal notes, bookmarks, highlights, or reading progress during a content update.

## Licensing
Online availability does not automatically grant redistribution rights. Verify the exact licence and its attribution, notice, and commercial-use requirements before distributing a package.
