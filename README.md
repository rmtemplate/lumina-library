# Lumina Library

<p align="center">
  <img src="assets/images/logo/lumina-logo.webp" width="180" alt="Lumina Library Logo"/>
</p>

<p align="center">
  <b>Modern Digital Campus Library App</b><br>
  Built with Flutter • GetX • Clean Architecture
</p>


**Lumina Library** adalah aplikasi perpustakaan modern berbasis Flutter yang dibuat untuk kebutuhan **Tugas Kuliah**. Aplikasi ini menyediakan alur penggunaan untuk dua role utama, yaitu **Mahasiswa** dan **Staff/Petugas Perpustakaan**.

Project ini disusun menggunakan pendekatan struktur folder yang clean, scalable, dan reusable melalui pemisahan `core`, `shared`, dan `features`.

---

## Informasi Project

| Informasi | Keterangan |
|---|---|
| Nama Project | **Lumina Library** |
| Jenis Project | **Sistem Perpustakaan Digital Kampus** |
| Platform | **Flutter Mobile Application** |
| Deskripsi | Aplikasi perpustakaan digital kampus berbasis Flutter dengan fitur manajemen buku, pencarian koleksi, peminjaman, pengembalian, riwayat transaksi, serta dashboard mahasiswa dan petugas perpustakaan. |
| Keterangan | **Project Tugas Kuliah** dengan konsep modern UI/UX dan clean architecture. |
| Redirect Website | Mendukung redirect ke website resmi kampus atau website developer melalui browser eksternal/WebView. |
| Website Developer | https://rmtemplate.com |
| Author | **Reza Maulana / RM Template** |
| License | **MIT License** |

---

## Fitur Utama

### Mahasiswa

- Splash screen dan onboarding.
- Home dashboard.
- Catalog buku.
- Detail buku.
- Search ala TikTok:
  - history search,
  - trending keyword,
  - buku terakhir dilihat,
  - buku trending,
  - search result page terpisah.
- Cart peminjaman.
- Checkout peminjaman.
- Date range peminjaman.
- Alert batas maksimal pengembalian.
- My Books.
- Profile.

### Staff / Petugas

- Dashboard petugas.
- Statistik perpustakaan.
- Quick actions.
- Recent activity.
- QR scanner untuk proses peminjaman atau validasi.
- Input manual jika QR tidak dapat discan.
- Reports placeholder.

---

## Tech Stack

- Flutter
- Dart
- GetX
- Mobile Scanner
- Custom Lumina Design System

---

## Requirements

Pastikan perangkat sudah terinstall:

```bash
flutter --version
dart --version
```

Minimal rekomendasi:

```txt
Flutter 3.x
Dart 3.x
```

---

## Installation

Clone atau copy project ini ke local device.

```bash
git clone <repository-url>
cd lumina_library
```

Install dependency:

```bash
flutter pub get
```

Jika dependency scanner belum tersedia, jalankan:

```bash
flutter pub add mobile_scanner
```

Jika GetX belum tersedia, jalankan:

```bash
flutter pub add get
```

---

## Dependencies

Pastikan `pubspec.yaml` memiliki dependency berikut:

```yaml
dependencies:
  flutter:
    sdk: flutter

  get: ^4.6.6
  mobile_scanner: ^5.0.0
```

---

## Run Project

Run di Chrome:

```bash
flutter run -d chrome
```

Run di Android emulator atau device:

```bash
flutter run
```

Run dengan memilih device:

```bash
flutter devices
flutter run -d <device-id>
```

---

## Build Project

Build Android APK:

```bash
flutter build apk --release
```

Build Web:

```bash
flutter build web
```

---

## Permission Setup

### Android Camera Permission

Tambahkan permission berikut di:

```txt
android/app/src/main/AndroidManifest.xml
```

Letakkan di atas tag `<application>`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

Contoh:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.INTERNET" />

    <application>
        ...
    </application>
</manifest>
```

### iOS Camera Permission

Tambahkan di:

```txt
ios/Runner/Info.plist
```

```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi membutuhkan akses kamera untuk scan QR peminjaman buku</string>
```

### Web / Chrome Camera Permission

Untuk QR scanner di Chrome, pastikan aplikasi berjalan di:

```txt
localhost
```

atau domain HTTPS. Setelah itu izinkan akses kamera dari browser.

---

## Struktur Folder

```txt
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── routing/
│   │   └── lumina_role_router.dart
│   ├── theme/
│   │   ├── lumina_colors.dart
│   │   ├── lumina_radius.dart
│   │   ├── lumina_spacing.dart
│   │   ├── lumina_text_styles.dart
│   │   └── lumina_theme.dart
│   └── utils/
│
├── exports/
│   ├── lumina.dart
│   ├── lumina_models.dart
│   └── lumina_widgets.dart
│
├── shared/
│   ├── models/
│   │   ├── activity/
│   │   │   └── library_activity_model.dart
│   │   ├── banner/
│   │   │   └── library_banner_model.dart
│   │   ├── book/
│   │   │   ├── borrowed_book_model.dart
│   │   │   └── cart_book_model.dart
│   │   ├── menu/
│   │   │   └── quick_action_model.dart
│   │   ├── navigation/
│   │   │   └── bottom_nav_item_model.dart
│   │   └── statistic/
│   │       └── statistic_card_model.dart
│   │
│   └── widgets/
│       ├── app/
│       │   └── lumina_app_top_bar.dart
│       ├── book/
│       │   └── lumina_book_card.dart
│       ├── card/
│       │   └── lumina_stat_card.dart
│       ├── feedback/
│       │   └── lumina_empty_state.dart
│       ├── form/
│       │   └── lumina_search_field.dart
│       ├── layout/
│       │   └── lumina_section_header.dart
│       └── navigation/
│           └── lumina_role_bottom_nav_bar.dart
│
└── features/
    ├── auth/
    │   └── presentation/
    │       ├── controllers/
    │       ├── models/
    │       ├── pages/
    │       └── widgets/
    │
    ├── splash/
    │   └── presentation/
    │       └── pages/
    │
    ├── onboarding/
    │   └── presentation/
    │       └── pages/
    │
    ├── mahasiswa/
    │   └── presentation/
    │       ├── controllers/
    │       ├── models/
    │       ├── pages/
    │       └── widgets/
    │
    └── staff/
        └── presentation/
            ├── controllers/
            ├── models/
            ├── pages/
            └── widgets/
```

---

## Export File

Gunakan file export agar import lebih rapi.

### Import semua model

```dart
import 'package:lumina_library/exports/lumina_models.dart';
```

Isi export model:

```dart
export '../shared/models/book/cart_book_model.dart';
export '../shared/models/book/borrowed_book_model.dart';
export '../shared/models/statistic/statistic_card_model.dart';
export '../shared/models/menu/quick_action_model.dart';
export '../shared/models/activity/library_activity_model.dart';
export '../shared/models/banner/library_banner_model.dart';
```

### Import semua widget

```dart
import 'package:lumina_library/exports/lumina_widgets.dart';
```

Isi export widget:

```dart
export '../shared/widgets/app/lumina_app_top_bar.dart';
export '../shared/widgets/book/lumina_book_card.dart';
export '../shared/widgets/card/lumina_stat_card.dart';
export '../shared/widgets/layout/lumina_section_header.dart';
export '../shared/widgets/navigation/lumina_role_bottom_nav_bar.dart';
export '../shared/widgets/feedback/lumina_empty_state.dart';
export '../shared/widgets/form/lumina_search_field.dart';
```

---

## Role Based Routing

Routing role digunakan untuk menentukan halaman awal setelah login.

Contoh:

```dart
void navigateAfterLogin(String role) {
  final normalizedRole = role.trim().toUpperCase();

  if (normalizedRole == 'PETUGAS' ||
      normalizedRole == 'STAFF' ||
      normalizedRole == 'LIBRARIAN' ||
      normalizedRole == 'ADMIN') {
    Get.offAll(
      () => const LibraryStaffHomePage(),
      transition: Transition.fadeIn,
    );
    return;
  }

  Get.offAll(
    () => const LibraryHomePage(),
    transition: Transition.fadeIn,
  );
}
```

Role mahasiswa diarahkan ke:

```dart
LibraryHomePage()
```

Role staff/petugas diarahkan ke:

```dart
LibraryStaffHomePage()
```

---

## Staff QR Scanner Flow

QR scanner dibuka sebagai halaman baru, bukan tab bottom navigation.

Contoh implementasi:

```dart
void _onNavigationChanged(int index) {
  if (index == 1) {
    _goToQrScannerPage();
    return;
  }

  if (_selectedIndex == index) return;

  setState(() {
    _selectedIndex = index;
  });
}

Future<void> _goToQrScannerPage() async {
  final result = await Navigator.of(context).push<String>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const StaffQrScannerPage(),
    ),
  );

  if (!mounted || result == null || result.trim().isEmpty) return;

  debugPrint('QR scan result: $result');
}
```

Dengan cara ini, bottom navigation tetap berada di tab sebelumnya, sedangkan scanner muncul sebagai fullscreen page.

---

## Search Flow

Search dibuat seperti aplikasi TikTok:

1. User klik icon search di top bar.
2. Masuk ke Search Page.
3. Search Page menampilkan:
   - history search,
   - trending keyword,
   - buku terakhir dilihat,
   - buku trending.
4. Saat user tekan enter/search, user diarahkan ke Search Result Page.
5. Hasil pencarian tampil di Search Result Page.

Search Page tidak menampilkan empty state `Buku tidak ditemukan`.

---

## Cart dan Checkout Flow

1. User menambahkan buku ke cart.
2. Pada cart, user memilih buku dengan checkbox.
3. Tombol checkout aktif jika minimal satu buku dicentang.
4. Checkout hanya menampilkan buku yang dicentang.
5. Periode pinjam memakai date range picker.
6. Alert checkout menampilkan batas maksimal tanggal pengembalian.

State cart dikelola menggunakan GetX controller.

---

## Coding Guideline

- Pisahkan page, widget, controller, dan model.
- Jangan letakkan model di dalam file page.
- Jangan duplikasi widget antara Staff dan Mahasiswa.
- Widget yang reusable wajib diletakkan di `shared/widgets`.
- Model yang reusable wajib diletakkan di `shared/models`.
- Page hanya bertugas menyusun layout.
- Controller bertugas mengatur state dan logic.
- Private widget boleh tetap di page jika hanya digunakan sekali.
- Gunakan import yang konsisten agar tidak terjadi error type GetX.

---

## Import Convention

Gunakan import relatif untuk file di dalam feature yang sama:

```dart
import '../controllers/library_search_controller.dart';
import '../widgets/library_trending_book_card.dart';
```

Gunakan export untuk shared widget/model:

```dart
import 'package:lumina_library/exports/lumina_widgets.dart';
import 'package:lumina_library/exports/lumina_models.dart';
```

Hindari mencampur import berikut untuk file yang sama:

```dart
import '../controllers/library_search_controller.dart';
```

dan:

```dart
import 'package:lumina_library/features/library/presentation/controllers/library_search_controller.dart';
```

Hal tersebut bisa menyebabkan error GetX seperti:

```txt
TypeError: Instance of 'LibrarySearchController':
type 'LibrarySearchController' is not a subtype of type 'LibrarySearchController'
```

Solusi:

```bash
flutter clean
flutter pub get
flutter run
```

---

## Development Notes

Untuk testing role staff, ubah sementara `home` di `app.dart`:

```dart
home: const LibraryStaffHomePage(),
```

Untuk testing role mahasiswa:

```dart
home: const LibraryHomePage(),
```

Atau gunakan role router:

```dart
home: LuminaRoleRouter.getHomeByRole('STAFF'),
```

```dart
home: LuminaRoleRouter.getHomeByRole('MAHASISWA'),
```

---

## Troubleshooting

### Kamera tidak muncul di Chrome

Pastikan:

- App berjalan di `localhost`.
- Browser sudah memberi permission kamera.
- Tidak ada aplikasi lain yang sedang memakai kamera.

### QR scanner blank di mobile

Pastikan:

- Permission kamera sudah ditambahkan.
- App sudah di-rebuild, bukan hanya hot reload.
- Jalankan ulang app setelah menambah permission.

### Image network tidak tampil

Pastikan permission internet Android sudah ditambahkan:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### Error GetX controller type

Gunakan import path yang konsisten, lalu jalankan:

```bash
flutter clean
flutter pub get
flutter run
```

---

## License

MIT License

Copyright (c) 2026 Reza Maulana

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files, to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the software,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the software.

This project is created as a college assignment (**Tugas Kuliah**) and may be
used as a learning reference or template under the name **RM Template**.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHOR OR COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.