# Miqat — Sholat On Time, Every Time

Aplikasi Flutter jadwal sholat & arah kiblat **offline-first** untuk Indonesia.

## Fitur

- **Jadwal sholat** akurat berbasis perhitungan astronomi lokal (tanpa internet)
- **Arah kiblat** dengan kompas perangkat
- **Notifikasi adzan** tepat waktu (exact alarm, Android 12+/14+), mode adzan / senyap / getar
- **Pengingat pra-adzan** dengan jeda yang dapat diatur
- **Al-Qur'an** lengkap dengan bookmark
- **512 kab/kota Indonesia** bawaan + deteksi lokasi GPS
- **Tema gelap** (nyaman untuk Subuh & Isya) — terang/gelap/ikuti sistem
- Dukungan screen reader (TalkBack/VoiceOver) pada komponen inti
- Jadwal otomatis dipulihkan setelah restart perangkat

## Menjalankan

```bash
flutter pub get
flutter run
```

## Testing & analisis

```bash
flutter analyze
flutter test
```

## Build rilis Android

1. Buat keystore rilis, lalu salin `android/key.properties.example` menjadi
   `android/key.properties` dan isi kredensialnya (file ini tidak di-commit).
2. Build:

```bash
flutter build appbundle   # Play Store (AAB)
flutter build apk         # APK langsung
```

Tanpa `key.properties`, build rilis otomatis memakai debug key (hanya untuk pengembangan).

## Struktur proyek

| Folder | Isi |
|---|---|
| `lib/engine/` | Kalkulator waktu sholat & model astronomi |
| `lib/features/` | UI per fitur: today, qibla, quran, hub, settings, onboarding |
| `lib/notifications/` | Penjadwalan adzan, exact alarm, refresh harian |
| `lib/data/` | Repositori kota, lokasi, preferensi |
| `assets/data/` | `cities_id.json` (512 kab/kota), `quran.json` |
| `tool/` | Skrip pembangun data kota (GeoNames), Qur'an & logo |

## Regenerasi ikon & splash

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## CI

GitHub Actions (`.github/workflows/ci.yml`) menjalankan analyze + test dan
build APK release pada setiap push/PR ke `main`.

## Atribusi

- Suara adzan: lihat [ADZAN_ATTRIBUTION.txt](ADZAN_ATTRIBUTION.txt).
- Data kab/kota: berisi data dari [GeoNames](https://www.geonames.org)
  (lisensi CC BY 4.0).
