# 🎟️ QinScan 

**QinScan** adalah solusi manajemen tiket dan pemindaian QR Code berbasis Flutter yang dirancang untuk kebutuhan pengelolaan acara skala besar. Aplikasi ini mengusung antarmuka modern dengan prinsip *Glassmorphism*, performa pemindaian real-time, dan integrasi API yang stabil.

## ✨ Fitur Utama

* **Pemindaian QR Neon**: Pemindai kamera dengan overlay animasi laser merah yang futuristik untuk verifikasi tiket instan.
* **Dashboard Statistik Real-time**: Visualisasi total tiket, tiket yang sudah digunakan (*redeemed*), dan sisa tiket dalam satu tampilan elegan.
* **Manajemen Peserta**: Fitur untuk menambah peserta baru dan melihat daftar aktif melalui modal bottom sheet yang interaktif.
* **Riwayat Scan (History)**: Dilengkapi halaman riwayat khusus untuk melacak semua tiket yang telah sukses diverifikasi.
* **Pass Digital & QR Generator**: Halaman detail tiket dengan desain perforasi klasik yang memungkinkan admin mengunduh kode QR langsung ke galeri ponsel.
* **Mode Gelap & Terang**: Dukungan penuh untuk tema gelap (*Dark Mode*) guna kenyamanan penggunaan di berbagai kondisi pencarian.

## 🛠️ Teknologi & Library

* **Framework**: Flutter (Material 3).
* **State Management**: StatefulWidget & Scoped Theme Switching.
* **Networking**: Dio (untuk komunikasi REST API).
* **Scanner**: Mobile Scanner.
* **QR Logic**: QR Flutter.
* **Storage**: Shared Preferences (untuk autentikasi dan preferensi tema).

## 🚀 Cara Instalasi

1.  **Clone repositori ini**:
    ```bash
    git clone [https://github.com/username/QR_Scanner.git](https://github.com/username/QR_Scanner.git)
    ```

2.  **Masuk ke direktori proyek**:
    ```bash
    cd QR_Scanner
    ```

3.  **Instal semua paket yang diperlukan**:
    ```bash
    flutter pub get
    ```

4.  **Jalankan aplikasi**:
    ```bash
    flutter run
    ```

## 📂 Struktur Proyek

* `lib/models/`: Definisi data `Ticket` dan serialisasi JSON.
* `lib/services/`: Logika integrasi API menggunakan Dio.
* `lib/views/`: Berisi semua halaman UI (Login, Home, Scanner, History, Detail).
* `lib/main.dart`: Konfigurasi tema global dan entry point aplikasi.

## 📝 Lisensi

Proyek ini berada di bawah lisensi MIT.

---

**Dikembangkan oleh Athallah Muhammad Ghiyast Qinthara**
