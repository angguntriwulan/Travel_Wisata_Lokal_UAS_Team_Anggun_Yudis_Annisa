# 🗺️ Travel Wisata Lokal

## 👥 Tim Pengembang

| Peran       | Nama                   | NIM           |
| ----------- |------------------------|---------------|
| **Ketua**   | Yudistira Aditya Putra | STI202303625  |
| **Anggota** | Anggun Tri Wulan       | STI202303646  |
| **Anggota** | Annisa Nur Rahmah      | STI202303687  |


![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)

Aplikasi mobile berbasis Flutter untuk menemukan dan mengelola destinasi wisata lokal. Proyek ini dikembangkan sebagai tugas kelompok untuk mendemonstrasikan fitur CRUD dengan SQLite, integrasi peta, pencarian, dan manajemen tema.

---

## 📱 Splash Screen & Intro

Tampilan awal aplikasi dengan desain modern dan animasi ringan.

<p align="center">
  <img src="assets/images/splash.png" width="230">
</p>

---

## 🏠 Halaman Utama (Home)

Berisi daftar wisata dengan pencarian, filter, dan kartu informasi wisata.

### Light Mode

<p align="center">
  <img src="assets/images/home_light.png" width="230">
</p>

### Dark Mode

<p align="center">
  <img src="assets/images/home_dark.png" width="230">
</p>

---

## ℹ️ Detail Wisata

Menampilkan detail lengkap seperti foto, deskripsi, rating, harga tiket, dan jam operasional.

<p align="center">
  <img src="assets/images/detail.png" width="230">
</p>

---

## 🗺️ Peta Sebaran Lokasi

Menampilkan lokasi semua tempat wisata dalam satu peta, serta lokasi pengguna saat ini.

<p align="center">
  <img src="assets/images/maps.png" width="230">
</p>

---

## 📝 Form Tambah & Edit Wisata

Form untuk menambah atau mengubah data wisata, termasuk memilih titik koordinat melalui peta.

<p align="center">
  <img src="assets/images/form.png" width="230">
</p>

---

## ✨ Fitur Utama

- **CRUD Lengkap**: Tambah, lihat, edit, hapus data wisata.
- **SQLite Offline Database** (`sqflite`)
- **Integrasi Google Maps**:
  - Menampilkan semua lokasi wisata
  - Memilih titik lokasi
  - Deteksi posisi pengguna
- **Dark/Light Mode** dengan penyimpanan otomatis (`shared_preferences`)
- **Pencarian & Filter kategori**
- **Detail informasi wisata lengkap**
- **UI/UX modern**, custom icon, custom fonts, dan animasi

---

## 🛠️ Teknologi & Paket

- **Flutter (Dart)**
- **State Management:** `setState` native
- **Database:** `sqflite`, `path`
- **Maps:** `google_maps_flutter`
- **Utilities:**
  - `image_picker`
  - `shared_preferences`
  - `intl`
  - `permission_handler`
- **UI Assets:** `flutter_launcher_icons`

---
