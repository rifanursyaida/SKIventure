import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_student_page.dart';
import '../services/student_service.dart';

// =========================
// DUOLINGO COLOR TOKENS
// (same as main.dart)
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
  static const red         = Color(0xFFFF4B4B);
  static const redLight    = Color(0xFFFFDDDD);
  static const ink         = Color(0xFF1F1F1F);
  static const inkLight    = Color(0xFF777777);
  static const snow        = Color(0xFFFFFFFF);
  static const polar       = Color(0xFFF7F7F7);
  static const borderGray  = Color(0xFFE5E5E5);
}

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final studentService = StudentService();

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
          'Data Siswa',
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

      // ── FAB ──────────────────────────────────
      floatingActionButton: _DuoFAB(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddStudentPage()),
          );
        },
      ),

      // ── BODY ─────────────────────────────────
      body: StreamBuilder<QuerySnapshot>(
        stream: studentService.getStudents(),
        builder: (context, snapshot) {

          // ⏳ LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: DuoColors.green,
                strokeWidth: 3,
              ),
            );
          }

          // ❌ ERROR
          if (snapshot.hasError) {
            return _EmptyState(
              emoji: '😵',
              title: 'Terjadi kesalahan',
              subtitle: 'Coba refresh halaman ini',
            );
          }

          // ❗ EMPTY
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _EmptyState(
              emoji: '🎒',
              title: 'Belum ada siswa',
              subtitle: 'Tambah siswa pertama kamu!',
            );
          }

          final docs = snapshot.data!.docs;

          // 📋 LIST SISWA
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc  = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return _StudentCard(
                index: index,
                name: data['name'] ?? '-',
                email: data['email'] ?? '-',
                onDelete: () async {
                  final error = await studentService.deleteStudent(doc.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error ?? "Siswa berhasil dihapus"),
                      backgroundColor:
                      error != null ? DuoColors.red : DuoColors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// =========================
// STUDENT CARD
// =========================
class _StudentCard extends StatefulWidget {
  final int index;
  final String name;
  final String email;
  final VoidCallback onDelete;

  const _StudentCard({
    required this.index,
    required this.name,
    required this.email,
    required this.onDelete,
  });

  @override
  State<_StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<_StudentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  // Cycle avatar colors like Duolingo
  static const _avatarPalettes = [
    (bg: Color(0xFFDDF4FF), fg: Color(0xFF1CB0F6)),
    (bg: Color(0xFFD7F5B1), fg: Color(0xFF58CC02)),
    (bg: Color(0xFFFFF9C4), fg: Color(0xFFFFD900)),
    (bg: Color(0xFFF4DDFF), fg: Color(0xFFCE82FF)),
    (bg: Color(0xFFFFECCC), fg: Color(0xFFFF9600)),
    (bg: Color(0xFFFFDDDD), fg: Color(0xFFFF4B4B)),
  ];

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
    final palette = _avatarPalettes[widget.index % _avatarPalettes.length];
    final initials = widget.name.isNotEmpty
        ? widget.name.trim()[0].toUpperCase()
        : '?';

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // ── Avatar ──
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: palette.bg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: palette.fg.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: palette.fg,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // ── Name & Email ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: DuoColors.ink,
                          fontFamily: 'Nunito',
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.email,
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

                // ── Popup Menu ──
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'delete') {
                      widget.onDelete();
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: DuoColors.borderGray),
                  ),
                  color: DuoColors.snow,
                  elevation: 4,
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: DuoColors.polar,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.more_horiz_rounded,
                      color: DuoColors.inkLight,
                      size: 20,
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: const [
                          Icon(Icons.delete_outline_rounded,
                              color: DuoColors.red, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Hapus',
                            style: TextStyle(
                              color: DuoColors.red,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ],
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

// =========================
// EMPTY STATE
// =========================
class _EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: DuoColors.ink,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: DuoColors.inkLight,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// DUOLINGO FAB
// =========================
class _DuoFAB extends StatefulWidget {
  final VoidCallback onPressed;
  const _DuoFAB({required this.onPressed});

  @override
  State<_DuoFAB> createState() => _DuoFABState();
}

class _DuoFABState extends State<_DuoFAB>
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
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
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
        widget.onPressed();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: DuoColors.green,
            shape: BoxShape.circle,
            border: Border.all(color: DuoColors.greenDark, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: DuoColors.greenDark.withOpacity(0.5),
                blurRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}