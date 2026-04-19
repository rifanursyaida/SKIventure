# 🦉 SKIventure

> **Belajar jadi seru!** — Aplikasi gamifikasi pembelajaran berbasis Flutter & Firebase dengan tema Duolingo-style.

---

## 📱 Tentang Aplikasi

SKIventure adalah aplikasi mobile edukatif yang dirancang untuk membuat proses belajar mengajar menjadi lebih interaktif dan menyenangkan. Guru dapat mengelola siswa, absensi, dan materi quiz; sementara siswa dapat mengikuti quiz, melihat leaderboard, dan memantau progress belajar mereka.

---

## ✨ Fitur Utama

### 👨‍🏫 Guru (Teacher)
- **Login** dengan email & password
- **Tambah Siswa** ke dalam kelas
- **Kelola Absensi** — input kehadiran harian siswa
- **Rekap Absensi** — review seluruh data kehadiran kelas
- **Hasil Quiz** — lihat skor dan progress setiap siswa

### 🎓 Siswa (Student)
- **Login** cukup dengan nama
- **Leaderboard Kelas** — peringkat berdasarkan skor quiz
- **Quiz Interaktif** — 4 topik Khalifah Islam
- **Absensi Mandiri** — catat kehadiran sendiri
- **Profil** — lihat data diri dan perkembangan

---

## 🗂️ Struktur Halaman

```
lib/
├── main.dart                  # Entry point & TeacherHomePage
├── session.dart               # Global session (userId, role, dll)
└── pages/
    ├── login_page.dart        # Login guru & siswa
    ├── leaderboard_page.dart  # Home siswa + leaderboard
    ├── materi_page.dart       # Halaman materi
    ├── quiz_page.dart         # Quiz interaktif
    ├── absensi_page.dart      # Input absensi
    ├── attendance_review.dart # Rekap absensi (guru)
    ├── quiz_review_page.dart  # Rekap hasil quiz (guru)
    ├── add_student_page.dart  # Tambah siswa baru
    └── profile_page.dart      # Profil siswa
```

---

## 🔥 Struktur Firestore

### Koleksi `users` — data guru
```
users/{teacherId}
  ├── name        : String
  ├── email       : String
  ├── password    : String
  └── role        : "teacher"
```

### Koleksi `students` — data siswa
```
students/{studentId}
  ├── name        : String
  ├── kelas       : String
  ├── teacher_id  : String
  └── created_at  : Timestamp
```

### Koleksi `attendance` — data absensi
```
attendance/{docId}
  ├── student_id  : String  (ref ke students)
  ├── teacher_id  : String
  ├── status      : "hadir" | "izin" | "sakit"
  ├── date        : Timestamp
  └── created_at  : Timestamp
```

### Koleksi `quiz_results` — hasil quiz
```
quiz_results/{docId}
  ├── student_id      : String  (ref ke students)
  ├── teacher_id      : String
  ├── materi_id       : "abu_bakar" | "umar" | "utsman" | "ali"
  ├── score           : Number
  ├── correct_answer  : Number
  ├── total_question  : Number
  └── created_at      : Timestamp
```

---

## ⚙️ Firestore Index yang Dibutuhkan

Buat **Composite Index** berikut di Firebase Console agar query berjalan:

| Collection | Fields | Order |
|---|---|---|
| `attendance` | `teacher_id` ASC + `created_at` DESC | — |
| `quiz_results` | `teacher_id` ASC + `score` DESC | — |
| `quiz_results` | — | `created_at` DESC |

> Jika query gagal, Flutter console akan menampilkan link langsung untuk auto-create index.

---

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Akun Firebase (Firestore aktif)
- Android Studio / VS Code

### Langkah-langkah

**1. Clone repository**
```bash
git clone https://github.com/username/skiventure.git
cd skiventure
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Setup Firebase**
- Buat project baru di [Firebase Console](https://console.firebase.google.com)
- Aktifkan **Cloud Firestore**
- Download `google-services.json` (Android) dan/atau `GoogleService-Info.plist` (iOS)
- Taruh file tersebut di folder yang sesuai:
    - Android: `android/app/google-services.json`
    - iOS: `ios/Runner/GoogleService-Info.plist`

**4. Jalankan aplikasi**
```bash
flutter run
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cloud_firestore: ^5.x.x
  firebase_core: ^3.x.x
  flutter_animate: ^4.x.x
```

---

## 🎨 Design System

SKIventure menggunakan **Duolingo-style light theme** yang konsisten di seluruh halaman.

| Token | Nilai | Kegunaan |
|---|---|---|
| `green` | `#58CC02` | Primary, CTA, header |
| `greenDark` | `#46A302` | Shadow tombol 3D |
| `blue` | `#1CB0F6` | Aksi sekunder |
| `yellow` | `#FFB100` | Peringatan, ranking |
| `red` | `#FF4B4B` | Error, tidak hadir |
| `ink` | `#3C3C3C` | Teks utama |
| `inkLight` | `#AFAFAF` | Teks sekunder, placeholder |
| `polar` | `#F7F7F7` | Background halaman |
| `snow` | `#FFFFFF` | Background card |
| `borderGray` | `#E5E5E5` | Border card |

### Komponen Khas
- **Tombol 3D** — `border-bottom` lebih gelap untuk efek raised
- **AppBar hijau melengkung** — `borderRadius` di sudut bawah
- **Status badge pill** — rounded dengan shadow 3D
- **Card dengan shadow solid** — `BoxShadow` offset tanpa blur

---

## 📝 Topik Quiz

| ID | Topik |
|---|---|
| `abu_bakar` | Abu Bakar Ash-Shiddiq |
| `umar` | Umar bin Khattab |
| `utsman` | Utsman bin Affan |
| `ali` | Ali bin Abi Thalib |

---

## 🔐 Catatan Keamanan

> ⚠️ Aplikasi ini saat ini menyimpan password sebagai **plain text** di Firestore. Untuk production, gunakan **Firebase Authentication** sebagai pengganti sistem login manual.

---

## 👨‍💻 Developer

Dibuat dengan ❤️ menggunakan Flutter & Firebase.

---

*© SKIventure 2026*