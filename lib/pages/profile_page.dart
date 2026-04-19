import 'package:flutter/material.dart';

class AppColors {
  static const Color emerald = Color(0xFF0D9373);
  static const Color emeraldDark = Color(0xFF065F46);
  static const Color gold = Color(0xFFF59E0B);
  static const Color cream = Color(0xFFF5F7FB); // 🔥 light modern
  static const Color textDark = Color(0xFF1F2937);
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Profil Saya',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // 🔥 HEADER (DUOLINGO STYLE)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
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
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF58CC02),
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: 45, color: Color(0xFF58CC02)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Nama Siswa",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    "Kelas 8A",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 MENU LIST
            _menuItem(
              icon: Icons.book,
              title: "Materi Saya",
              subtitle: "Lihat materi yang sudah dipelajari",
              onTap: () {},
            ),

            _menuItem(
              icon: Icons.quiz,
              title: "Hasil Quiz",
              subtitle: "Cek nilai quiz kamu",
              onTap: () {},
            ),

            _menuItem(
              icon: Icons.emoji_events,
              title: "Progress Belajar",
              subtitle: "Lihat perkembangan kamu",
              onTap: () {},
            ),

            _menuItem(
              icon: Icons.settings,
              title: "Pengaturan",
              subtitle: "Atur akun kamu",
              onTap: () {},
            ),

            _menuItem(
              icon: Icons.logout,
              title: "Keluar",
              subtitle: "Logout dari aplikasi",
              isDanger: true,
              onTap: () {
                // TODO: logout logic
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  static Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
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
        child: ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDanger
                  ? Colors.red.withOpacity(0.1)
                  : const Color(0xFF58CC02).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDanger
                  ? Colors.red
                  : const Color(0xFF58CC02),
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDanger ? Colors.red : Colors.black,
            ),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}