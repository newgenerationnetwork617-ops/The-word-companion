import hashlib
import json
from pathlib import Path

# Original devotional hymn texts written for The Word Companion.
# These are text-only compositions; no existing melodies or copyrighted
# arrangements are included.

COLLECTIONS = [
    {
        "id": "twc-original-praise",
        "name": "Songs of Praise",
        "hymns": [
            {
                "title": "Morning Praise",
                "hymn_number": "1",
                "first_line": "The morning light declares Your grace",
                "lyrics": "The morning light declares Your grace,\nThe skies proclaim Your faithful care;\nWe lift our hearts and seek Your face,\nAnd bring our thanks to You in prayer.\n\nYou are our strength through every day,\nOur steady hope when paths are long;\nGuide all our steps along Your way,\nAnd fill our lives with grateful song."
            },
            {
                "title": "Great Is Your Faithfulness",
                "hymn_number": "2",
                "first_line": "Your mercy meets us with the dawn",
                "lyrics": "Your mercy meets us with the dawn,\nYour truth remains when days are done;\nThrough changing seasons, still You lead,\nAnd give the strength our hearts may need.\n\nGreat is Your faithfulness and love,\nA constant gift from heaven above;\nOur hope is held in what You say,\nOur song of thanks will rise each day."
            },
            {
                "title": "Let Every Heart Give Thanks",
                "hymn_number": "3",
                "first_line": "Let every heart give thanks today",
                "lyrics": "Let every heart give thanks today,\nFor grace that guides us on our way;\nFor daily bread and strength to stand,\nFor loving care from Your own hand.\n\nWhen we are weak, Your truth is strong;\nYou turn our sighs to hopeful song;\nMay all we do and all we say\nBring honour to Your name each day."
            },
            {
                "title": "Worthy of Our Praise",
                "hymn_number": "4",
                "first_line": "Worthy are You, Lord of all",
                "lyrics": "Worthy are You, Lord of all,\nThe One who hears the humble call;\nYour wisdom stands, Your mercies stay,\nYour light can never fade away.\n\nReceive the praise our hearts can bring,\nThe simple song our spirits sing;\nIn every place, in every hour,\nWe trust Your love and seek Your power."
            }
        ]
    },
    {
        "id": "twc-scripture-songs",
        "name": "Scripture Songs",
        "hymns": [
            {
                "title": "Your Word Is a Lamp",
                "hymn_number": "1",
                "first_line": "Your word is a lamp unto my feet",
                "lyrics": "Your word is a lamp unto my feet,\nA faithful guide when roads divide;\nYour promises are sure and sweet,\nYour truth will ever be my guide.\n\nTeach me to listen, help me obey,\nTo walk in love throughout the day;\nLet every choice and thought be true,\nAnd shape my life to honour You."
            },
            {
                "title": "Teach Us Your Way",
                "hymn_number": "2",
                "first_line": "Teach us Your way, O Lord, we pray",
                "lyrics": "Teach us Your way, O Lord, we pray,\nAnd keep our hearts from going astray;\nGive us the wisdom to discern\nThe lessons that Your people learn.\n\nMake us doers of what is true,\nWith patient hearts in all we do;\nLet kindness guide the words we say,\nAnd faithfulness mark every day."
            },
            {
                "title": "A Heart Made New",
                "hymn_number": "3",
                "first_line": "Create in us a heart made new",
                "lyrics": "Create in us a heart made new,\nA spirit steadfast, kind and true;\nHelp us to leave the wrong behind,\nAnd seek the things that please Your mind.\n\nMay mercy shape the work we do,\nMay hope make all our vision new;\nAnd as Your light our lives renew,\nMay others see Your love shine through."
            },
            {
                "title": "Walk in the Light",
                "hymn_number": "4",
                "first_line": "We walk by faith and not by sight",
                "lyrics": "We walk by faith and not by sight,\nYour word our lamp, Your truth our light;\nWhen questions rise, help us to stand,\nAnd place our future in Your hand.\n\nLet justice, mercy, guide our way,\nLet humble service mark each day;\nUntil our journey here is through,\nKeep us in love and close to You."
            }
        ]
    }
]

def main():
    output = Path("assets/hymns")
    output.mkdir(parents=True, exist_ok=True)
    for collection in COLLECTIONS:
        content = {"hymns": collection["hymns"]}
        canonical = json.dumps(content, ensure_ascii=False, separators=(",", ":"))
        manifest = {
            "schema_version": 1,
            "package_type": "hymn_collection",
            "package_id": collection["id"],
            "display_name": collection["name"],
            "language_code": "en",
            "source_name": "Original devotional texts written for The Word Companion",
            "source_url": "https://github.com/newgenerationnetwork617-ops/The-word-companion",
            "licence_name": "Original content; permission granted for use in The Word Companion",
            "licence_url": "https://github.com/newgenerationnetwork617-ops/The-word-companion",
            "attribution_text": "Original devotional hymn texts written for The Word Companion. Text only; no existing melody or arrangement is included.",
            "package_version": 1,
            "checksum_sha256": hashlib.sha256(canonical.encode("utf-8")).hexdigest(),
        }
        package = {"manifest": manifest, "content": content}
        path = output / f"{collection['id']}.json"
        path.write_text(json.dumps(package, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"Created {path} ({len(collection['hymns'])} original hymns)")

if __name__ == "__main__":
    main()
