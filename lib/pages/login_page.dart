import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skiventure/pages/leaderboard_page.dart';
import '../main.dart';

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

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const TeacherHomePage(),
          ),
        );
      } else {
        final snapshot = await FirebaseFirestore.instance
            .collection('students')
            .where('name', isEqualTo: nameController.text.trim())
            .get();

        if (snapshot.docs.isEmpty) {
          throw "Nama siswa tidak ditemukan";
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LeaderboardPage(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FFF8), // 🌿 soft green
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 🦉 ICON / HEADER
              Column(
                children: const [
                  Icon(Icons.emoji_events, size: 70, color: Colors.green),
                  SizedBox(height: 10),
                  Text(
                    "SKIventure",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Belajar jadi seru! 🚀",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 📦 CARD FORM
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // 🔽 ROLE SWITCH
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        choiceRole("teacher", "Guru", Icons.school),
                        const SizedBox(width: 10),
                        choiceRole("student", "Siswa", Icons.person),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 🔄 FORM
                    if (role == "teacher") ...[
                      TextField(
                        controller: emailController,
                        decoration: inputStyle("Email", Icons.email),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: inputStyle("Password", Icons.lock),
                      ),
                    ] else ...[
                      TextField(
                        controller: nameController,
                        decoration:
                        inputStyle("Nama Siswa", Icons.person),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // 🔘 BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text(
                          "Masuk",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "© SKIventure 2026",
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 ROLE BUTTON
  Widget choiceRole(String value, String title, IconData icon) {
    final isSelected = role == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => role = value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 INPUT STYLE
  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}