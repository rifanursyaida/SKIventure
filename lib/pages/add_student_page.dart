import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  bool isLoading = false;

  Future<void> addStudent() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    // ✅ VALIDASI
    if (nameController.text.isEmpty || emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field wajib diisi")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('students').add({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "createdBy": user.uid,
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Siswa berhasil ditambahkan")),
      );

      Navigator.pop(context); // balik ke halaman list siswa
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Siswa"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 👤 Nama
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nama Siswa",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // 📧 Email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email Siswa",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),

            // 🚀 Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : addStudent,
                child: isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Simpan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}