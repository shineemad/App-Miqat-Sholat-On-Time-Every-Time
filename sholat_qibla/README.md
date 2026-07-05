# Miqat — Sholat On Time, Every Time

Aplikasi Flutter jadwal sholat & arah kiblat **offline-first** untuk Indonesia.

## Fitur

- **Jadwal sholat** akurat berbasis perhitungan astronomi lokal (tanpa internet)
- **Arah kiblat** dengan kompas perangkat
- **Notifikasi adzan** tepat waktu (exact alarm, Android 12+/14+), mode adzan / senyap / getar
- **Pengingat pra-adzan** dengan jeda yang dapat diatur
- **Al-Qur'an** lengkap dengan bookmark
- **42 kota Indonesia** bawaan + deteksi lokasi GPS
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
| `assets/data/` | `cities_id.json` (42 kota), `quran.json` |
| `tool/` | Skrip pembangun data Qur'an & logo |

## Regenerasi ikon & splash

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Atribusi audio

Lihat [ADZAN_ATTRIBUTION.txt](ADZAN_ATTRIBUTION.txt).
