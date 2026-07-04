#!/usr/bin/env python3
"""Membangun ulang assets/data/quran.json dengan seluruh 114 surah.

Sumber: equran.id API v2 (teksArab, teksLatin, teksIndonesia — terjemahan
Kemenag). Metadata surah & indeks juz dipertahankan dari file yang ada.
"""
import json
import sys
import time
import urllib.request

ASSET = "assets/data/quran.json"
API = "https://equran.id/api/v2/surat/{}"


def fetch(n, retries=4):
    url = API.format(n)
    for attempt in range(retries):
        try:
            req = urllib.request.Request(
                url,
                headers={
                    "User-Agent": "Mozilla/5.0 (Miqat data builder)",
                    "Accept": "application/json",
                },
            )
            with urllib.request.urlopen(req, timeout=30) as r:
                return json.loads(r.read().decode("utf-8"))["data"]
        except Exception as e:  # noqa: BLE001
            if attempt == retries - 1:
                raise
            time.sleep(1.5)
    return None


def juz_of(juz_index, surah, ayah):
    result = 1
    for m in juz_index:
        started = surah > m["surah"] or (surah == m["surah"] and ayah >= m["ayah"])
        if started:
            result = m["juz"]
    return result


def main():
    with open(ASSET, encoding="utf-8") as f:
        existing = json.load(f)

    surahs = existing["surahs"]
    juz_index = existing["juzIndex"]

    verses = []
    for n in range(1, 115):
        data = fetch(n)
        for a in data["ayat"]:
            ayah_no = a["nomorAyat"]
            verses.append({
                "surah": n,
                "ayah": ayah_no,
                "juz": juz_of(juz_index, n, ayah_no),
                "arabic": a["teksArab"],
                "transliteration": a["teksLatin"],
                "translation": a["teksIndonesia"],
            })
        print(f"  surah {n:3d} ({data['namaLatin']}) : {len(data['ayat'])} ayat", file=sys.stderr)

    out = {
        "version": existing.get("version", 1),
        "surahs": surahs,
        "juzIndex": juz_index,
        "verses": verses,
    }
    with open(ASSET, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, separators=(",", ":"))

    print(f"TOTAL VERSES: {len(verses)}", file=sys.stderr)


if __name__ == "__main__":
    main()
