import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'leaderboard_page.dart';
import '../main.dart';
import '../session.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  String role = "teacher";
  bool isLoading = false;
  bool obscurePassword = true; // ✅ TAMBAHAN: state untuk toggle password

  Future<void> handleLogin() async {
    setState(() => isLoading = true);

    try {
      if (role == "teacher") {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: emailController.text.trim())
            .where('password', isEqualTo: passwordController.text.trim())
            .where('role', isEqualTo: 'teacher')
            .get();

        if (snapshot.docs.isEmpty) {
          throw "Email atau password salah";
        }

        final user = snapshot.docs.first;

        Session.name = user['name'];
        Session.role = "teacher";
        Session.teacherId = user.id;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TeacherHomePage()),
        );
      } else {
        final snapshot = await FirebaseFirestore.instance
            .collection('students')
            .where('name', isEqualTo: nameController.text.trim())
            .get();

        if (snapshot.docs.isEmpty) {
          throw "Nama siswa tidak ditemukan";
        }

        final student = snapshot.docs.first;

        Session.studentId = student.id;
        Session.name = student['name'];
        Session.role = "student";
        Session.teacherId = student['teacher_id'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LeaderboardPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFFFF4B4B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── HEADER HIJAU ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36),
                decoration: const BoxDecoration(
                  color: Color(0xFF58CC02),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        "🦉",
                        style: TextStyle(fontSize: 48),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "SKIventure",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Belajar jadi seru!",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── CARD ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E5E5), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      // ── ROLE TOGGLE ──
                      Row(
                        children: [
                          _choiceRole("teacher", "Guru", "🎓"),
                          const SizedBox(width: 10),
                          _choiceRole("student", "Siswa", "👤"),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── FIELDS ──
                      if (role == "teacher") ...[
                        _buildTextField(
                          controller: emailController,
                          label: "Email",
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 12),
                        // ✅ Password field dengan icon mata
                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF3C3C3C),
                          ),
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: const TextStyle(
                              color: Color(0xFFAFAFAF),
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFFAFAFAF),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() => obscurePassword = !obscurePassword);
                              },
                              child: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: obscurePassword
                                    ? const Color(0xFFAFAFAF)
                                    : const Color(0xFF58CC02),
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF7F7F7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E5E5),
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E5E5),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF58CC02),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        _buildTextField(
                          controller: nameController,
                          label: "Nama Siswa",
                          icon: Icons.person_outline,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── TOMBOL MASUK (Duolingo 3D style) ──
                      GestureDetector(
                        onTap: isLoading ? null : handleLogin,
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            color: isLoading
                                ? const Color(0xFFAFAFAF)
                                : const Color(0xFF58CC02),
                            borderRadius: BorderRadius.circular(16),
                            // Efek "3D" khas Duolingo
                            border: Border(
                              bottom: BorderSide(
                                color: isLoading
                                    ? const Color(0xFF8C8C8C)
                                    : const Color(0xFF46A302),
                                width: 4,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: isLoading
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : const Text(
                            "Masuk",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "© SKIventure 2026",
                style: TextStyle(
                  color: Color(0xFFAFAFAF),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── WIDGET: Role Toggle ──
  Widget _choiceRole(String value, String title, String emoji) {
    final isSelected = role == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => role = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF58CC02) : const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(14),
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFF46A302)
                    : const Color(0xFFDDDDDD),
                width: 3,
              ),
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFFAFAFAF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── WIDGET: Text Field ──
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF3C3C3C),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFFAFAFAF),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFFAFAFAF)),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE5E5E5),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE5E5E5),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF58CC02),
            width: 2,
          ),
        ),
      ),
    );
  }
}