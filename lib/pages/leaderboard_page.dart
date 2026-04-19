import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../session.dart';

import 'materi_page.dart';
import 'quiz_page.dart';
import 'absensi_page.dart';
import 'profile_page.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = Session.name ?? "User";

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 52, bottom: 28),
              decoration: const BoxDecoration(
                color: Color(0xFF58CC02),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "Assalamu'alaikum 👋",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Halo, $userName!",
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // XP Bar khas Duolingo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "⚡ XP Hari Ini",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "Semangat belajar!",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: 0.6,
                            minHeight: 10,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: -0.3),
            ),

            const SizedBox(height: 24),

            // ================= QUICK MENU =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _quickButton(
                    icon: Icons.play_arrow_rounded,
                    label: "Quiz",
                    color: const Color(0xFF58CC02),
                    shadowColor: const Color(0xFF46A302),
                    onTap: () => showQuizPicker(context),
                  ),
                  const SizedBox(width: 12),
                  _quickButton(
                    icon: Icons.emoji_events_rounded,
                    label: "Ranking",
                    color: const Color(0xFFFFB100),
                    shadowColor: const Color(0xFFCC8E00),
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  _quickButton(
                    icon: Icons.check_circle_rounded,
                    label: "Absensi",
                    color: const Color(0xFF1CB0F6),
                    shadowColor: const Color(0xFF0E8ECC),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AttendancePage()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= GRID MENU =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  _menuItem(
                    icon: Icons.book_rounded,
                    label: "Materi",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MateriPage()),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Icons.person_rounded,
                    label: "Profil",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProfilePage()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= LEADERBOARD TITLE =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB100).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text("🏆", style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Leaderboard Kelas",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3C3C3C),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ================= LEADERBOARD LIST =================
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('quiz_results')
                  .where('teacher_id', isEqualTo: Session.teacherId)
                  .orderBy('score', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text("Error: ${snapshot.error}"),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF58CC02),
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Text("🎯", style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        const Text(
                          "Belum ada data nilai di kelas ini",
                          style: TextStyle(
                            color: Color(0xFFAFAFAF),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index];
                    final studentId = data['student_id'];
                    final score = data['score'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('students')
                          .doc(studentId)
                          .get(),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 4),
                            child: LinearProgressIndicator(
                              color: Color(0xFF58CC02),
                            ),
                          );
                        }

                        final student = snap.data!;
                        final name = student['name'];

                        // Medal & warna peringkat
                        String medal = "";
                        Color cardColor = Colors.white;
                        Color borderColor = const Color(0xFFE5E5E5);

                        if (index == 0) {
                          medal = "🥇";
                          cardColor = const Color(0xFFFFFBEB);
                          borderColor = const Color(0xFFFFB100);
                        } else if (index == 1) {
                          medal = "🥈";
                          cardColor = const Color(0xFFF5F5F5);
                          borderColor = const Color(0xFFAFAFAF);
                        } else if (index == 2) {
                          medal = "🥉";
                          cardColor = const Color(0xFFFFF5F0);
                          borderColor = const Color(0xFFE07B4A);
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: borderColor,
                              width: 1.5,
                            ),
                            // Efek 3D khas Duolingo untuk top 3
                            boxShadow: index < 3
                                ? [
                              BoxShadow(
                                color: borderColor.withOpacity(0.4),
                                offset: const Offset(0, 3),
                                blurRadius: 0,
                              )
                            ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              // Nomor / Medal
                              SizedBox(
                                width: 32,
                                child: medal.isNotEmpty
                                    ? Text(
                                  medal,
                                  style: const TextStyle(fontSize: 20),
                                )
                                    : Text(
                                  "${index + 1}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFAFAFAF),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Avatar
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF58CC02)
                                      .withOpacity(0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF58CC02)
                                        .withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : "?",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF58CC02),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Nama
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Color(0xFF3C3C3C),
                                  ),
                                ),
                              ),

                              // Score badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF58CC02),
                                  borderRadius: BorderRadius.circular(99),
                                  border: const Border(
                                    bottom: BorderSide(
                                      color: Color(0xFF46A302),
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "$score",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: (index * 100).ms)
                            .slideX(begin: 0.2);
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFE5E5E5), width: 1.5),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF58CC02),
          unselectedItemColor: const Color(0xFFAFAFAF),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) {
            if (index == 1) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MateriPage()));
            } else if (index == 2) {
              showQuizPicker(context);
            } else if (index == 3) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AttendancePage()));
            } else if (index == 4) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()));
            }
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: "Beranda"),
            BottomNavigationBarItem(
                icon: Icon(Icons.book_rounded), label: "Materi"),
            BottomNavigationBarItem(
                icon: Icon(Icons.quiz_rounded), label: "Quiz"),
            BottomNavigationBarItem(
                icon: Icon(Icons.check_circle_rounded), label: "Absensi"),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: "Profil"),
          ],
        ),
      ),
    );
  }

  // ================= QUIZ PICKER =================
  static void showQuizPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Pilih Quiz Khalifah",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3C3C3C),
                ),
              ),
              const SizedBox(height: 16),
              quizItem(context, "Abu Bakar", "abu_bakar"),
              quizItem(context, "Umar bin Khattab", "umar"),
              quizItem(context, "Utsman bin Affan", "utsman"),
              quizItem(context, "Ali bin Abi Thalib", "ali"),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  static Widget quizItem(
      BuildContext context, String title, String materiId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1.5),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF58CC02).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.menu_book_rounded,
              color: Color(0xFF58CC02), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Color(0xFF3C3C3C),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: Color(0xFFAFAFAF)),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizPage(
                studentId: Session.studentId ?? "",
                teacherId: Session.teacherId ?? "",
                materiId: materiId,
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= QUICK BUTTON =================
  static Widget _quickButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              bottom: BorderSide(color: shadowColor, width: 4),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= MENU ITEM =================
  static Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFE5E5E5),
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF58CC02), size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3C3C3C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showStaticPage(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(child: Text("$title Page")),
        ),
      ),
    );
  }
}