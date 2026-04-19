import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

// pages
import 'pages/login_page.dart';
import 'pages/absensi_page.dart';
import 'pages/profile_page.dart';
import 'pages/leaderboard_page.dart';
import 'pages/add_student_page.dart';
import 'pages/quiz_review.dart';
import 'pages/attendance_review.dart';
import 'session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

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

// =========================
// APP
// =========================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SKIventure Teacher',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: DuoColors.green),
        useMaterial3: true,
        scaffoldBackgroundColor: DuoColors.polar,
        fontFamily: 'Nunito', // Duolingo uses Nunito / rounded sans
      ),
      home: const LoginPage(),
    );
  }
}

// =========================
// HOME PAGE (NAVBAR)
// =========================
class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TeacherDashboard(),
    const Placeholder(),
    const SizedBox(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      _openQuiz();
      return;
    }
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AttendanceReviewPage(
            teacherId: Session.teacherId ?? "",
          ),
        ),
      );
      return;
    }
    setState(() => _selectedIndex = index);
  }

  void _openQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuizReviewPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: _DuoBottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// =========================
// DUOLINGO BOTTOM NAV
// =========================
class _DuoBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _DuoBottomNav({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.home_rounded,       label: 'Home'),
      _NavItem(icon: Icons.quiz_rounded,        label: 'Quiz'),
      _NavItem(icon: Icons.check_circle_rounded, label: 'Absensi'),
      _NavItem(icon: Icons.person_rounded,      label: 'Profil'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: DuoColors.snow,
        border: Border(top: BorderSide(color: DuoColors.borderGray, width: 2)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: selected
                                ? DuoColors.greenLight
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            items[i].icon,
                            size: 24,
                            color: selected
                                ? DuoColors.green
                                : DuoColors.inkLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: selected
                                ? DuoColors.green
                                : DuoColors.inkLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// =========================
// DASHBOARD TEACHER
// =========================
class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Selamat Pagi';
    if (h < 17) return 'Selamat Siang';
    return 'Selamat Malam';
  }

  String get greetingEmoji {
    final h = DateTime.now().hour;
    if (h < 12) return '🌤️';
    if (h < 17) return '☀️';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.polar,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ---- TOP BAR ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/duo_owl.png',
                      height: 36,
                      errorBuilder: (_, __, ___) => const Text(
                        '🦉',
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SKIventure',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: DuoColors.green,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    // XP streak pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: DuoColors.orangeLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: DuoColors.orange.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: const [
                          Text('🔥', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 4),
                          Text(
                            '7',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: DuoColors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---- GREETING CARD ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF58CC02), Color(0xFF78E000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: DuoColors.green.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$greeting $greetingEmoji',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Teacher!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '✨ Siap mengajar hari ini?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ---- SECTION TITLE ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Row(
                  children: const [
                    Text(
                      'Menu Utama',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: DuoColors.ink,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---- MENU GRID ----
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate([
                  _DuoMenuCard(
                    icon: Icons.person_add_alt_1_rounded,
                    title: 'Tambah\nStudent',
                    accentColor: DuoColors.blue,
                    bgColor: DuoColors.blueLight,
                    emoji: '👤',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddStudentPage(),
                        ),
                      );
                    },
                  ),
                  _DuoMenuCard(
                    icon: Icons.quiz_rounded,
                    title: 'Hasil\nQuiz',
                    accentColor: DuoColors.purple,
                    bgColor: DuoColors.purpleLight,
                    emoji: '📝',
                    onTap: () => _openQuizFromMenu(context),
                  ),
                  _DuoMenuCard(
                    icon: Icons.leaderboard_rounded,
                    title: 'Ranking',
                    accentColor: DuoColors.yellow,
                    bgColor: DuoColors.yellowLight,
                    emoji: '🏆',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LeaderboardPage(),
                        ),
                      );
                    },
                  ),
                  _DuoMenuCard(
                    icon: Icons.fact_check_rounded,
                    title: 'Absensi',
                    accentColor: DuoColors.green,
                    bgColor: DuoColors.greenLight,
                    emoji: '✅',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttendanceReviewPage(
                            teacherId: Session.teacherId ?? "",
                          ),
                        ),
                      );
                    },
                  ),
                ]),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.0,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  // =========================
  // QUIZ FROM DASHBOARD MENU
  // =========================
  void _openQuizFromMenu(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuizReviewPage()),
    );
  }
}

// =========================
// DUO MENU CARD WIDGET
// =========================
class _DuoMenuCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color accentColor;
  final Color bgColor;
  final String emoji;
  final VoidCallback onTap;

  const _DuoMenuCard({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.bgColor,
    required this.emoji,
    required this.onTap,
  });

  @override
  State<_DuoMenuCard> createState() => _DuoMenuCardState();
}

class _DuoMenuCardState extends State<_DuoMenuCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.04,
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
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: DuoColors.snow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: DuoColors.borderGray, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
              // Bottom "press" shadow — Duolingo signature
              BoxShadow(
                color: widget.accentColor.withOpacity(0.18),
                blurRadius: 0,
                offset: const Offset(0, 5),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon badge
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 26,
                    color: widget.accentColor,
                  ),
                ),
                // Title + emoji row
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: DuoColors.ink,
                        height: 1.2,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}