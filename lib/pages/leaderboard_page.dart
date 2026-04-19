import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'materi_page.dart';
import 'quiz_page.dart';
import 'absensi_page.dart';
import 'profile_page.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Assalamu'alaikum",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Selamat Datang!",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: -0.3),
            ),

            const SizedBox(height: 20),

            // ================= QUICK MENU =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                quickButton(Icons.play_arrow, "Quiz", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const Placeholder()));
                }),
                quickButton(Icons.emoji_events, "Ranking", () {}),
                quickButton(Icons.check, "Absensi", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AttendancePage()));
                }),
              ],
            ),

            const SizedBox(height: 20),

            // ================= GRID MENU =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  menuItem(Icons.book, "Materi", () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MateriPage()));
                  }),
                  menuItem(Icons.person, "Profil", () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()));
                  }),
                  menuItem(Icons.settings, "Pengaturan", () {
                    showStaticPage(context, "Pengaturan");
                  }),
                  menuItem(Icons.help, "Panduan", () {
                    showStaticPage(context, "Panduan");
                  }),
                  menuItem(Icons.info, "About", () {
                    showStaticPage(context, "About");
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= LEADERBOARD =================
            const Text(
              "🏆 Leaderboard Kelas",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('quiz_results')
                  .orderBy('score', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data!.docs;

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
                          return const ListTile(title: Text("Loading..."));
                        }

                        final student = snap.data!;
                        final name = student['name'];

                        String medal = "";
                        if (index == 0) medal = "🥇";
                        if (index == 1) medal = "🥈";
                        if (index == 2) medal = "🥉";

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                "$medal",
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 10),
                              CircleAvatar(
                                backgroundColor: const Color(0xFF58CC02),
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                "$score",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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

            const SizedBox(height: 80),
          ],
        ),
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF58CC02),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MateriPage()));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const Placeholder()));
          } else if (index == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AttendancePage()));
          } else if (index == 4) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfilePage()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Materi"),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: "Quiz"),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: "Absensi"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  // ================= QUICK BUTTON =================
  static Widget quickButton(
      IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF58CC02),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 10,
                )
              ],
            ),
            child: Icon(icon, color: Colors.white),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(duration: 1500.ms, begin: const Offset(1, 1), end: const Offset(1.08, 1.08)),
          const SizedBox(height: 6),
          Text(title),
        ],
      ),
    );
  }

  // ================= MENU ITEM =================
  static Widget menuItem(
      IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF58CC02).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF58CC02)),
          ).animate().scale(delay: 200.ms),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  static void showStaticPage(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFFF5F7FB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(title,
                style: const TextStyle(color: Colors.black)),
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: Center(
            child: Text(
              "$title Page",
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}