#!/usr/bin/env python3
"""Membangun assets/data/cities_id.json dari dump GeoNames.

Menggabungkan 42 kota kurasi awal (ID stabil, dipakai test & preferensi
pengguna) dengan seluruh kabupaten/kota Indonesia (ADM2) dari GeoNames.

Sumber data: https://download.geonames.org/export/dump/ID.zip (CC BY 4.0).

Pemakaian:
    curl -sO https://download.geonames.org/export/dump/ID.zip && unzip ID.zip
    python3 tool/build_cities_data.py --geonames ID.txt \
        --existing assets/data/cities_id.json --out assets/data/cities_id.json
"""
from __future__ import annotations

import argparse
import json
import re
import unicodedata

# Zona waktu IANA -> offset UTC (jam). Indonesia tidak memakai DST.
TZ_OFFSET = {
    "Asia/Jakarta": 7,   # WIB
    "Asia/Pontianak": 7, # WIB
    "Asia/Makassar": 8,  # WITA
    "Asia/Jayapura": 9,  # WIT
}

# Kode admin1 GeoNames (ID.xx) -> nama provinsi (Bahasa Indonesia).
PROVINCES = {
    "01": "Aceh", "02": "Bali", "03": "Bengkulu", "04": "DKI Jakarta",
    "05": "Jambi", "07": "Jawa Barat", "08": "Jawa Tengah", "10": "DI Yogyakarta",
    "11": "Jawa Timur", "12": "Kalimantan Barat", "13": "Kalimantan Selatan",
    "14": "Kalimantan Tengah", "15": "Kalimantan Timur", "17": "Lampung",
    "18": "Maluku", "19": "Sulawesi Utara", "21": "Nusa Tenggara Barat",
    "22": "Nusa Tenggara Timur", "24": "Riau", "26": "Sumatera Utara",
    "28": "Sulawesi Tenggara", "29": "Sulawesi Selatan", "30": "Sumatera Barat",
    "31": "Sulawesi Tengah", "32": "Sumatera Selatan", "33": "Banten",
    "34": "Gorontalo", "35": "Kepulauan Bangka Belitung", "36": "Papua",
    "37": "Riau", "38": "Sulawesi Barat", "39": "Papua Barat",
    "40": "Kepulauan Riau", "41": "Kalimantan Utara", "42": "Papua Tengah",
    "43": "Papua Pegunungan", "44": "Papua Selatan", "45": "Papua Barat Daya",
    # Kode baru GeoNames untuk provinsi pemekaran Papua (2022).
    "PD": "Papua Barat Daya", "PE": "Papua Pegunungan",
    "PS": "Papua Selatan", "PT": "Papua Tengah",
}

# Fallback offset per provinsi (bila kolom timezone GeoNames kosong).
_WITA = {"Bali", "Nusa Tenggara Barat", "Nusa Tenggara Timur",
         "Kalimantan Selatan", "Kalimantan Timur", "Kalimantan Utara",
         "Sulawesi Utara", "Sulawesi Tengah", "Sulawesi Selatan",
         "Sulawesi Tenggara", "Sulawesi Barat", "Gorontalo"}
_WIT = {"Maluku", "Maluku Utara", "Papua", "Papua Barat", "Papua Tengah",
        "Papua Pegunungan", "Papua Selatan", "Papua Barat Daya"}
PROVINCE_OFFSET = {p: (8 if p in _WITA else 9 if p in _WIT else 7)
                   for p in set(PROVINCES.values()) | _WITA | _WIT}


def slugify(text: str) -> str:
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode()
    text = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
    return text


def normalize_name(name: str) -> str:
    """Nama tampilan: buang prefiks administratif GeoNames."""
    name = re.sub(
        r"^(Kota Administrasi|Kabupaten Administrasi|Kota|Kabupaten)\s+",
        "", name)
    return name.strip()


def display_name(raw: str) -> str:
    """'Kabupaten X' -> 'Kab. X'; 'Kota X'/'Kota Administrasi X' -> 'X'."""
    base = normalize_name(raw)
    if raw.startswith("Kabupaten"):
        return f"Kab. {base}"
    return base


def key_of(name: str) -> str:
    """Kunci dedupe berbasis nama tampilan.

    'Kab. X' dan 'X' (kota) sengaja berbeda — keduanya wilayah berbeda.
    """
    return re.sub(r"[^a-z0-9]", "", display_name(name).lower())


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--geonames", required=True, help="path ID.txt")
    ap.add_argument("--existing", required=True, help="cities_id.json lama")
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    with open(args.existing, encoding="utf-8") as f:
        existing = json.load(f)["cities"]

    seen_keys = {key_of(c["name"]) for c in existing}
    seen_ids = {c["id"] for c in existing}

    added = []
    with open(args.geonames, encoding="utf-8") as f:
        for line in f:
            cols = line.rstrip("\n").split("\t")
            if len(cols) < 18 or cols[6] != "A" or cols[7] != "ADM2":
                continue
            raw_name, lat, lng = cols[1], float(cols[4]), float(cols[5])
            admin1, dem, tz = cols[10], cols[16], cols[17]

            # Kota administrasi DKI (Jakarta Pusat dll.) dilewati: sudah
            # terwakili entri kurasi "Jakarta" (waktu sholat identik).
            if raw_name.startswith("Kota Administrasi"):
                continue

            key = key_of(raw_name)
            if key in seen_keys:
                continue  # sudah ada di data kurasi
            province = PROVINCES.get(admin1)
            offset = TZ_OFFSET.get(tz)
            if offset is None and province is not None:
                offset = PROVINCE_OFFSET.get(province)
            if province is None or offset is None:
                raise SystemExit(f"Mapping hilang untuk: {raw_name} "
                                 f"(admin1={admin1}, tz={tz})")

            city_id = slugify(display_name(raw_name))
            if city_id in seen_ids:
                city_id = slugify(raw_name)
            seen_ids.add(city_id)
            seen_keys.add(key)

            elevation = max(0, int(dem)) if dem.lstrip("-").isdigit() else 0
            added.append({
                "id": city_id,
                "name": display_name(raw_name),
                "province": province,
                "country": "Indonesia",
                "lat": round(lat, 5),
                "lng": round(lng, 5),
                "utcOffset": offset,
                "elevation": elevation,
            })

    cities = existing + added
    cities.sort(key=lambda c: c["name"])
    out = {
        "version": 2,
        "attribution": "Berisi data dari GeoNames (geonames.org), CC BY 4.0",
        "cities": cities,
    }
    with open(args.out, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=1)
        f.write("\n")
    print(f"kurasi={len(existing)} tambahan={len(added)} total={len(cities)}")


if __name__ == "__main__":
    main()
