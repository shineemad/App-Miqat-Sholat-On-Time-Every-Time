# Struktur UI/UX — Aplikasi Pengingat Waktu Sholat & Arah Kiblat

> Dokumen ini menyusun **arsitektur informasi, peta layar, navigasi, komponen, dan alur (flow)** sebagai fondasi sebelum desain visual. Prinsip utama berasal dari hasil "local council" 4 sudut pandang: kesederhanaan, privasi, skalabilitas, dan tantangan (devil's advocate).

---

## 1. Prinsip Desain (Design Principles)

| Prinsip | Penjelasan |
| --- | --- |
| **Offline-first** | Fungsi inti (waktu sholat, kiblat, notifikasi) wajib jalan tanpa internet. Waktu sholat & arah kiblat dihitung **di perangkat** (math murni dari lat/long). |
| **Glanceable** | Tujuan utama dijawab dalam < 2 detik: "Sholat berikutnya apa & berapa lama lagi?" |
| **Privacy by default** | Tanpa akun, tanpa SDK analitik/iklan yang membaca lokasi. Lokasi tidak pernah keluar dari perangkat. Tersedia opsi **pilih kota manual** (tanpa izin GPS). |
| **Defaults cerdas, mudah diubah** | Metode perhitungan default **Kemenag (Indonesia)**, lokasi otomatis, reminder aktif — semua dapat diubah ≤ 2 tap. |
| **Akurasi & kejujuran status** | Setiap layar inti menampilkan status sumber data & ketidakpastian (mis. "Akurasi kompas rendah — kalibrasi"). |
| **Shell stabil, fitur sebagai modul** | Tab bar tetap; fitur masa depan masuk lewat layar **Hub** tanpa merombak navigasi. |
| **Aksesibilitas** | Kontras tinggi (dipakai outdoor), teks besar, dukungan satu tangan, dukungan **RTL/Arab** sejak awal. |

---

## 2. Arsitektur Informasi (Information Architecture)

```
App
├─ Onboarding (sekali, saat pertama buka)
│  ├─ Welcome / nilai aplikasi
│  ├─ Permission priming (Lokasi: "While Using") + opsi "Pilih kota manual"
│  ├─ Pilih metode perhitungan (default: Kemenag) + madzhab Ashar
│  └─ Aktifkan notifikasi (opsional)
│
└─ Main (Tab Bar — 5 slot tetap)
   ├─ 1. Today (Beranda)
   ├─ 2. Qibla (Arah Kiblat)
   ├─ 3. Quran  (stub/disediakan untuk masa depan)
   ├─ 4. Hub    (kumpulan fitur tambahan — grid yang bisa tumbuh)
   └─ 5. Settings (Pengaturan)
```

> **Catatan navigasi:** label tab tidak boleh berubah antar rilis (menjaga muscle memory). Semua fitur baru (Tasbih, Kalender Hijriah, Pencari Masjid, Mode Ramadhan) masuk sebagai kartu di **Hub**, bukan menggeser tab.

---

## 3. Peta Layar (Screen Map) & Komponen

### 3.1 Onboarding (first run)

| Layar | Komponen utama | Catatan UX |
| --- | --- | --- |
| **Welcome** | Ilustrasi, 1 kalimat nilai, tombol "Mulai" | Singkat, bisa di-skip |
| **Izin Lokasi (priming)** | Penjelasan *mengapa*, tombol **"Gunakan Lokasi"** (While Using) & **"Pilih Kota Manual"** | Jangan minta background location di awal. Jangan langsung munculkan dialog OS sebelum priming |
| **Metode Perhitungan** | Dropdown metode (default **Kemenag**), pilihan madzhab Ashar (Syafi'i/Hanafi) | Default benar untuk lokal; tetap mudah diubah |
| **Notifikasi** | Toggle aktifkan, preview adzan/getar | Opsional, bisa dilewati |

### 3.2 Tab 1 — Today (Beranda)  ⭐ layar hero

| Komponen | Deskripsi |
| --- | --- |
| **Hero: Sholat berikutnya** | Nama sholat + **hitung mundur besar** ("Ashar 1j 23m lagi") di tengah |
| **Daftar 5 waktu** | Baris sekunder yang tenang: Subuh, Dzuhur, Ashar, Maghrib, Isya + waktu masing-masing; sholat aktif disorot |
| **Tanggal** | Tanggal Masehi + **Hijriah** (dengan offset yang bisa diatur) |
| **Lokasi & status** | Nama kota saat ini + indikator sumber (GPS / manual) + **badge offline** bila tanpa jaringan |
| **Mark as prayed** | Tombol satu-tap "Sudah sholat" → memberi umpan ke **streak/konsistensi** (ambient, tidak menggurui) |
| **Akses cepat Qibla** | Ikon kompas di top bar (alternatif selain tab) |

**Alur utama:** Buka app → langsung lihat countdown sholat berikutnya → (opsional) tandai sudah sholat.

### 3.3 Tab 2 — Qibla (Arah Kiblat)

| Komponen | Deskripsi |
| --- | --- |
| **Kompas + ikon Ka'bah** | Panah/Ka'bah berputar menunjuk bearing ke Makkah (21.4225°N, 39.8262°E) |
| **Gate kalibrasi (wajib)** | Bila magnetometer tidak akurat → tampilkan animasi gerakan angka 8 + pesan **"Akurasi rendah, kalibrasi dulu"**. Jangan tampilkan panah "yakin" saat akurasi rendah |
| **Indikator akurasi** | Status live: Tinggi / Sedang / Rendah |
| **Fallback tanpa sensor** | Jika perangkat tanpa magnetometer → tampilkan **derajat arah kiblat** + instruksi manual, bukan kompas palsu |
| **Sudut & jarak (opsional)** | Derajat dari Utara + jarak ke Makkah, dapat disembunyikan |

**Alur utama:** Tap Qibla → (jika perlu) kalibrasi → panah aktif dengan status akurasi.

### 3.4 Tab 3 — Quran (placeholder / fase berikutnya)

- Disediakan sebagai slot stabil; rilis awal bisa menampilkan "Segera hadir" atau bacaan ringkas. Tidak menambah beban navigasi karena slot sudah dipesan.

### 3.5 Tab 4 — Hub (fitur tambahan modular)

Grid kartu yang dirender dari **feature-catalog** (metadata: id, ikon, route, tier free/premium, dukungan lokal, kapabilitas widget/wearable, aktif-per-region):

- Kalender Hijriah
- Tasbih Digital
- Pencari Masjid (butuh lokasi → opt-in)
- **Mode Ramadhan** (Imsak/Sahur, hitung mundur Iftar, Tarawih)
- Audio Adzan / Murottal
- Doa harian

> Kurasi penting agar Hub tidak menjadi "laci sampah": urutan berdasarkan pemakaian, item populer bisa dipromosikan ke Today.

### 3.6 Tab 5 — Settings (Pengaturan)

Hierarkis, dikelompokkan (bukan satu daftar datar):

| Grup | Isi |
| --- | --- |
| **Sholat** | Metode perhitungan, madzhab Ashar, koreksi menit per-waktu, offset Hijriah |
| **Notifikasi** | Toggle **per-sholat**, pilihan suara (Adzan/Getar/Senyap) **per-sholat**, pra-adzan reminder, kesadaran DND |
| **Lokasi** | Mode (GPS / Kota manual), izin & tombol revoke ke setelan OS |
| **Tampilan & Bahasa** | Tema, ukuran teks, kontras, **bahasa (termasuk Arab/RTL)**, format angka |
| **Privasi** | Dashboard izin, badge "Data tidak meninggalkan perangkat", daftar layanan pihak ketiga (idealnya "Tidak ada"), "Hapus semua data lokal", sembunyikan konten di lock screen |
| **Premium / Donasi** | Hapus iklan, suara adzan premium, murottal — **bukan** mengunci waktu sholat/kiblat |
| **Tentang** | Versi, kebijakan privasi bahasa sederhana, kredit |

---

## 4. Alur Pengguna Inti (Key User Flows)

### Flow A — Buka harian (glance)
```
Buka app → Today → lihat "Sholat berikutnya + hitung mundur" → (opsional) "Sudah sholat" → tutup
```

### Flow B — Cari arah kiblat
```
Today/top bar → Qibla → [akurasi rendah?] → kalibrasi (gerakan 8) → panah aktif + status akurasi
```

### Flow C — Notifikasi waktu sholat (app tertutup)
```
Scheduler lokal di perangkat → waktu sholat tiba → notifikasi (suara per-sholat sesuai setelan, hormati DND) → tap → buka Today
```

### Flow D — Privasi tanpa GPS
```
Onboarding/Settings → "Pilih kota manual" → cari kota → waktu sholat & kiblat dihitung tanpa izin lokasi
```

### Flow E — Mode Ramadhan
```
Hub → Mode Ramadhan → tampil Imsak/Sahur cutoff + hitung mundur Iftar + jadwal Tarawih
```

---

## 5. Pondasi Teknis yang Memengaruhi UI (agar tidak rombak ulang)

- **Headless Prayer Engine**: logika "hitung waktu sholat + countdown + bearing kiblat" dipisah sebagai service bersama → dipakai oleh layar Today, **widget home screen**, dan **wearable** secara independen dari app terbuka.
- **Feature-catalog ber-tipe**: Hub grid, pemilih widget, pohon settings, dan paywall semua dirender dari katalog yang sama (tambah fitur = tambah entri data, bukan layar baru).
- **i18n/RTL sejak awal**: semua string dieksternalisasi; layout pakai properti logis (start/end), uji locale Arab sebelum rilis.
- **Notifikasi lokal**: dijadwalkan di perangkat (tanpa push server) — uji keandalan terhadap **Android Doze / batas background iOS** sedini mungkin (ini risiko #1 uninstall).

---

## 6. Lingkup Rilis (Scope)

### MVP (v1) — minimal, defaults-first
- Onboarding (priming + metode + notifikasi)
- Today (countdown + 5 waktu + Hijriah + lokasi/offline)
- Qibla (kompas + gate kalibrasi + fallback derajat)
- Notifikasi per-sholat (suara per-sholat, DND-aware)
- Settings inti (Sholat, Notifikasi, Lokasi, Privasi, Bahasa)
- Mode kota manual (privasi)

### Fase berikutnya (v2+) — lewat Hub, tanpa rombak navigasi
- Mode Ramadhan, Kalender Hijriah, Tasbih, Pencari Masjid, Murottal/Quran, Widget & Wearable, Premium/Donasi.

---

## 7. Daftar Periksa Risiko (dari council)

- [ ] Metode perhitungan default benar untuk region (Kemenag utk Indonesia) & mudah diubah.
- [ ] Kompas kiblat punya **status akurasi + gate kalibrasi**; fallback untuk perangkat tanpa magnetometer.
- [ ] Notifikasi tidak berlebihan (toggle granular per-sholat) & hormati DND/senyap.
- [ ] Semua fungsi inti **bekerja offline**; tampilkan badge offline.
- [ ] **Sahur/Imsak cutoff** akurat di Mode Ramadhan (risiko membatalkan puasa).
- [ ] Tanpa SDK iklan/analitik yang membaca lokasi; sediakan layar Privasi yang dapat diperiksa.
- [ ] Opsi sembunyikan konten notifikasi di lock screen/wearable (jangan bocorkan jadwal ibadah).
- [ ] Uji keandalan notifikasi pada berbagai versi OS (Doze/background).
- [ ] Aksesibilitas: kontras outdoor, teks besar, satu tangan, RTL/Arab.
```

---

## 8. Design System — Neo-Brutalist Prayer Companion

> **name:** Neo-Brutalist Prayer Companion
> **description:** A bold, high-contrast design system for Islamic utility apps, featuring heavy strokes, vibrant accents, and high legibility.
> **version:** 1.1.0

Sistem ini dibangun di atas prinsip **Neo-Brutalism**: kejujuran material, kontras tinggi, dan kejelasan struktural. Dirancang khusus untuk aplikasi "Waktu Sholat" agar terasa modern, mudah diakses, dan berani.

### 8.1 Prinsip Inti

1. **Unapologetic Hierarchy** — Gunakan ketebalan & fill kontras tinggi untuk mengarahkan mata langsung ke data terpenting (mis. sholat berikutnya).
2. **Tactile Interactivity** — Tombol & toggle harus terasa "clickable" lewat hard shadow dan target sentuh minimal 44px.
3. **Friendly Brutalism** — Outline tegas dilembutkan oleh palet warna (Coral, Teal, Yellow) dan tipografi Poppins agar tetap ramah.

### 8.2 Color Tokens

**Base Surface**

| Token | Hex | Keterangan |
| --- | --- | --- |
| `surface` | `#fcf9f8` | Cream/Beige base |
| `surface-dim` | `#dcd9d9` | |
| `surface-bright` | `#fcf9f8` | |
| `surface-container-lowest` | `#ffffff` | |
| `surface-container-low` | `#f6f3f2` | |
| `surface-container` | `#f1edeb` | |
| `surface-container-high` | `#ebe7e5` | |
| `surface-container-highest` | `#e5e1df` | |

**Accents**

| Peran | Token | Hex |
| --- | --- | --- |
| Coral | `primary` | `#ff5a3c` |
| | `on-primary` | `#ffffff` |
| | `primary-container` | `#ffdad4` |
| | `on-primary-container` | `#3b0904` |
| Teal | `secondary` | `#2fd9a8` |
| | `on-secondary` | `#003828` |
| | `secondary-container` | `#b3f7df` |
| | `on-secondary-container` | `#002116` |
| Yellow | `tertiary` | `#ffc34d` |
| | `on-tertiary` | `#251a00` |
| | `tertiary-container` | `#ffe0a1` |
| | `on-tertiary-container` | `#251a00` |

**Borders & Shadows**

| Token | Hex | Keterangan |
| --- | --- | --- |
| `outline` | `#1c1b1b` | Hitam tegas untuk border & hard shadow |
| `outline-variant` | `#49454f` | |

### 8.3 Typography

| Peran | Keluarga | Skala |
| --- | --- | --- |
| Headings | **Poppins** | `display`: font-bold tracking-tight · `headline`: font-bold · `title`: font-semibold |
| Body | **Inter** | `body`: font-normal |

### 8.4 Borders, Radius & Shadows

- **Border**: width `3px`, style `solid`, color `#1c1b1b`
- **Radius**: `20px` (kartu), `full` (tombol & toggle)
- **Shadow hard**: `4px 4px 0px #1c1b1b`
- **Shadow none**: `0px 0px 0px transparent`

### 8.5 Component Specs

**Card**
- Base: `bg-white border-3 border-black rounded-[20px] p-4`
- States: `default` → shadow-none · `active` → `bg-primary text-white` · `highlighted` → `shadow-[4px_4px_0px_#1c1b1b]`

**Button — Primary**
- Base: `bg-black text-white rounded-full px-6 py-3 font-bold text-center h-[44px] min-w-[44px]`
- Interaction: `active:translate-x-[2px] active:translate-y-[2px] active:shadow-none transition-all`

**Toggle**
- Base: `w-[52px] h-[32px] rounded-full border-3 border-black p-1`
- Thumb: `bg-black rounded-full transition-transform`
- States: `on` → `bg-primary` · `off` → `bg-white`

### 8.6 Spacing

| Token | Nilai |
| --- | --- |
| `container` | `16px` |
| `stack` | `12px` |
| `inline` | `8px` |

### 8.7 Component Documentation

**Prayer Time Card** — unit fundamental aplikasi.
- *Normal*: background putih, border hitam 3px, radius 20px.
- *Active*: fill Coral, teks putih, hard shadow 4px — menandai "Sholat saat ini".
- *Content*: Poppins bold untuk waktu (mis. `04:30`), Inter untuk label (mis. `Subuh`).

**Navigation**
- *Top Bar*: bersih, sticky, pemisah halus lewat border bawah.
- *Bottom Bar*: ikon kontras tinggi dengan label jelas; state aktif memakai lingkaran coral khas.

### 8.8 Accessibility

- Target sentuh minimum **44px × 44px**.
- Rasio kontras **≥ 4.5:1** untuk seluruh teks fungsional.
- Border hitam tegas mendefinisikan batas elemen dengan jelas bagi pengguna low vision.
