import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddMateriPage extends StatefulWidget {
  const AddMateriPage({super.key});

  @override
  State<AddMateriPage> createState() => _AddMateriPageState();
}

class _AddMateriPageState extends State<AddMateriPage> {
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final videoController = TextEditingController();
  final descController = TextEditingController();

  bool isLoading = false;

  Future<void> addMateri() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    // 🔥 ambil role dari Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final role = userDoc.data()?['role'];

    if (role != 'teacher') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Akses ditolak")),
      );
      return;
    }

    // ✅ VALIDASI
    if (titleController.text.isEmpty ||
        subtitleController.text.isEmpty ||
        videoController.text.isEmpty ||
        descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field wajib diisi")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('materi').add({
        "title": titleController.text.trim(),
        "subtitle": subtitleController.text.trim(),
        "videoId": videoController.text.trim(),
        "description": descController.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
        "createdBy": user.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Materi berhasil ditambahkan")),
      );

      Navigator.pop(context); // balik ke halaman materi
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    titleController.dispose();
    subtitleController.dispose();
    videoController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Materi"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 📌 TITLE
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Judul Materi",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // 📌 SUBTITLE
            TextField(
              controller: subtitleController,
              decoration: const InputDecoration(
                labelText: "Subtitle",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // 🎥 VIDEO ID
            TextField(
              controller: videoController,
              decoration: const InputDecoration(
                labelText: "YouTube Video ID",
                hintText: "contoh: Y8flRf3LQhY",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // 📝 DESCRIPTION
            TextField(
              controller: descController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Deskripsi",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),

            // 🚀 BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : addMateri,
                child: isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Simpan Materi"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}