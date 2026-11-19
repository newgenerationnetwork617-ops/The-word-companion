#!/usr/bin/env python3
"""Build pinned public-domain English Bible packages for offline APK installation.

The source dataset's code is MIT; each Bible text retains its own declared
public-domain status. eBible.org edition pages are recorded as rights/source
references. All generated packages are structurally checked before inclusion.
"""
import hashlib
import json
import pathlib
import urllib.request

COMMIT = "9586bd8228a747962df1ee8692730422fb7eb2ec"
BASE = f"https://raw.githubusercontent.com/midvash/bible-data/{COMMIT}/versions/en"

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
EXPECTED = {name: count for name, count in BOOKS}
EDITIONS = [
    {
        "slug":"kjv","id":"kjv","name":"King James Version (1769)","abbr":"KJV",
        "verses":31102,"rights":"https://ebible.org/find/show.php?id=eng-kjv2006",
        "rights_note":"Public domain outside the United Kingdom; UK Crown printing rights exception applies.",
        "source_note":"King James (Authorized) Version, standardized 1769 text; source dataset pinned to Midvash Bible Data."
    },
    {
        "slug":"asv","id":"asv","name":"American Standard Version (1901)","abbr":"ASV",
        "verses":31086,"rights":"https://ebible.org/find/details.php?id=eng-asv",
        "rights_note":"Public domain.",
        "source_note":"American Standard Version, 1901; source dataset pinned to Midvash Bible Data."
    },
    {
        "slug":"web","id":"web","name":"World English Bible","abbr":"WEB",
        "verses":31098,"rights":"https://ebible.org/find/details.php?id=engwebp",
        "rights_note":"Public domain; preserve the text unchanged when using the WEB name.",
        "source_note":"World English Bible; source dataset pinned to Midvash Bible Data."
    },
    {
        "slug":"geneva1599","id":"geneva1599","name":"Geneva Bible (1599)","abbr":"GNV",
        "verses":31090,"rights":"https://ebible.org/find/details.php?id=enggnv",
        "rights_note":"Public domain, 1599 edition.",
        "source_note":"Geneva Bible, 1599 edition; source dataset pinned to Midvash Bible Data."
    },
]

def get_json(url):
    request = urllib.request.Request(url, headers={"User-Agent":"TheWordCompanion-build/1.0"})
    with urllib.request.urlopen(request, timeout=120) as response:
        return json.loads(response.read())

def package_edition(edition):
    slug = edition["slug"]
    source_url = f"{BASE}/{slug}/{slug}.json"
    bible = get_json(source_url)
    if bible.get("version") != slug or bible.get("language") != "en":
        raise SystemExit(f"{slug}: wrong edition identity or language")
    books = bible.get("books")
    if not isinstance(books, list) or len(books) != 66:
        raise SystemExit(f"{slug}: expected exactly 66 books")

    by_id = {}
    for book in books:
        book_id = book.get("bookId")
        name = book.get("englishName")
        if not isinstance(book_id, int) or not isinstance(name, str) or name not in EXPECTED:
            raise SystemExit(f"{slug}: invalid book identity {book!r}")
        if book_id in by_id:
            raise SystemExit(f"{slug}: duplicate book id {book_id}")
        by_id[book_id] = book

    if set(by_id) != set(range(1, 67)):
        raise SystemExit(f"{slug}: canonical 66-book numbering is incomplete")

    verses = []
    for book_id in range(1, 67):
        book = by_id[book_id]
        name = book["englishName"]
        chapters = book.get("chapters")
        if not isinstance(chapters, list) or len(chapters) != EXPECTED[name]:
            raise SystemExit(f"{slug}: incomplete chapter coverage for {name}")
        chapter_seen = set()
        for chapter in chapters:
            chapter_no = chapter.get("chapter")
            if not isinstance(chapter_no, int) or chapter_no < 1 or chapter_no > EXPECTED[name] or chapter_no in chapter_seen:
                raise SystemExit(f"{slug}: invalid/duplicate chapter in {name}")
            chapter_seen.add(chapter_no)
            raw_verses = chapter.get("verses")
            if not isinstance(raw_verses, list) or not raw_verses:
                raise SystemExit(f"{slug}: empty chapter {name} {chapter_no}")
            verse_seen = set()
            for verse in raw_verses:
                number, text = verse.get("number"), verse.get("text")
                if not isinstance(number, int) or number < 1 or number in verse_seen:
                    raise SystemExit(f"{slug}: invalid/duplicate verse in {name} {chapter_no}")
                if not isinstance(text, str) or not text.strip():
                    raise SystemExit(f"{slug}: empty verse in {name} {chapter_no}:{number}")
                verse_seen.add(number)
                verses.append({
                    "book_id":book_id,
                    "chapter_number":chapter_no,
                    "verse_number":number,
                    "text":text.strip(),
                })
        if chapter_seen != set(range(1, EXPECTED[name] + 1)):
            raise SystemExit(f"{slug}: missing chapter number in {name}")

    if len(verses) != edition["verses"]:
        raise SystemExit(f"{slug}: expected {edition['verses']} verses, found {len(verses)}")
    verses.sort(key=lambda v:(v["book_id"],v["chapter_number"],v["verse_number"]))
    content = {"verses":verses}
    canonical = json.dumps(content, ensure_ascii=False, separators=(",",":"))
    checksum = hashlib.sha256(canonical.encode("utf-8")).hexdigest()
    package = {
        "manifest":{
            "schema_version":1,
            "package_type":"bible_translation",
            "package_id":edition["id"],
            "display_name":edition["name"],
            "abbreviation":edition["abbr"],
            "language_code":"en",
            "source_name":"Midvash Bible Data (pinned dataset); edition details from eBible.org",
            "source_url":source_url,
            "licence_name":"Public Domain",
            "licence_url":edition["rights"],
            "attribution_text":edition["source_note"]+" Dataset: Midvash bible-data, commit "+COMMIT+". Rights note: "+edition["rights_note"],
            "package_version":1,
            "checksum_sha256":checksum,
        },
        "content":content,
    }
    target = pathlib.Path("assets/bible") / f"{slug}.json"
    target.parent.mkdir(parents=True, exist_ok=True)
    with target.open("w",encoding="utf-8",newline="") as output:
        json.dump(package,output,ensure_ascii=False,separators=(",",":"))
    print(f"Packaged {edition['abbr']}: {len(verses):,} verses, {target.stat().st_size:,} bytes, SHA-256 {checksum}")

def main():
    for edition in EDITIONS:
        package_edition(edition)

if __name__ == "__main__":
    main()
