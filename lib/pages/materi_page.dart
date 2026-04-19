import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'quiz_page.dart';
import '../session.dart';

// =========================
// DUOLINGO COLOR TOKENS
// =========================
class DuoColors {
  static const green       = Color(0xFF58CC02);
  static const greenDark   = Color(0xFF46A302);
  static const greenLight  = Color(0xFFD7F5B1);
  static const blue        = Color(0xFF1CB0F6);
  static const blueLight   = Color(0xFFDDF4FF);
  static const yellow      = Color(0xFFFFD900);
  static const yellowLight = Color(0xFFFFF9C4);
  static const orange      = Color(0xFFFF9600);
  static const orangeDark  = Color(0xFFCC7700);
  static const orangeLight = Color(0xFFFFECCC);
  static const purple      = Color(0xFFCE82FF);
  static const purpleLight = Color(0xFFF4DDFF);
  static const red         = Color(0xFFFF4B4B);
  static const redLight    = Color(0xFFFFDDDD);
  static const ink         = Color(0xFF1F1F1F);
  static const inkLight    = Color(0xFF777777);
  static const snow        = Color(0xFFFFFFFF);
  static const polar       = Color(0xFFF7F7F7);
  static const borderGray  = Color(0xFFE5E5E5);
}

// keep for backward compat
class AppColors {
  static const Color primary = Color(0xFF58CC02);
  static const Color cream   = Color(0xFFF7F7F7);
}

// materi metadata
const _materiMeta = {
  'Abu Bakar': (emoji: '1️⃣', color: DuoColors.blue,   bg: DuoColors.blueLight),
  'Umar':      (emoji: '2️⃣', color: DuoColors.orange, bg: DuoColors.orangeLight),
  'Utsman':    (emoji: '3️⃣', color: DuoColors.purple, bg: DuoColors.purpleLight),
  'Ali':       (emoji: '4️⃣', color: DuoColors.green,  bg: DuoColors.greenLight),
};

class MateriPage extends StatefulWidget {
  const MateriPage({super.key});

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  late YoutubePlayerController controller;

  String currentVideoId = "Y8flRf3LQhY";
  String currentMateri  = "Abu Bakar";

  @override
  void initState() {
    super.initState();
    controller = YoutubePlayerController(
      initialVideoId: currentVideoId,
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
  }

  void changeVideo(String videoId, String materi) {
    controller.load(videoId);
    setState(() {
      currentMateri = materi;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String mapMateri(String title) {
    switch (title) {
      case "Umar (1)":
      case "Umar (2)":
        return "Umar";
      default:
        return title;
    }
  }

  // ─────────────────────────────────────────
  // MATERI BUTTON
  // ─────────────────────────────────────────
  Widget materiButton(String title, String videoId) {
    final mapped    = mapMateri(title);
    final meta      = _materiMeta[mapped];
    final isActive  = currentMateri == mapped;
    final color     = meta?.color ?? DuoColors.green;
    final bgColor   = meta?.bg    ?? DuoColors.greenLight;
    final emoji     = meta?.emoji ?? '📖';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: _DuoPressable(
        onTap: () => changeVideo(videoId, mapped),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: isActive ? bgColor : DuoColors.snow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? color : DuoColors.borderGray,
              width: isActive ? 2.5 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? color.withOpacity(0.2)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isActive ? color : DuoColors.ink,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              if (isActive)
                Icon(Icons.play_circle_filled_rounded,
                    color: color, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // START QUIZ BUTTON
  // ─────────────────────────────────────────
  Widget startQuizButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: _DuoPressable(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizPage(
                materiId:  currentMateri,
                studentId: Session.studentId ?? "",
                teacherId: Session.teacherId ?? "",
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: DuoColors.orange,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: DuoColors.orangeDark, width: 2),
            boxShadow: const [
              BoxShadow(
                color: DuoColors.orangeDark,
                blurRadius: 0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('⚡', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text(
                  'Mulai Quiz',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // EXPANDABLE MATERI
  // ─────────────────────────────────────────
  Widget expandableMateri(String title, String content) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: DuoColors.snow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DuoColors.borderGray, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
          const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: DuoColors.green,
          collapsedIconColor: DuoColors.inkLight,
          leading: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: DuoColors.greenLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: DuoColors.green,
              size: 18,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: DuoColors.ink,
              fontFamily: 'Nunito',
              letterSpacing: -0.2,
            ),
          ),
          children: [
            const Divider(color: DuoColors.borderGray, height: 1),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: DuoColors.ink,
                fontFamily: 'Nunito',
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final meta = _materiMeta[currentMateri];

    return Scaffold(
      backgroundColor: DuoColors.polar,

      // ── APP BAR ──────────────────────────
      appBar: AppBar(
        elevation: 0,
        backgroundColor: DuoColors.snow,
        foregroundColor: DuoColors.ink,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: const Text(
          'Materi',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: DuoColors.ink,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: DuoColors.borderGray),
        ),
      ),

      body: Column(
        children: [

          // ── VIDEO PLAYER ─────────────────
          Container(
            color: DuoColors.snow,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: DuoColors.borderGray, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: YoutubePlayer(controller: controller),
                  ),
                ),

                // Now playing pill
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: meta?.bg ?? DuoColors.greenLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (meta?.color ?? DuoColors.green)
                                .withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(meta?.emoji ?? '📖',
                                style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 5),
                            Text(
                              currentMateri,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: meta?.color ?? DuoColors.green,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.play_circle_outline_rounded,
                          size: 16, color: DuoColors.inkLight),
                      const SizedBox(width: 4),
                      const Text(
                        'Sedang diputar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DuoColors.inkLight,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── SCROLLABLE CONTENT ───────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Section: Pilih Materi
                  _sectionLabel('🎬  Pilih Materi'),
                  const SizedBox(height: 8),

                  materiButton("Abu Bakar", "Y8flRf3LQhY"),
                  materiButton("Umar (1)",  "EuQTKmhAZ5g"),
                  materiButton("Umar (2)",  "x1WNxM8bDls"),
                  materiButton("Utsman",    "FP5s6qFwHS0"),
                  materiButton("Ali",       "tvRVgwQ82oo"),

                  // Quiz button
                  startQuizButton(),

                  // Section: Ringkasan Materi
                  _sectionLabel('📚  Ringkasan Materi'),
                  const SizedBox(height: 8),

                  expandableMateri(
                    "Pengertian Khulafaur Rasyidin",
                    "Istilah Khulafaur Rasyidin berasal dari dua kata, yaitu 'Khulafa' yang berarti "
                        "pengganti dan 'Ar-Rasyidun' yang berarti orang-orang yang mendapat petunjuk.\n\n"
                        "Dengan demikian, Khulafaur Rasyidin adalah para pemimpin umat Islam setelah wafatnya "
                        "Rasulullah SAW yang menjalankan pemerintahan berdasarkan petunjuk Allah SWT "
                        "dan ajaran Rasulullah.\n\n"
                        "Mereka dikenal sebagai pemimpin yang adil, bijaksana, dan mengutamakan kepentingan umat.\n\n"
                        "Khulafaur Rasyidin terdiri dari empat sahabat utama Rasulullah, yaitu:\n"
                        "- Abu Bakar Ash-Shiddiq\n"
                        "- Umar bin Khattab\n"
                        "- Utsman bin Affan\n"
                        "- Ali bin Abi Thalib\n\n"
                        "Masa kepemimpinan mereka disebut sebagai masa terbaik dalam sejarah pemerintahan Islam "
                        "karena dijalankan dengan penuh keadilan dan tanggung jawab.",
                  ),
                  expandableMateri(
                    "Abu Bakar Ash-Shiddiq",
                    "Abu Bakar Ash-Shiddiq memiliki nama asli Abdullah bin Abi Quhafa. Ia merupakan sahabat "
                        "terdekat Rasulullah SAW dan orang pertama yang masuk Islam dari kalangan laki-laki dewasa.\n\n"
                        "Beliau diberi gelar 'As-Shiddiq' yang berarti orang yang sangat membenarkan, karena selalu "
                        "membenarkan setiap perkataan Rasulullah tanpa ragu.\n\n"
                        "Setelah wafatnya Rasulullah SAW, Abu Bakar diangkat menjadi khalifah pertama.\n\n"
                        "Selama masa kepemimpinannya, Abu Bakar menghadapi berbagai tantangan besar, terutama "
                        "munculnya kaum murtad dan nabi-nabi palsu.\n\n"
                        "📌 Bidang Agama:\n"
                        "- Memerangi orang-orang yang murtad\n"
                        "- Menumpas nabi palsu\n"
                        "- Mengumpulkan ayat-ayat Al-Qur'an menjadi satu mushaf\n\n"
                        "📌 Bidang Politik:\n"
                        "- Menyatukan kembali umat Islam\n"
                        "- Mengangkat para gubernur\n\n"
                        "📌 Bidang Militer:\n"
                        "- Mengirim pasukan ke wilayah Syam\n"
                        "- Melanjutkan ekspedisi yang direncanakan Rasulullah\n\n"
                        "Abu Bakar dikenal sebagai pemimpin yang tegas dalam menjaga keimanan umat, "
                        "namun tetap rendah hati dan mengutamakan musyawarah.",
                  ),
                  expandableMateri(
                    "Umar bin Khattab",
                    "Umar bin Khattab adalah khalifah kedua setelah Abu Bakar. Ia dikenal sebagai pemimpin "
                        "yang sangat tegas, adil, dan berani.\n\n"
                        "Beliau mendapat gelar 'Al-Faruq' yang berarti pembeda antara yang benar dan yang salah.\n\n"
                        "Pada masa kepemimpinannya, wilayah Islam berkembang sangat pesat hingga mencakup "
                        "wilayah Persia dan Romawi.\n\n"
                        "📌 Bidang Pemerintahan:\n"
                        "- Membagi wilayah menjadi beberapa provinsi\n"
                        "- Membentuk sistem administrasi negara\n\n"
                        "📌 Bidang Agama:\n"
                        "- Menetapkan kalender Hijriah\n\n"
                        "📌 Bidang Sosial:\n"
                        "- Memberikan perlindungan kepada non-Muslim\n"
                        "- Memperhatikan kesejahteraan rakyat\n\n"
                        "📌 Bidang Hukum:\n"
                        "- Menyusun sistem peradilan yang teratur\n\n"
                        "Umar bin Khattab dikenal sebagai pemimpin yang tidak segan menghukum dirinya sendiri "
                        "jika melakukan kesalahan, serta sangat peduli terhadap rakyatnya.",
                  ),
                  expandableMateri(
                    "Utsman bin Affan",
                    "Utsman bin Affan adalah khalifah ketiga dan dikenal sebagai sosok yang sangat dermawan.\n\n"
                        "Beliau mendapat gelar 'Dzunnurain' yang berarti pemilik dua cahaya karena menikahi dua putri Rasulullah.\n\n"
                        "📌 Bidang Agama:\n"
                        "- Membukukan Al-Qur'an menjadi satu mushaf standar (Mushaf Utsmani)\n\n"
                        "📌 Bidang Politik:\n"
                        "- Mengembangkan sistem pemerintahan\n"
                        "- Menggunakan musyawarah dalam pengambilan keputusan\n\n"
                        "📌 Bidang Militer:\n"
                        "- Membentuk angkatan laut pertama dalam Islam\n"
                        "- Melakukan ekspansi wilayah\n\n"
                        "Namun, pada akhir masa kepemimpinannya, muncul berbagai konflik dan pemberontakan "
                        "yang akhirnya menyebabkan wafatnya beliau.\n\n"
                        "Meskipun demikian, Utsman tetap dikenal sebagai pemimpin yang sabar, lembut, dan dermawan.",
                  ),
                  expandableMateri(
                    "Ali bin Abi Thalib",
                    "Ali bin Abi Thalib adalah khalifah keempat sekaligus sepupu dan menantu Rasulullah SAW.\n\n"
                        "Beliau dikenal sebagai sosok yang sangat cerdas, berani, dan memiliki ilmu yang luas.\n\n"
                        "📌 Bidang Pemerintahan:\n"
                        "- Melakukan reformasi pejabat pemerintahan\n"
                        "- Memindahkan pusat pemerintahan ke Kufah\n\n"
                        "📌 Bidang Ekonomi:\n"
                        "- Mengembalikan harta negara ke baitul mal\n\n"
                        "📌 Bidang Ilmu:\n"
                        "- Mengembangkan ilmu bahasa Arab\n\n"
                        "Pada masa kepemimpinannya, terjadi berbagai konflik internal seperti Perang Jamal "
                        "dan Perang Shiffin.\n\n"
                        "Ali tetap berusaha menjaga persatuan umat Islam di tengah kondisi yang sulit.\n\n"
                        "Beliau dikenal sebagai pemimpin yang adil, bijaksana, dan sangat berani dalam menegakkan kebenaran.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: DuoColors.ink,
        fontFamily: 'Nunito',
        letterSpacing: -0.2,
      ),
    );
  }
}

// =========================
// DUO PRESSABLE WRAPPER
// =========================
class _DuoPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _DuoPressable({required this.child, required this.onTap});

  @override
  State<_DuoPressable> createState() => _DuoPressableState();
}

class _DuoPressableState extends State<_DuoPressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}