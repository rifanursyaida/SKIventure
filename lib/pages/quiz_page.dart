import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

// ════════════════════════════════════════════════════════════════════════════
//  quiz_page.dart
//  SKIVENTURE – Khulafaur Rasyidin Learning App
//  Target : SMP/MTs (usia 12–15 tahun)
//  Theme  : Emerald Green (#2ecc71) + Soft Gold (#f1c40f)
//  Dep    : video_player: ^2.8.3
// ════════════════════════════════════════════════════════════════════════════

// ─── COLOURS ─────────────────────────────────────────────────────────────────
class _C {
  static const Color emerald     = Color(0xFF2ECC71);
  static const Color emeraldDark = Color(0xFF27AE60);
  static const Color emeraldDeep = Color(0xFF1A7A4A);
  static const Color gold        = Color(0xFFF1C40F);
  static const Color goldDark    = Color(0xFFD4AC0D);
  static const Color bg          = Color(0xFFF4F7F5);
  static const Color card        = Color(0xFFFFFFFF);
  static const Color dark        = Color(0xFF0F1923);
  static const Color textDark    = Color(0xFF1A1A2E);
  static const Color textMid     = Color(0xFF4A4A6A);
  static const Color textLight   = Color(0xFF9090AA);
  static const Color correct     = Color(0xFF27AE60);
  static const Color wrong       = Color(0xFFE74C3C);
  static const Color optionBg    = Color(0xFFF0F4F2);
  static const Color shadow      = Color(0x14000000);
}

// ─── MODEL: SOAL ─────────────────────────────────────────────────────────────
class QuizQuestion {
  final String question;
  final List<String> options;   // selalu 4 pilihan
  final int correctIndex;       // 0-based
  final String explanation;
  final String ibrah;
  final int score;              // C1-C2→10, C3-C4→15, C5-C6→20

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.ibrah,
    required this.score,
  });
}

// ─── MODEL: LEVEL ────────────────────────────────────────────────────────────
class QuizLevel {
  final String title;
  final String subtitle;
  final String videoPath;
  final IconData icon;
  final Color color;
  final List<int> timestamps;        // detik tempat video berhenti
  final List<QuizQuestion> questions;

  const QuizLevel({
    required this.title,
    required this.subtitle,
    required this.videoPath,
    required this.icon,
    required this.color,
    required this.timestamps,
    required this.questions,
  });

  int get maxScore =>
      questions.fold(0, (sum, q) => sum + q.score) +
          questions.length * 5; // maks semua dapat bonus
}

// ════════════════════════════════════════════════════════════════════════════
//  DATA SOAL — diambil verbatim dari dokumen
//  BANK SOAL KUIS GAME – Aplikasi Skiventure
//  Materi Khulafaur Rasyidin – SKI Kelas X MA
// ════════════════════════════════════════════════════════════════════════════
final List<QuizLevel> quizLevels = [

  // ══════════════════════════════════════════════════════════════════════════
  //  LEVEL 1 — ABU BAKAR ASH-SHIDDIQ
  // ══════════════════════════════════════════════════════════════════════════
  QuizLevel(
    title: 'Abu Bakar Ash-Shiddiq',
    subtitle: 'Khalifah Pertama · 11–13 H',
    videoPath: 'lib/videos/abu_bakar.mp4',
    icon: Icons.wb_sunny_rounded,
    color: const Color(0xFF0D9373),
    timestamps: [20, 55, 90, 125, 160],
    questions: [
      // Soal 1 — C1 (skor 10)
      QuizQuestion(
        question:
        'Gelar "Ash-Shiddiq" yang disematkan kepada Abu Bakar diperoleh '
            'karena alasan...',
        options: [
          'Ia adalah orang pertama yang masuk Islam dari kalangan laki-laki dewasa',
          'Ia segera membenarkan Nabi dalam berbagai peristiwa, terutama Isra\' dan Mi\'raj',
          'Ia berhasil memimpin perang melawan kaum murtad dengan gemilang',
          'Ia menghafal seluruh Al-Qur\'an sejak masa Rasulullah masih hidup',
        ],
        correctIndex: 1,
        explanation:
        'Gelar Ash-Shiddiq berarti "yang membenarkan". Abu Bakar mendapat gelar ini '
            'karena ia dengan segera membenarkan Nabi Muhammad dalam berbagai peristiwa '
            'penting, terutama peristiwa Isra\' dan Mi\'raj yang saat itu banyak orang '
            'meragukannya.',
        ibrah:
        'Keberanian meyakini kebenaran meski banyak orang meragukannya '
            'adalah sifat mulia yang perlu kita teladani.',
        score: 10,
      ),

      // Soal 2 — C2 (skor 10)
      QuizQuestion(
        question:
        'Mengapa Perang Yamamah menjadi salah satu pemicu awal inisiatif '
            'pembukuan Al-Qur\'an secara resmi?',
        options: [
          'Karena perang Yamamah menghancurkan naskah-naskah Al-Qur\'an yang tersimpan di Madinah',
          'Karena dalam perang Yamamah gugur lebih dari 70 penghafal Al-Qur\'an sehingga memunculkan kekhawatiran hilangnya Al-Qur\'an',
          'Karena Rasulullah memerintahkan pembukuan Al-Qur\'an sebelum terjadinya perang Yamamah',
          'Karena setelah perang Yamamah banyak orang kafir yang merusak catatan-catatan Al-Qur\'an',
        ],
        correctIndex: 1,
        explanation:
        'Perang Yamamah menyebabkan gugurnya lebih dari 70 penghafal (huffaz) Al-Qur\'an. '
            'Fakta ini mendorong Umar bin Khattab untuk mengusulkan kepada Abu Bakar agar '
            'Al-Qur\'an segera dikumpulkan dan dibukukan secara resmi, guna mencegah '
            'hilangnya Al-Qur\'an bersama wafatnya para penghafal.',
        ibrah:
        'Menjaga warisan ilmu dan wahyu adalah kewajiban kolektif umat — '
            'satu nyawa yang berilmu bisa membawa dampak luar biasa jika hilang.',
        score: 10,
      ),

      // Soal 3 — C4 (skor 15)
      QuizQuestion(
        question:
        'Abu Bakar memilih jalur persuasi sebelum operasi militer terhadap '
            'kaum murtad, dan menerima usulan pembukuan Al-Qur\'an meski awalnya ragu. '
            'Apa yang dapat dianalisis dari pola pengambilan keputusannya?',
        options: [
          'Abu Bakar cenderung mengikuti semua usulan sahabat tanpa pertimbangan sendiri',
          'Abu Bakar adalah pemimpin yang mengutamakan musyawarah, bertahap dalam tindakan, dan mampu menerima ijtihad baru demi kemaslahatan',
          'Abu Bakar hanya berani mengambil keputusan tegas dalam urusan militer saja',
          'Abu Bakar selalu mengikuti preseden Rasulullah tanpa pernah berinovasi',
        ],
        correctIndex: 1,
        explanation:
        'Dari kedua kebijakan tersebut terlihat pola kepemimpinan Abu Bakar yang matang: '
            'ia mendahulukan komunikasi (persuasi) sebelum tindakan keras, dan mampu '
            'berijtihad — menerima usulan pembukuan Al-Qur\'an yang belum ada preseden '
            'sebelumnya — demi kemaslahatan umat.',
        ibrah:
        'Pemimpin yang bijak tidak tergesa-gesa dalam bertindak dan '
            'terbuka menerima ide baru yang membawa kebaikan.',
        score: 15,
      ),

      // Soal 4 — C4 (skor 15)
      QuizQuestion(
        question:
        'Abu Bakar menunjuk Zaid bin Tsabit sebagai koordinator pengumpulan '
            'Al-Qur\'an. Mengapa pemilihan tokoh ini strategis?',
        options: [
          'Karena Zaid bin Tsabit adalah sahabat tertua yang masih hidup saat itu',
          'Karena Zaid bin Tsabit adalah sekretaris Rasulullah yang terbiasa mencatat wahyu, sehingga paling kompeten dalam bidang ini',
          'Karena Zaid bin Tsabit adalah satu-satunya penghafal Al-Qur\'an yang selamat dari perang Yamamah',
          'Karena Zaid bin Tsabit adalah menantu Abu Bakar yang paling dipercaya',
        ],
        correctIndex: 1,
        explanation:
        'Pemilihan Zaid bin Tsabit sangat strategis karena ia adalah sekretaris wahyu '
            'Rasulullah — ia terbiasa mencatat ayat-ayat Al-Qur\'an langsung dari Nabi. '
            'Kompetensinya menjadikan hasil kompilasi lebih akurat dan dapat '
            'dipertanggungjawabkan secara keilmuan.',
        ibrah:
        'Menempatkan orang yang tepat sesuai keahliannya adalah prinsip '
            'kepemimpinan yang tidak lekang oleh waktu.',
        score: 15,
      ),

      // Soal 5 — C5 (skor 20)
      QuizQuestion(
        question:
        'Di era modern, pelajar menghadapi informasi yang tersebar di berbagai '
            'platform digital — ada yang valid, ada yang hoaks. Nilai kepemimpinan '
            'Abu Bakar yang paling relevan untuk menghadapi situasi ini adalah...',
        options: [
          'Keberanian berperang dan tidak takut menghadapi tantangan',
          'Kebiasaan bermusyawarah dan memverifikasi kebenaran sebelum mengambil sikap, sebagaimana Abu Bakar memverifikasi sebelum menerima usulan pembukuan Al-Qur\'an',
          'Sikap tunduk pada pemimpin dan tidak banyak bertanya',
          'Kemampuan mengumpulkan banyak pengikut untuk mendukung keputusannya',
        ],
        correctIndex: 1,
        explanation:
        'Abu Bakar selalu mengedepankan verifikasi dan musyawarah sebelum mengambil '
            'keputusan besar. Sikap kritis dan tidak tergesa-gesa ini sangat relevan '
            'dengan literasi digital: verifikasi informasi sebelum menyebarkannya.',
        ibrah:
        'Tabayun (verifikasi) adalah sunnah para pemimpin terbaik. '
            'Di era informasi, tabayun adalah ibadah.',
        score: 20,
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════════════════
  //  LEVEL 2 — UMAR BIN KHATTAB
  // ══════════════════════════════════════════════════════════════════════════
  QuizLevel(
    title: 'Umar bin Khattab',
    subtitle: 'Khalifah Kedua · 13–23 H',
    videoPath: 'lib/videos/umar.mp4',
    icon: Icons.bolt_rounded,
    color: const Color(0xFF1D4ED8),
    timestamps: [20, 55, 90, 125, 160],
    questions: [
      // Soal 6 — C1 (skor 10)
      QuizQuestion(
        question:
        'Sistem penanggalan yang ditetapkan pada masa Umar bin Khattab '
            'dihitung mulai dari peristiwa apa?',
        options: [
          'Kelahiran Nabi Muhammad SAW di Makkah',
          'Turunnya wahyu pertama di Gua Hira',
          'Hijrahnya Rasulullah dari Makkah ke Madinah pada 16 Juli 622 M',
          'Penaklukan kota Makkah (Fathu Makkah)',
        ],
        correctIndex: 2,
        explanation:
        'Kalender Hijriah yang ditetapkan pada masa Umar bin Khattab dihitung '
            'mulai dari peristiwa hijrahnya Rasulullah SAW dari Makkah ke Madinah, '
            'yaitu pada 16 Juli 622 M. Penanggalan ini digunakan hingga saat ini '
            'sebagai kalender resmi umat Islam.',
        ibrah:
        'Sistem dan administrasi yang baik adalah warisan peradaban yang '
            'bertahan lebih lama dari kekuatan militer.',
        score: 10,
      ),

      // Soal 7 — C2 (skor 10)
      QuizQuestion(
        question:
        'Mengapa Umar bin Khattab merasa perlu membuat sistem penanggalan '
            'Hijriah? Apa masalah konkret yang melatarbelakanginya?',
        options: [
          'Karena umat Islam ingin memiliki identitas tersendiri yang berbeda dari kalender Romawi dan Persia',
          'Karena permasalahan surat-menyurat pemerintah — setiap surat hanya mencantumkan tanggal dan bulan tanpa tahun, sehingga arsip negara kacau',
          'Karena para ulama meminta Umar untuk mencatat sejarah Islam secara kronologis',
          'Karena pedagang Muslim kesulitan bertransaksi akibat perbedaan sistem kalender',
        ],
        correctIndex: 1,
        explanation:
        'Masalah yang konkret adalah kekacauan pengarsipan surat-menyurat negara — '
            'setiap surat hanya mencantumkan tanggal dan bulan tanpa tahun. Umar kemudian '
            'bermusyawarah dengan para sahabat dan mereka sepakat menetapkan sistem Hijriah.',
        ibrah:
        'Inovasi terbaik lahir dari kepekaan terhadap masalah nyata di sekitar kita, '
            'bukan dari keinginan pamer kecanggihan.',
        score: 10,
      ),

      // Soal 8 — C4 (skor 15)
      QuizQuestion(
        question:
        'Umar bin Khattab membentuk berbagai lembaga kenegaraan seperti '
            'Departemen Pajak, Lembaga Kepolisian, dan Lembaga Militer. '
            'Apa yang dapat dianalisis dari langkah ini?',
        options: [
          'Umar hanya meniru sistem pemerintahan Persia dan Romawi tanpa inovasi apapun',
          'Langkah ini menunjukkan bahwa Umar membangun negara berbasis institusi — bukan berbasis individu — sehingga sistem dapat berjalan tanpa bergantung pada satu orang',
          'Pembentukan lembaga-lembaga ini terbukti gagal karena wilayah Islam terus bergolak',
          'Umar membentuk lembaga-lembaga ini semata untuk memperkuat kekuatan militer',
        ],
        correctIndex: 1,
        explanation:
        'Pembentukan lembaga-lembaga kenegaraan yang terstruktur menunjukkan visi Umar '
            'dalam membangun negara berbasis institusi (bukan personal). Ini adalah reformasi '
            'tata kelola yang sangat maju untuk zamannya — sistem yang tidak runtuh '
            'ketika pemimpinnya berganti.',
        ibrah:
        'Negara yang kuat bukan bergantung pada satu tokoh karismatik, '
            'melainkan pada sistem dan institusi yang kokoh.',
        score: 15,
      ),

      // Soal 9 — C5 (skor 20)
      QuizQuestion(
        question:
        'Umar bin Khattab sangat selektif dalam mengangkat pejabat dan tidak '
            'segan mengganti mereka jika ada yang lebih kompeten. Bandingkan '
            'prinsip ini dengan tuduhan nepotisme pada masa Utsman bin Affan. '
            'Pelajaran apa yang paling tepat diambil?',
        options: [
          'Seorang pemimpin harus selalu memilih orang dari kalangan keluarganya agar lebih loyal',
          'Menempatkan orang berdasarkan kompetensi dan integritas — bukan kedekatan personal — adalah kunci tata kelola yang adil dan legitimatif',
          'Pemimpin sebaiknya tidak terlalu sering mengganti pejabat agar situasi tetap stabil',
          'Nepotisme dapat dibenarkan selama orang yang dipilih masih memiliki kemampuan dasar',
        ],
        correctIndex: 1,
        explanation:
        'Kontras antara Umar yang selektif berbasis kompetensi dan permasalahan '
            'nepotisme pada masa Utsman mengajarkan: legitimasi pemimpin terbangun '
            'dari keadilan dalam penunjukan jabatan. Memilih berdasarkan kualifikasi, '
            'bukan hubungan darah, adalah pondasi tata kelola yang baik.',
        ibrah:
        'Jabatan adalah amanah — menempatkannya pada orang yang tidak layak '
            'adalah bentuk pengkhianatan terhadap rakyat.',
        score: 20,
      ),

      // Soal 10 — C6 (skor 20)
      QuizQuestion(
        question:
        'Jika kamu adalah seorang ketua OSIS dan ingin menerapkan prinsip '
            'kepemimpinan Umar bin Khattab, program konkret apa yang paling '
            'mencerminkan nilai-nilainya?',
        options: [
          'Membuat program donor darah tahunan untuk menunjukkan kepedulian sosial',
          'Membuat sistem evaluasi kinerja pengurus yang transparan, membentuk divisi khusus per bidang, dan membuka kanal pengaduan siswa kepada pengurus',
          'Mengadakan acara hiburan sebanyak-banyaknya agar siswa senang dengan kepemimpinanmu',
          'Memperbanyak kegiatan ekskul militer dan bela diri untuk memperkuat organisasi',
        ],
        correctIndex: 1,
        explanation:
        'Nilai kepemimpinan Umar yang paling menonjol: membangun sistem yang '
            'terstruktur, transparan dalam pengelolaan, selektif dalam penempatan '
            'orang, dan peduli pada kesejahteraan semua pihak. Program seperti '
            'sistem evaluasi transparan, pembagian divisi yang jelas, dan kanal '
            'pengaduan mencerminkan semua nilai tersebut.',
        ibrah:
        'Kepemimpinan sejati bukan soal tampil hebat, tapi soal membangun '
            'sistem yang adil dan berkelanjutan.',
        score: 20,
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════════════════
  //  LEVEL 3 — UTSMAN BIN AFFAN
  // ══════════════════════════════════════════════════════════════════════════
  QuizLevel(
    title: 'Utsman bin Affan',
    subtitle: 'Khalifah Ketiga · 23–36 H',
    videoPath: 'lib/videos/utsman.mp4',
    icon: Icons.auto_stories_rounded,
    color: const Color(0xFF7C3AED),
    timestamps: [20, 55, 90, 125, 160],
    questions: [
      // Soal 11 — C1 (skor 10)
      QuizQuestion(
        question:
        'Inovasi militer terbesar yang pertama kali lahir pada masa '
            'pemerintahan Utsman bin Affan adalah...',
        options: [
          'Pembentukan pasukan kavaleri (berkuda) yang terorganisir',
          'Pembentukan angkatan laut Islam untuk pertama kalinya',
          'Pembentukan pasukan khusus penjaga khalifah (pengawal istana)',
          'Pembentukan sistem intelijen militer untuk memata-matai musuh',
        ],
        correctIndex: 1,
        explanation:
        'Pada masa Utsman bin Affan, untuk pertama kalinya dibentuk angkatan '
            'laut Islam. Ini merupakan inovasi besar karena sebelumnya pada masa '
            'Rasulullah, Abu Bakar, dan Umar, kekuatan militer Islam sepenuhnya '
            'bertumpu pada pasukan darat. Angkatan laut ini atas usulan Mu\'awiyah '
            'bin Abi Sufyan.',
        ibrah:
        'Pemimpin visioner berani berinovasi melampaui batas tradisi '
            'demi kebutuhan zaman yang terus berkembang.',
        score: 10,
      ),

      // Soal 12 — C2 (skor 10)
      QuizQuestion(
        question:
        'Apa yang dimaksud dengan tuduhan "nepotisme" terhadap Utsman bin '
            'Affan, dan mengapa hal ini menjadi pemicu utama ketidakpuasan rakyat?',
        options: [
          'Utsman dituduh menggunakan uang negara untuk keperluan pribadi dan keluarganya',
          'Utsman dianggap cenderung mengutamakan kerabatnya (dari klan Umayyah) dalam penunjukan pejabat penting, sehingga rakyat merasa tidak diperlakukan adil',
          'Utsman menolak bermusyawarah dengan para sahabat senior dalam pengambilan keputusan',
          'Utsman melarang para sahabat Nabi yang bukan kerabatnya untuk tinggal di Madinah',
        ],
        correctIndex: 1,
        explanation:
        'Tuduhan nepotisme terhadap Utsman merujuk pada kecenderungannya mengangkat '
            'anggota klan Umayyah (kerabatnya) pada posisi-posisi kunci pemerintahan. '
            'Rakyat merasa tidak adil karena jabatan tidak diberikan berdasarkan '
            'kompetensi, melainkan kedekatan keluarga.',
        ibrah:
        'Ketidakadilan dalam pengelolaan jabatan, sekecil apapun, dapat '
            'mengguncang kepercayaan rakyat dan meruntuhkan pemerintahan.',
        score: 10,
      ),

      // Soal 13 — C4 (skor 15)
      QuizQuestion(
        question:
        'Kodifikasi Al-Qur\'an (Mushaf Utsmani) yang dilakukan Utsman berbeda '
            'dengan pengumpulan Al-Qur\'an di masa Abu Bakar. '
            'Apa perbedaan mendasar dan signifikansinya?',
        options: [
          'Mushaf Abu Bakar dikumpulkan secara lisan, sedangkan Mushaf Utsmani dikumpulkan secara tertulis untuk pertama kalinya',
          'Pengumpulan di masa Abu Bakar bertujuan menjaga Al-Qur\'an dari hilang akibat gugurnya para huffaz, sedangkan Mushaf Utsmani bertujuan menyeragamkan bacaan agar tidak terjadi perpecahan akibat perbedaan dialek',
          'Mushaf Abu Bakar adalah salinan pertama, sedangkan Mushaf Utsmani adalah terjemahan Al-Qur\'an ke berbagai bahasa',
          'Tidak ada perbedaan — keduanya merupakan proyek yang sama yang dilanjutkan dari Abu Bakar',
        ],
        correctIndex: 1,
        explanation:
        'Di masa Abu Bakar, tujuannya adalah mencegah hilangnya Al-Qur\'an akibat '
            'gugurnya para penghafal. Di masa Utsman, tujuannya berbeda: menyeragamkan '
            'mushaf dan bacaan karena wilayah Islam sudah sangat luas dengan beragam '
            'dialek. Utsman membuat salinan standar (Mushaf Utsmani) yang dikirimkan '
            'ke seluruh provinsi.',
        ibrah:
        'Setiap zaman punya tantangan yang berbeda. Pemimpin yang baik '
            'mampu membaca kebutuhan zamannya dan merespons dengan tepat.',
        score: 15,
      ),

      // Soal 14 — C5 (skor 20)
      QuizQuestion(
        question:
        'Pertempuran Tiang Kapal yang dimenangkan armada laut Islam pada masa '
            'Utsman memiliki dampak strategis yang besar. Evaluasi: mengapa '
            'kemenangan ini penting tidak hanya secara militer, '
            'tetapi juga secara peradaban?',
        options: [
          'Karena membuat Utsman menjadi khalifah terkuat yang pernah ada dalam sejarah Islam',
          'Karena kemenangan atas armada Romawi di laut membuktikan bahwa kekuatan Islam tidak hanya di darat — membuka akses ke wilayah maritim dan memperluas jangkauan peradaban Islam',
          'Karena setelah kemenangan ini, seluruh bangsa Romawi langsung masuk Islam',
          'Karena kemenangan ini mengakhiri semua konflik internal yang sedang terjadi di masa Utsman',
        ],
        correctIndex: 1,
        explanation:
        'Kemenangan Pertempuran Tiang Kapal bermakna lebih dari sekadar militer: '
            'ini membuktikan bahwa Islam mampu berkembang melampaui batas daratan, '
            'membuka jalur maritim baru, dan memungkinkan penyebaran Islam ke wilayah '
            'kepulauan dan kawasan Laut Tengah — sebuah lompatan peradaban besar.',
        ibrah:
        'Berani keluar dari zona nyaman dan mencoba hal baru sering kali '
            'membuka peluang peradaban yang tidak pernah terbayangkan sebelumnya.',
        score: 20,
      ),

      // Soal 15 — C5 (skor 20)
      QuizQuestion(
        question:
        'Meski Utsman memiliki pencapaian besar (Mushaf Utsmani, angkatan laut), '
            'pemerintahannya berakhir tragis akibat krisis kepercayaan. '
            'Pelajaran kepemimpinan apa yang paling kritis dari kisah Utsman?',
        options: [
          'Pemimpin yang berprestasi besar tidak perlu khawatir dengan kritik rakyat',
          'Pencapaian program besar tidak cukup jika tidak diimbangi keadilan dalam tata kelola — krisis kepercayaan akibat nepotisme bisa menghancurkan legasi terbesar sekalipun',
          'Pemimpin sebaiknya tidak terlalu lama menjabat agar tidak terjebak dalam kebiasaan nepotisme',
          'Utsman seharusnya lebih banyak berperang untuk mengalihkan perhatian rakyat dari masalah internal',
        ],
        correctIndex: 1,
        explanation:
        'Kisah Utsman mengajarkan bahwa prestasi dan capaian program tidak '
            'otomatis menjamin legitimasi yang kuat jika dirusak oleh ketidakadilan '
            'dalam tata kelola. Kepercayaan rakyat adalah modal utama kepemimpinan — '
            'sekali runtuh, sulit dibangun kembali meski capaiannya luar biasa.',
        ibrah:
        'Integritas dalam tata kelola adalah fondasi yang tidak bisa '
            'digantikan oleh prestasi apapun — sekali retak, seluruh bangunan bisa roboh.',
        score: 20,
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════════════════
  //  LEVEL 4 — ALI BIN ABI THALIB
  // ══════════════════════════════════════════════════════════════════════════
  QuizLevel(
    title: 'Ali bin Abi Thalib',
    subtitle: 'Khalifah Keempat · 36–41 H',
    videoPath: 'lib/videos/ali.mp4',
    icon: Icons.star_rounded,
    color: const Color(0xFFC2410C),
    timestamps: [20, 55, 90, 125, 160],
    questions: [
      // Soal 16 — C1 (skor 10)
      QuizQuestion(
        question:
        'Ali bin Abi Thalib memindahkan pusat pemerintahan dari Madinah ke '
            'kota mana, dan kota tersebut kemudian berkembang menjadi pusat ilmu apa?',
        options: [
          'Ke Damaskus, yang berkembang menjadi pusat perdagangan Islam',
          'Ke Kuffah, yang berkembang menjadi pusat ilmu tafsir, ilmu hadis, ilmu nahwu, dan ilmu pengetahuan lainnya',
          'Ke Basrah, yang berkembang menjadi pusat angkatan laut Islam',
          'Ke Bagdad, yang berkembang menjadi pusat kebudayaan Islam',
        ],
        correctIndex: 1,
        explanation:
        'Ali bin Abi Thalib memindahkan pusat pemerintahan ke Kuffah — kota yang '
            'awalnya adalah basis pertahanan militer. Di bawah kepemimpinannya, Kuffah '
            'berkembang menjadi pusat ilmu tafsir, ilmu hadis, ilmu nahwu, dan '
            'berbagai ilmu pengetahuan lainnya.',
        ibrah:
        'Sebuah kota atau lingkungan bisa berubah total fungsinya jika ada '
            'pemimpin yang visioner yang mengembangkan potensinya.',
        score: 10,
      ),

      // Soal 17 — C2 (skor 10)
      QuizQuestion(
        question:
        'Perang Jamal dan Perang Shiffin yang terjadi pada masa Ali bin Abi '
            'Thalib keduanya bersumber dari masalah yang sama. '
            'Apa akar masalah utamanya?',
        options: [
          'Perebutan harta rampasan perang antara para sahabat senior',
          'Persoalan legitimasi politik pasca-terbunuhnya Utsman — berbagai kelompok mempersoalkan cara Ali naik dan kebijakannya',
          'Perbedaan mazhab fikih antara para sahabat tentang hukum Islam',
          'Ambisi Ali untuk menaklukkan wilayah Persia dan Romawi lebih luas',
        ],
        correctIndex: 1,
        explanation:
        'Perang Jamal (melawan Thalhah dan Zubair) dan Perang Shiffin (melawan '
            'Mu\'awiyah) keduanya berakar dari persoalan legitimasi politik '
            'pasca-terbunuhnya Utsman. Pertanyaan tentang siapa yang berhak berkuasa '
            'dan bagaimana cara Ali merespons pembunuhan Utsman menjadi titik api konflik.',
        ibrah:
        'Konflik yang tidak diselesaikan dari akar permasalahannya akan terus '
            'memunculkan krisis baru — penyelesaian tuntas lebih baik dari solusi sementara.',
        score: 10,
      ),

      // Soal 18 — C4 (skor 15)
      QuizQuestion(
        question:
        'Ali bin Abi Thalib memerintahkan pengembangan ilmu nahwu (tata bahasa '
            'Arab) melalui Abu Aswad ad-Duali. Analisis: mengapa kebijakan ini '
            'berdampak jauh melampaui zamannya?',
        options: [
          'Karena ilmu nahwu memudahkan orang Arab untuk berdagang di seluruh dunia',
          'Karena standardisasi tata bahasa Arab menjadi fondasi bagi jutaan non-Arab untuk membaca Al-Qur\'an dengan benar, menjaga keshahihan wahyu lintas generasi',
          'Karena ilmu nahwu membuat bahasa Arab menggantikan bahasa Persia dan Romawi di seluruh wilayah Islam',
          'Karena tanpa ilmu nahwu, Al-Qur\'an tidak bisa diterjemahkan ke bahasa lain',
        ],
        correctIndex: 1,
        explanation:
        'Saat itu huruf hijaiyah belum dilengkapi harakat, sehingga non-Arab sangat '
            'rentan salah membaca Al-Qur\'an. Dengan memerintahkan pengembangan ilmu '
            'nahwu, Ali meletakkan fondasi gramatika Arab yang kelak memungkinkan '
            'ratusan juta non-Arab membaca Al-Qur\'an dengan benar. '
            'Dampaknya terasa hingga hari ini.',
        ibrah:
        'Investasi pada ilmu dan pendidikan adalah warisan terpanjang yang bisa '
            'ditinggalkan seorang pemimpin — dampaknya terasa lintas generasi.',
        score: 15,
      ),

      // Soal 19 — C4 (skor 15)
      QuizQuestion(
        question:
        'Reformasi agraria Ali — menarik kembali tanah yang dibagi Utsman '
            'kepada kerabatnya — disambut positif sekaligus memperparah konflik '
            'dengan kelompok tertentu. Apa dilema kepemimpinan yang tergambar?',
        options: [
          'Pemimpin yang adil selalu dicintai semua pihak tanpa terkecuali',
          'Kebijakan yang adil secara prinsip bisa tetap memicu resistensi dari pihak yang dirugikan — keberanian menegakkan keadilan sering kali datang dengan harga yang harus dibayar',
          'Ali seharusnya tidak menarik kebijakan Utsman agar konflik tidak melebar',
          'Reformasi hanya boleh dilakukan dalam situasi damai, bukan di tengah konflik',
        ],
        correctIndex: 1,
        explanation:
        'Kebijakan agraria Ali adalah keputusan yang tepat secara prinsip keadilan, '
            'namun langsung menimbulkan resistensi dari pihak yang merasa dirugikan. '
            'Ini menggambarkan dilema klasik kepemimpinan: melakukan hal yang benar '
            'tidak selalu disukai semua pihak — kepemimpinan membutuhkan keberanian moral.',
        ibrah:
        'Keberanian menegakkan keadilan, meski tidak populer dan penuh risiko, '
            'adalah tanda kepemimpinan yang sesungguhnya.',
        score: 15,
      ),

      // Soal 20 — C6 (skor 20)
      QuizQuestion(
        question:
        'Ali bin Abi Thalib memimpin di tengah krisis bertubi-tubi namun tetap '
            'mewariskan reformasi ilmu dan keadilan. Rancang sebuah prinsip '
            'kepemimpinan personal yang bisa kamu terapkan sebagai pelajar, '
            'terinspirasi dari kepemimpinan Ali!',
        options: [
          'Menghindari semua konflik dan kontroversi agar hidup lebih tenang dan tidak ada masalah',
          'Tetap berkomitmen pada nilai keadilan dan pengembangan ilmu meski dalam tekanan — bersikap adil dalam kelompok, berani menegur yang salah, dan terus belajar meski situasi sulit',
          'Memimpin hanya ketika situasi sudah aman dan kondusif agar keputusan bisa diambil dengan tenang',
          'Mengikuti pendapat mayoritas teman agar tidak terjadi konflik dalam kelompok belajar',
        ],
        correctIndex: 1,
        explanation:
        'Kepemimpinan Ali paling kuat tercermin dalam dua hal: komitmen pada '
            'keadilan (meski menimbulkan resistensi) dan investasi pada ilmu di tengah '
            'gejolak konflik. Sebagai pelajar, ini bisa diwujudkan dengan tetap jujur '
            'dalam kelompok, berani menegur kecurangan, dan tidak berhenti belajar '
            'meski situasi sulit.',
        ibrah:
        'Nilai sejati seseorang bukan diukur saat situasi mudah, melainkan '
            'saat ia tetap memegang prinsipnya di tengah tekanan dan kesulitan.',
        score: 20,
      ),
    ],
  ),
];

// ════════════════════════════════════════════════════════════════════════════
//  QuizPage — Level Selection Screen
// ════════════════════════════════════════════════════════════════════════════
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // Track score + completion per level
  final Map<int, int> _scores     = {};
  final Map<int, bool> _completed = {};

  int get _totalScore => _scores.values.fold(0, (a, b) => a + b);
  int get _doneCount  => _completed.values.where((v) => v).length;

  // ── navigate to level ────────────────────────────────────────────────────
  Future<void> _startLevel(int idx) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) =>
            _QuizLevelPage(level: quizLevels[idx], levelIndex: idx),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _scores[idx]     = result['score'] as int;
        _completed[idx]  = true;
      });
    }
  }

  // ── build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _sliverHeader(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _totalScoreCard(),
                const SizedBox(height: 22),
                _sectionTitle('Pilih Level Kuis'),
                const SizedBox(height: 12),
                for (var i = 0; i < quizLevels.length; i++)
                  _levelCard(i, quizLevels[i]),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sliver header ────────────────────────────────────────────────────────
  Widget _sliverHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: _C.emeraldDeep,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(fit: StackFit.expand, children: [
          // gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A7A4A), _C.emerald, Color(0xFF52D98A)],
              ),
            ),
          ),
          // decorative circles
          Positioned(top: -60, right: -60,
              child: _oval(240, Colors.white.withOpacity(0.04))),
          Positioned(bottom: -40, left: -40,
              child: _oval(180, Colors.white.withOpacity(0.04))),
          Positioned(top: 60, left: 90,
              child: _oval(80, _C.gold.withOpacity(0.09))),
          // content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _iconBox(Icons.quiz_rounded, _C.gold),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SKIVENTURE',
                            style: TextStyle(
                                color: Color(0xFFFDE68A),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.5)),
                        Text('Kuis Interaktif',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                height: 1.1)),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 10),
                  const Text(
                    'Tonton video · Jawab soal · Raih skor tertinggi!',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ),
        ]),
        title: const Text('Kuis Interaktif',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 18),
        onPressed: () => Navigator.maybePop(context),
      ),
    );
  }

  // ── Total score card ─────────────────────────────────────────────────────
  Widget _totalScoreCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [_C.emeraldDeep, _C.emerald]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: _C.emerald.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(children: [
        // circular score
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Center(
            child: Text('$_totalScore',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Total Skor',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text('$_doneCount dari ${quizLevels.length} level selesai',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
        // badge
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _C.gold,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _doneCount == quizLevels.length
                ? 'Selesai!'
                : '$_doneCount/${quizLevels.length}',
            style: const TextStyle(
                color: Color(0xFF5A4000),
                fontSize: 12,
                fontWeight: FontWeight.w800),
          ),
        ),
      ]),
    );
  }

  // ── Level card ───────────────────────────────────────────────────────────
  Widget _levelCard(int idx, QuizLevel level) {
    final done = _completed[idx] == true;
    final score = _scores[idx] ?? 0;
    final maxScore = level.maxScore;

    return GestureDetector(
      onTap: () => _startLevel(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(20),
          border: done
              ? Border.all(color: level.color.withOpacity(0.4), width: 1.5)
              : null,
          boxShadow: const [
            BoxShadow(color: _C.shadow, blurRadius: 14, offset: Offset(0, 5)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(children: [
            // gradient header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [level.color, level.color.withOpacity(0.68)]),
              ),
              child: Row(children: [
                _iconBox(level.icon, Colors.white, size: 22, boxSize: 46),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Level ${idx + 1} — ${level.subtitle}',
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(level.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800)),
                      ]),
                ),
                if (done)
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 16),
                  ),
              ]),
            ),
            // info row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(children: [
                _chip(Icons.help_outline_rounded,
                    '${level.questions.length} Soal', level.color),
                const SizedBox(width: 8),
                _chip(Icons.timer_outlined, '30 dtk', level.color),
                const SizedBox(width: 8),
                _chip(
                  Icons.star_outline_rounded,
                  done ? '$score/$maxScore' : 'Maks $maxScore',
                  done ? _C.emerald : level.color,
                ),
                const Spacer(),
                // CTA button
                _ctaButton(done ? 'Ulangi' : 'Mulai',
                    done ? Icons.replay_rounded : Icons.play_arrow_rounded,
                    level.color),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────────
  Widget _oval(double s, Color c) => Container(
      width: s,
      height: s,
      decoration: BoxDecoration(shape: BoxShape.circle, color: c));

  Widget _iconBox(IconData icon, Color iconColor,
      {double size = 24, double boxSize = 48}) {
    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.35)),
      ),
      child: Icon(icon, color: iconColor, size: size),
    );
  }

  Widget _chip(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 4),
      Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _ctaButton(String label, IconData icon, Color color) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: Colors.white, size: 16),
      const SizedBox(width: 4),
      Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700)),
    ]),
  );

  Widget _sectionTitle(String text) => Row(children: [
    Container(
        width: 4,
        height: 20,
        decoration: BoxDecoration(
            color: _C.emerald, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(text,
        style: const TextStyle(
            color: _C.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 16)),
  ]);
}

// ════════════════════════════════════════════════════════════════════════════
//  _QuizLevelPage — Video + Soal Overlay
// ════════════════════════════════════════════════════════════════════════════
class _QuizLevelPage extends StatefulWidget {
  final QuizLevel level;
  final int levelIndex;

  const _QuizLevelPage({required this.level, required this.levelIndex});

  @override
  State<_QuizLevelPage> createState() => _QuizLevelPageState();
}

class _QuizLevelPageState extends State<_QuizLevelPage>
    with TickerProviderStateMixin {

  // ── video ─────────────────────────────────────────────────────────────────
  late VideoPlayerController _vc;
  bool _videoReady = false;

  // ── quiz state ────────────────────────────────────────────────────────────
  int  _score              = 0;
  int  _qIdx               = 0;   // current question index
  int  _tsIdx              = 0;   // current timestamp index
  bool _isQuestionActive   = false;
  bool _quizDone           = false;

  // ── answer state ──────────────────────────────────────────────────────────
  int? _selectedOption;
  bool _answered           = false;

  // ── timer ─────────────────────────────────────────────────────────────────
  static const int _totalTime = 30;
  int  _timeLeft           = _totalTime;
  Timer? _countdownTimer;

  // ── animations ────────────────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  // ── init ──────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // Animations
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
        begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    _initVideo();
  }

  Future<void> _initVideo() async {
    _vc = VideoPlayerController.asset(widget.level.videoPath);
    try {
      await _vc.initialize();
      if (!mounted) return;
      _vc.addListener(_onVideoTick);
      setState(() => _videoReady = true);
      _vc.play();
    } catch (_) {
      // Video file missing — demo mode (quiz triggers via manual button)
      if (mounted) setState(() => _videoReady = false);
    }
  }

  // ── video position listener ───────────────────────────────────────────────
  void _onVideoTick() {
    if (!mounted)           return;
    if (_isQuestionActive)  return;   // ← prevents double trigger
    if (_tsIdx >= widget.level.timestamps.length) return;

    final pos    = _vc.value.position.inSeconds;
    final target = widget.level.timestamps[_tsIdx];

    if (pos >= target) _showQuestion();
  }

  // ── show question ─────────────────────────────────────────────────────────
  void _showQuestion() {
    if (_isQuestionActive) return;
    _vc.pause();
    setState(() {
      _isQuestionActive = true;
      _selectedOption   = null;
      _answered         = false;
      _timeLeft         = _totalTime;
    });
    _fadeCtrl.forward(from: 0);
    _slideCtrl.forward(from: 0);
    _startCountdown();
  }

  // ── countdown timer ───────────────────────────────────────────────────────
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        t.cancel();
        _handleAnswer(-1);   // timeout → treated as wrong
      }
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  // ── handle answer ─────────────────────────────────────────────────────────
  void _handleAnswer(int selected) {
    if (_answered) return;
    _stopCountdown();

    final q         = widget.level.questions[_qIdx];
    final isCorrect = selected == q.correctIndex;
    final bonus     = (isCorrect && _timeLeft > 15) ? 5 : 0;
    final gained    = isCorrect ? q.score + bonus : 0;

    setState(() {
      _selectedOption = selected;
      _answered       = true;
      _score         += gained;
    });

    // Auto-advance after 3 s
    Future.delayed(const Duration(seconds: 3), _advanceQuiz);
  }

  // ── advance to next question or finish ───────────────────────────────────
  void _advanceQuiz() {
    if (!mounted) return;
    final nextQ  = _qIdx + 1;
    final nextTs = _tsIdx + 1;

    if (nextQ >= widget.level.questions.length) {
      // All questions done
      _fadeCtrl.reverse();
      setState(() {
        _isQuestionActive = false;
        _quizDone         = true;
      });
      Future.delayed(const Duration(milliseconds: 400), _showResult);
      return;
    }

    _fadeCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _qIdx             = nextQ;
        _tsIdx            = nextTs;
        _isQuestionActive = false;
        _answered         = false;
        _selectedOption   = null;
      });
      _vc.play();
    });
  }

  // ── result dialog ─────────────────────────────────────────────────────────
  void _showResult() {
    if (!mounted) return;
    final max  = widget.level.maxScore;
    final pct  = (_score / max * 100).clamp(0, 100).round();

    final (String label, Color colour) = pct >= 85
        ? ('Luar Biasa!', _C.emerald)
        : pct >= 70
        ? ('Bagus Sekali!', _C.emeraldDark)
        : pct >= 55
        ? ('Cukup Baik', _C.gold)
        : ('Tetap Semangat!', _C.textMid);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // trophy icon
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colour.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.emoji_events_rounded, size: 48, color: colour),
            ),
            const SizedBox(height: 14),
            Text(label,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900, color: colour)),
            const SizedBox(height: 4),
            Text(widget.level.title,
                style: const TextStyle(
                    color: _C.textMid, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            // stat row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _stat('Skor', '$_score', colour),
                    _vDivider(),
                    _stat('Maks', '$max', _C.textLight),
                    _vDivider(),
                    _stat('Nilai', '$pct%', colour),
                  ]),
            ),
            const SizedBox(height: 22),
            Row(children: [
              // Back
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);        // close dialog
                    Navigator.pop(context);        // go back (no score saved)
                  },
                  icon: const Icon(Icons.home_rounded, size: 16),
                  label: const Text('Kembali'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _C.textMid,
                    side: BorderSide(color: _C.textLight.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Save
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);        // close dialog
                    Navigator.pop(context,         // return score to QuizPage
                        {'score': _score, 'levelIndex': widget.levelIndex});
                  },
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Simpan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.emerald,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Column(children: [
    Text(value,
        style: TextStyle(
            color: color, fontSize: 22, fontWeight: FontWeight.w900)),
    const SizedBox(height: 2),
    Text(label,
        style: const TextStyle(color: _C.textLight, fontSize: 12)),
  ]);

  Widget _vDivider() =>
      Container(width: 1, height: 40, color: _C.optionBg);

  // ── dispose ───────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _stopCountdown();
    _vc.removeListener(_onVideoTick);
    _vc.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    // Lock portrait
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return Scaffold(
      backgroundColor: _C.dark,
      body: SafeArea(
        child: Column(children: [
          _topBar(),
          Expanded(
            child: Stack(children: [
              // ── video + progress ──
              Column(children: [
                _videoPlayer(),
                _progressStrip(),
                if (!_videoReady && !_isQuestionActive) _demoTrigger(),
              ]),
              // ── question overlay ──
              if (_isQuestionActive)
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: _questionOverlay(),
                  ),
                ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _topBar() => Container(
    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
    decoration: BoxDecoration(
      color: _C.dark,
      border:
      Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
    ),
    child: Row(children: [
      IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white70, size: 18),
        onPressed: () => Navigator.maybePop(context),
      ),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.level.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          Text(widget.level.subtitle,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 11)),
        ]),
      ),
      // live score
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _C.gold.withOpacity(0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.gold.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.star_rounded, size: 14, color: _C.gold),
          const SizedBox(width: 5),
          Text('$_score pts',
              style: const TextStyle(
                  color: _C.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    ]),
  );

  // ── Video player ──────────────────────────────────────────────────────────
  Widget _videoPlayer() => Container(
    margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      color: const Color(0xFF1A2530),
      boxShadow: [
        BoxShadow(
            color: widget.level.color.withOpacity(0.3),
            blurRadius: 22,
            offset: const Offset(0, 6)),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: _videoReady
            ? VideoPlayer(_vc)
            : _videoPlaceholder(),
      ),
    ),
  );

  Widget _videoPlaceholder() => Container(
    color: const Color(0xFF1A2530),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(widget.level.icon, size: 52, color: widget.level.color),
      const SizedBox(height: 10),
      Text(widget.level.title,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      const Text('Video akan diputar di sini',
          style: TextStyle(color: Colors.white38, fontSize: 11)),
    ]),
  );

  // ── Progress strip ────────────────────────────────────────────────────────
  Widget _progressStrip() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
    child: Row(children: [
      // animated dots
      Row(
        children: List.generate(widget.level.questions.length, (i) {
          final Color c = i < _qIdx
              ? _C.emerald
              : i == _qIdx
              ? _C.gold
              : Colors.white24;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 6),
            width: i == _qIdx ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
                color: c, borderRadius: BorderRadius.circular(4)),
          );
        }),
      ),
      const Spacer(),
      Text(
        'Soal ${_qIdx + 1}/${widget.level.questions.length}',
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
    ]),
  );

  // ── Demo trigger (when video file is missing) ─────────────────────────────
  Widget _demoTrigger() => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: GestureDetector(
      onTap: _showQuestion,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: widget.level.color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: widget.level.color.withOpacity(0.35)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.touch_app_rounded,
              color: widget.level.color, size: 18),
          const SizedBox(width: 8),
          Text('Tap untuk mulai soal (mode demo)',
              style: TextStyle(
                  color: widget.level.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    ),
  );

  // ── Question overlay ──────────────────────────────────────────────────────
  Widget _questionOverlay() {
    if (_qIdx >= widget.level.questions.length) return const SizedBox.shrink();
    final q = widget.level.questions[_qIdx];

    return Positioned.fill(
      child: Column(children: [
        // semi-transparent top fade
        Expanded(
          child: GestureDetector(
            onTap: () {}, // absorb taps so user can't dismiss by tapping top
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
        ),
        // question card
        Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: widget.level.color.withOpacity(0.28),
                  blurRadius: 28,
                  offset: const Offset(0, -4)),
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _qHeader(q),
            _qBody(q),
            if (_answered) _explanationCard(q),
            const SizedBox(height: 10),
          ]),
        ),
      ]),
    );
  }

  // ── Question header (level badge + timer) ────────────────────────────────
  Widget _qHeader(QuizQuestion q) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
          colors: [widget.level.color, widget.level.color.withOpacity(0.65)]),
      borderRadius:
      const BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10)),
        child: Text('Soal ${_qIdx + 1} / ${widget.level.questions.length}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ),
      const Spacer(),
      _timerWidget(),
    ]),
  );

  // ── Circular countdown timer ──────────────────────────────────────────────
  Widget _timerWidget() {
    final pct   = _timeLeft / _totalTime;
    final color = _timeLeft > 15
        ? _C.emerald
        : _timeLeft > 8
        ? _C.gold
        : _C.wrong;

    return Row(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: 38,
        height: 38,
        child: Stack(alignment: Alignment.center, children: [
          CircularProgressIndicator(
            value: pct,
            strokeWidth: 3.5,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Text('$_timeLeft',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800)),
        ]),
      ),
      const SizedBox(width: 6),
      const Icon(Icons.timer_rounded, color: Colors.white70, size: 15),
    ]);
  }

  // ── Question text ─────────────────────────────────────────────────────────
  Widget _qBody(QuizQuestion q) => Column(children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Text(q.question,
          style: const TextStyle(
              color: _C.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.55)),
    ),
    Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Column(
        children: q.options.asMap().entries
            .map((e) => _optionButton(e.key, e.value, q))
            .toList(),
      ),
    ),
  ]);

  // ── Option button ─────────────────────────────────────────────────────────
  static const _labels = ['A', 'B', 'C', 'D'];

  Widget _optionButton(int idx, String text, QuizQuestion q) {
    // Determine colours
    Color bg     = _C.optionBg;
    Color tc     = _C.textDark;
    Color border = Colors.transparent;
    Widget? icon;

    if (_answered) {
      if (idx == q.correctIndex) {
        bg     = _C.correct.withOpacity(0.11);
        tc     = _C.correct;
        border = _C.correct;
        icon   = const Icon(Icons.check_circle_rounded,
            color: _C.correct, size: 18);
      } else if (idx == _selectedOption) {
        bg     = _C.wrong.withOpacity(0.10);
        tc     = _C.wrong;
        border = _C.wrong;
        icon   = const Icon(Icons.cancel_rounded, color: _C.wrong, size: 18);
      }
    }

    return GestureDetector(
      onTap: _answered ? null : () => _handleAnswer(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: border, width: 1.5),
          boxShadow: const [
            BoxShadow(color: _C.shadow, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Row(children: [
          // label badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _answered && (idx == q.correctIndex || idx == _selectedOption)
                  ? (idx == q.correctIndex ? _C.correct : _C.wrong)
                  : widget.level.color.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(_labels[idx],
                  style: TextStyle(
                      color: _answered &&
                          (idx == q.correctIndex || idx == _selectedOption)
                          ? Colors.white
                          : widget.level.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: tc,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4)),
          ),
          if (icon != null) ...[const SizedBox(width: 8), icon],
        ]),
      ),
    );
  }

  // ── Explanation card ──────────────────────────────────────────────────────
  Widget _explanationCard(QuizQuestion q) {
    final correct = _selectedOption == q.correctIndex;
    final bonus   = correct && _timeLeft > 15;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: correct
            ? _C.correct.withOpacity(0.07)
            : _C.wrong.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: correct
                ? _C.correct.withOpacity(0.28)
                : _C.wrong.withOpacity(0.28)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // status row
        Row(children: [
          Icon(
            correct ? Icons.check_circle_rounded : Icons.info_rounded,
            size: 15,
            color: correct ? _C.correct : _C.wrong,
          ),
          const SizedBox(width: 6),
          Text(
            correct
                ? 'Benar! +${q.score} poin'
                : 'Jawaban salah',
            style: TextStyle(
                color: correct ? _C.correct : _C.wrong,
                fontWeight: FontWeight.w700,
                fontSize: 13),
          ),
          if (bonus) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _C.gold.withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('+5 Bonus Cepat!',
                  style: TextStyle(
                      color: _C.goldDark,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
        const SizedBox(height: 8),
        // explanation
        Text(q.explanation,
            style: const TextStyle(
                color: _C.textMid, fontSize: 12, height: 1.5)),
        const SizedBox(height: 8),
        // ibrah
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _C.gold.withOpacity(0.09),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.gold.withOpacity(0.28)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.lightbulb_rounded,
                size: 14, color: _C.goldDark),
            const SizedBox(width: 7),
            Expanded(
              child: Text(q.ibrah,
                  style: const TextStyle(
                      color: _C.textMid,
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      height: 1.45)),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SETUP NOTES
// ════════════════════════════════════════════════════════════════════════════
//
//  pubspec.yaml:
//  ─────────────
//  dependencies:
//    video_player: ^2.8.3
//
//  flutter:
//    assets:
//      - lib/videos/abu_bakar.mp4
//      - lib/videos/umar.mp4
//      - lib/videos/utsman.mp4
//      - lib/videos/ali.mp4
//
//  AndroidManifest.xml:
//  ─────────────────────
//  <uses-permission android:name="android.permission.INTERNET"/>
//
//  Usage:
//  ───────
//  Navigator.push(context,
//    MaterialPageRoute(builder: (_) => const QuizPage()));
//
//  Scoring:
//  ─────────
//  C1–C2 → +10 pts   C4–C5 → +15–20 pts   C6 → +20 pts
//  Bonus +5 jika menjawab benar dalam < 15 detik
//
// ════════════════════════════════════════════════════════════════════════════