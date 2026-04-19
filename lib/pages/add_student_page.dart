import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final nameController = TextEditingController();

  String? selectedKelas;
  bool isLoading = false;

  String teacherId = "O9p2Nhl1CspdbrvJjHXo";

  final List<String> kelasList = ["XI"];

  Future<void> addStudent() async {
    if (nameController.text.isEmpty || selectedKelas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Nama dan kelas wajib diisi"),
          backgroundColor: const Color(0xFFFF4B4B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('students').add({
        "name": nameController.text.trim(),
        "kelas": selectedKelas,
        "teacher_id": teacherId,
        "created_at": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Siswa berhasil ditambahkan! 🎉"),
          backgroundColor: const Color(0xFF58CC02),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
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
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF58CC02),
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
        ),
        title: const Text(
          "Tambah Siswa",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ── INFO BANNER ──
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF58CC02).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF58CC02).withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: const [
                  Text("🎓", style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Isi data siswa baru dengan lengkap",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3C8A00),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── CARD FORM ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border:
                Border.all(color: const Color(0xFFE5E5E5), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFE5E5E5),
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── LABEL NAMA ──
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF58CC02).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: Color(0xFF58CC02), size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Nama Siswa",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Color(0xFF3C3C3C),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── FIELD NAMA ──
                  TextField(
                    controller: nameController,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3C3C3C),
                    ),
                    decoration: InputDecoration(
                      hintText: "Masukkan nama siswa...",
                      hintStyle: const TextStyle(
                        color: Color(0xFFAFAFAF),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7F7F7),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFFE5E5E5), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFFE5E5E5), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF58CC02), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.edit_rounded,
                          color: Color(0xFFAFAFAF), size: 18),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── LABEL KELAS ──
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1CB0F6).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.class_rounded,
                            color: Color(0xFF1CB0F6), size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Kelas",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Color(0xFF3C3C3C),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── DROPDOWN KELAS ──
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF7F7F7),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFFE5E5E5), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFFE5E5E5), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF58CC02), width: 2),
                      ),
                    ),
                    hint: const Text(
                      "Pilih kelas...",
                      style: TextStyle(
                        color: Color(0xFFAFAFAF),
                        fontSize: 14,
                      ),
                    ),
                    value: selectedKelas,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFFAFAFAF)),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3C3C3C),
                    ),
                    items: kelasList.map((kelas) {
                      return DropdownMenuItem(
                        value: kelas,
                        child: Text(kelas),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedKelas = value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── TOMBOL SIMPAN ──
            GestureDetector(
              onTap: isLoading ? null : addStudent,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: isLoading
                      ? const Color(0xFFAFAFAF)
                      : const Color(0xFF58CC02),
                  borderRadius: BorderRadius.circular(16),
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
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Simpan Siswa",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── TOMBOL BATAL ──
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE5E5E5),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Batal",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFAFAFAF),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}