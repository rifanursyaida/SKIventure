import 'package:flutter/material.dart';
import '../session.dart';
import 'login_page.dart';
import 'leaderboard_page.dart';

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
  static const red         = Color(0xFFFF4B4B);
  static const redLight    = Color(0xFFFFDDDD);
  static const ink         = Color(0xFF1F1F1F);
  static const inkLight    = Color(0xFF777777);
  static const snow        = Color(0xFFFFFFFF);
  static const polar       = Color(0xFFF7F7F7);
  static const borderGray  = Color(0xFFE5E5E5);
}

// keep AppColors for backward compat
class AppColors {
  static const Color emerald     = Color(0xFF0D9373);
  static const Color emeraldDark = Color(0xFF065F46);
  static const Color gold        = Color(0xFFF59E0B);
  static const Color cream       = Color(0xFFF5F7FB);
  static const Color textDark    = Color(0xFF1F2937);
  static const Color duoGreen    = Color(0xFF58CC02);
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final name = Session.name ?? "Nama Siswa";
    final initials = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: DuoColors.polar,

      // ── APP BAR ──────────────────────────────
      appBar: AppBar(
        elevation: 0,
        backgroundColor: DuoColors.snow,
        foregroundColor: DuoColors.ink,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: const Text(
          'Profil Saya',
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

      body: SingleChildScrollView(
        child: Column(
          children: [

            // ── PROFILE HEADER ───────────────────
            Container(
              width: double.infinity,
              color: DuoColors.snow,
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // Avatar ring
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: DuoColors.green, width: 3),
                        ),
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            color: DuoColors.greenLight,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: DuoColors.greenDark,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Online dot
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: DuoColors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: DuoColors.snow, width: 2.5),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: DuoColors.ink,
                      fontFamily: 'Nunito',
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Role pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: DuoColors.greenLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: DuoColors.green.withOpacity(0.4)),
                    ),
                    child: const Text(
                      '🦉  Siswa SKIventure',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: DuoColors.greenDark,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Stats strip
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: DuoColors.polar,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: DuoColors.borderGray, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statItem('🔥', '7', 'Hari Streak'),
                        _divider(),
                        _statItem('⭐', 'SKI', 'Kelas'),
                        _divider(),
                        _statItem('🏅', 'Aktif', 'Status'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── SECTION TITLE ────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Menu',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: DuoColors.inkLight,
                    fontFamily: 'Nunito',
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // ── MENU ITEMS ───────────────────────
            _DuoMenuItem(
              icon: Icons.leaderboard_rounded,
              title: 'Hasil Quiz',
              subtitle: 'Cek nilai dan peringkat kamu',
              iconColor: DuoColors.blue,
              iconBgColor: DuoColors.blueLight,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                );
              },
            ),

            _DuoMenuItem(
              icon: Icons.logout_rounded,
              title: 'Keluar',
              subtitle: 'Logout dari aplikasi',
              iconColor: DuoColors.red,
              iconBgColor: DuoColors.redLight,
              isDanger: true,
              onTap: () => _showLogoutDialog(context),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────
  Widget _statItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: DuoColors.ink,
            fontFamily: 'Nunito',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: DuoColors.inkLight,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(
    width: 1.5,
    height: 36,
    color: DuoColors.borderGray,
  );

  // ── LOGOUT DIALOG (unchanged logic) ──────
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28)),
        backgroundColor: DuoColors.snow,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DuoColors.redLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: DuoColors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Mau keluar?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: DuoColors.ink,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kamu akan keluar dari akun ini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DuoColors.inkLight,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  // Batal
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: DuoColors.polar,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: DuoColors.borderGray, width: 2),
                        ),
                        child: const Center(
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: DuoColors.inkLight,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Keluar
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Bersihkan data session
                        Session.name      = null;
                        Session.role      = null;
                        Session.studentId = null;
                        Session.teacherId = null;

                        // Kembali ke Login Page dan hapus semua history navigasi
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginPage()),
                              (route) => false,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: DuoColors.red,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFFCC2222), width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFCC2222),
                              blurRadius: 0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Keluar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================
// DUO MENU ITEM
// =========================
class _DuoMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBgColor;
  final bool isDanger;
  final VoidCallback onTap;

  const _DuoMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  State<_DuoMenuItem> createState() => _DuoMenuItemState();
}

class _DuoMenuItemState extends State<_DuoMenuItem>
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
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: DuoColors.snow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: DuoColors.borderGray, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon badge
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: widget.isDanger
                              ? DuoColors.red
                              : DuoColors.ink,
                          fontFamily: 'Nunito',
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: DuoColors.inkLight,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  color: DuoColors.inkLight,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}