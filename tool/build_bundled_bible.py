#!/usr/bin/env python3
"""Fetch and package the pinned, public-domain WEBU dataset for offline APK use."""
import hashlib
import json
import pathlib
import urllib.request

COMMIT = "44ce9156b77649adf11c0bbcee89c1d80e2c1f1c"
SOURCE = (
    "https://raw.githubusercontent.com/ringletech/webu-open-bible/"
    + COMMIT + "/json/complete-bible.json"
)
BOOKS = [
    ("Genesis",50),("Exodus",40),("Leviticus",27),("Numbers",36),("Deuteronomy",34),
    ("Joshua",24),("Judges",21),("Ruth",4),("1 Samuel",31),("2 Samuel",24),
    ("1 Kings",22),("2 Kings",25),("1 Chronicles",29),("2 Chronicles",36),("Ezra",10),
    ("Nehemiah",13),("Esther",10),("Job",42),("Psalms",150),("Proverbs",31),
    ("Ecclesiastes",12),("Song of Solomon",8),("Isaiah",66),("Jeremiah",52),
    ("Lamentations",5),("Ezekiel",48),("Daniel",12),("Hosea",14),("Joel",3),
    ("Amos",9),("Obadiah",1),("Jonah",4),("Micah",7),("Nahum",3),("Habakkuk",3),
    ("Zephaniah",3),("Haggai",2),("Zechariah",14),("Malachi",4),("Matthew",28),
    ("Mark",16),("Luke",24),("John",21),("Acts",28),("Romans",16),
    ("1 Corinthians",16),("2 Corinthians",13),("Galatians",6),("Ephesians",6),
    ("Philippians",4),("Colossians",4),("1 Thessalonians",5),("2 Thessalonians",3),
    ("1 Timothy",6),("2 Timothy",4),("Titus",3),("Philemon",1),("Hebrews",13),
    ("James",5),("1 Peter",5),("2 Peter",3),("1 John",5),("2 John",1),
    ("3 John",1),("Jude",1),("Revelation",22),
]

def main():
    request = urllib.request.Request(SOURCE, headers={"User-Agent": "TheWordCompanion-build/1.0"})
    with urllib.request.urlopen(request, timeout=90) as response:
        raw = response.read()
    records = json.loads(raw)
    if not isinstance(records, list) or len(records) != 31098:
        raise SystemExit(f"WEBU source validation failed: expected 31,098 verses, got {len(records) if isinstance(records, list) else 'non-list'}")

    book_ids = {name: index + 1 for index, (name, _) in enumerate(BOOKS)}
    expected_chapters = {name: count for name, count in BOOKS}
    seen = set()
    chapter_sets = {name: set() for name, _ in BOOKS}
    verse_numbers = {}
    verses = []
    for item in records:
        if item.get("translation") != "WEBU":
            raise SystemExit("Unexpected translation code in source dataset.")
        name = item.get("book")
        book_id = book_ids.get(name)
        chapter, number, text = item.get("chapter"), item.get("verse"), item.get("text")
        if book_id is None or not isinstance(chapter, int) or not isinstance(number, int) or not isinstance(text, str) or not text.strip():
            raise SystemExit(f"Invalid source verse record: {item!r}")
        if chapter < 1 or chapter > expected_chapters[name] or number < 1:
            raise SystemExit(f"Out-of-range Scripture reference: {name} {chapter}:{number}")
        key = (book_id, chapter, number)
        if key in seen:
            raise SystemExit(f"Duplicate Scripture reference: {key}")
        seen.add(key)
        chapter_sets[name].add(chapter)
        verse_numbers.setdefault((book_id, chapter), set()).add(number)
        verses.append({
            "book_id": book_id,
            "chapter_number": chapter,
            "verse_number": number,
            "text": text.strip(),
        })

    for name, chapter_count in BOOKS:
        if chapter_sets[name] != set(range(1, chapter_count + 1)):
            raise SystemExit(f"Incomplete chapter coverage for {name}")

    for (book_id, chapter), numbers in verse_numbers.items():
        if numbers != set(range(1, max(numbers) + 1)):
            raise SystemExit(f"Non-contiguous verse numbering in book {book_id}, chapter {chapter}")

    verses.sort(key=lambda v: (v["book_id"], v["chapter_number"], v["verse_number"]))
    content = {"verses": verses}
    canonical_content = json.dumps(content, ensure_ascii=False, separators=(",", ":"))
    checksum = hashlib.sha256(canonical_content.encode("utf-8")).hexdigest()
    package = {
        "manifest": {
            "schema_version": 1,
            "package_type": "bible_translation",
            "package_id": "webu",
            "display_name": "World English Bible Updated",
            "abbreviation": "WEBU",
            "language_code": "en",
            "source_name": "eBible.org World English Bible Updated (dataset mirror: ringletech/webu-open-bible)",
            "source_url": SOURCE,
            "licence_name": "Public Domain (eBible.org); dataset CC0-1.0",
            "licence_url": "https://ebible.org/find/details.php?id=engwebu",
            "attribution_text": "Scripture text: World English Bible Updated (WEBU), eBible.org, public domain. Dataset mirror released under CC0-1.0 by ringletech/webu-open-bible. Source commit: " + COMMIT,
            "package_version": 1,
            "checksum_sha256": checksum,
        },
        "content": content,
    }
    target = pathlib.Path("assets/bible/webu.json")
    target.parent.mkdir(parents=True, exist_ok=True)
    with target.open("w", encoding="utf-8", newline="") as output:
        json.dump(package, output, ensure_ascii=False, separators=(",", ":"))
    print(f"Packaged {len(verses):,} WEBU verses across {len(BOOKS)} books; SHA-256 {checksum}; {target.stat().st_size:,} bytes")

if __name__ == "__main__":
    main()
