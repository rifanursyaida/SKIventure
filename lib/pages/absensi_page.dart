import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../session.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String? selectedStudentId;
  String get teacherId => Session.teacherId ?? "";
  String status = "hadir";

  bool isLoading = false;
  bool submitted = false;
  bool isFetchingStudents = true;

  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('students').get();

      final data = snapshot.docs.map((doc) {
        return {
          'id': doc.id.toString(),
          'name': doc.data().containsKey('name') ? doc['name'] : 'Tanpa Nama',
        };
      }).toList();

      setState(() {
        students = data;
        isFetchingStudents = false;
      });
    } catch (e) {
      setState(() => isFetchingStudents = false);
      debugPrint("Error fetch students: $e");
    }
  }

  Future<bool> alreadyAbsenToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final snapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('student_id', isEqualTo: selectedStudentId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> submitAbsensi() async {
    if (selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih siswa dulu'),
          backgroundColor: const Color(0xFFFF4B4B),
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      bool sudahAbsen = await alreadyAbsenToday();

      if (sudahAbsen) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Siswa sudah absen hari ini'),
            backgroundColor: const Color(0xFFFFB100),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('attendance').add({
        'student_id': selectedStudentId,
        'teacher_id': teacherId,
        'status': status,
        'date': Timestamp.now(),
        'created_at': Timestamp.now(),
      });

      setState(() {
        isLoading = false;
        submitted = true;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFFF4B4B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
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
            child:
            const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
        ),
        title: const Text(
          "Absensi",
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
      body: submitted ? successView() : formView(),
    );
  }

  Widget formView() {
    if (isFetchingStudents) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF58CC02)),
      );
    }

    return SingleChildScrollView(
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
                Text("📅", style: TextStyle(fontSize: 20)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Catat kehadiran siswa hari ini",
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

          // ── CARD PILIH SISWA ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFFE5E5E5), width: 1.5),
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
                // Label
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
                      "Pilih Siswa",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Color(0xFF3C3C3C),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Dropdown
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
                    "Pilih nama siswa...",
                    style: TextStyle(
                        color: Color(0xFFAFAFAF), fontSize: 14),
                  ),
                  value: students.any((s) => s['id'] == selectedStudentId)
                      ? selectedStudentId
                      : null,
                  items: students.map((siswa) {
                    return DropdownMenuItem<String>(
                      value: siswa['id'],
                      child: Text(
                        siswa['name'] ?? 'Tanpa Nama',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3C3C3C),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedStudentId = value);
                  },
                ),

                const SizedBox(height: 24),

                // Label status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1CB0F6).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.how_to_reg_rounded,
                          color: Color(0xFF1CB0F6), size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Status Kehadiran",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Color(0xFF3C3C3C),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Status chips
                Row(
                  children: [
                    Expanded(
                      child: _statusChip(
                        label: "Hadir",
                        value: "hadir",
                        activeColor: const Color(0xFF58CC02),
                        activeShadow: const Color(0xFF46A302),
                        emoji: "✅",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statusChip(
                        label: "Izin",
                        value: "izin",
                        activeColor: const Color(0xFFFFB100),
                        activeShadow: const Color(0xFFCC8E00),
                        emoji: "📝",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statusChip(
                        label: "Sakit",
                        value: "sakit",
                        activeColor: const Color(0xFFFF4B4B),
                        activeShadow: const Color(0xFFCC3333),
                        emoji: "🤒",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── TOMBOL SUBMIT ──
          GestureDetector(
            onTap: isLoading ? null : submitAbsensi,
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
                    color: Colors.white, strokeWidth: 2.5),
              )
                  : const Text(
                "Submit Absensi",
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
    );
  }

  Widget _statusChip({
    required String label,
    required String value,
    required Color activeColor,
    required Color activeShadow,
    required String emoji,
  }) {
    final isSelected = status == value;

    return GestureDetector(
      onTap: () => setState(() => status = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(14),
          border: Border(
            bottom: BorderSide(
              color: isSelected ? activeShadow : const Color(0xFFDDDDDD),
              width: 3,
            ),
            top: BorderSide(
              color: isSelected
                  ? activeColor.withOpacity(0.3)
                  : const Color(0xFFE5E5E5),
              width: 1.5,
            ),
            left: BorderSide(
              color: isSelected
                  ? activeColor.withOpacity(0.3)
                  : const Color(0xFFE5E5E5),
              width: 1.5,
            ),
            right: BorderSide(
              color: isSelected
                  ? activeColor.withOpacity(0.3)
                  : const Color(0xFFE5E5E5),
              width: 1.5,
            ),
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFFAFAFAF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget successView() {
    final statusEmoji = status == "hadir"
        ? "✅"
        : status == "izin"
        ? "📝"
        : "🤒";
    final statusColor = status == "hadir"
        ? const Color(0xFF58CC02)
        : status == "izin"
        ? const Color(0xFFFFB100)
        : const Color(0xFFFF4B4B);
    final statusShadow = status == "hadir"
        ? const Color(0xFF46A302)
        : status == "izin"
        ? const Color(0xFFCC8E00)
        : const Color(0xFFCC3333);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animasi centang
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF58CC02),
                shape: BoxShape.circle,
                border: const Border(
                  bottom: BorderSide(
                    color: Color(0xFF46A302),
                    width: 5,
                  ),
                ),
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 52),
            ),

            const SizedBox(height: 24),

            const Text(
              "Absensi Berhasil! 🎉",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF3C3C3C),
              ),
            ),

            const SizedBox(height: 12),

            // Status badge
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(99),
                border: Border(
                  bottom: BorderSide(color: statusShadow, width: 3),
                ),
              ),
              child: Text(
                "$statusEmoji  ${status.toUpperCase()}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Tombol input lagi
            GestureDetector(
              onTap: () {
                setState(() {
                  submitted = false;
                  selectedStudentId = null;
                  status = "hadir";
                });
              },
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF58CC02),
                  borderRadius: BorderRadius.circular(16),
                  border: const Border(
                    bottom: BorderSide(
                      color: Color(0xFF46A302),
                      width: 4,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Input Lagi",
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
    );
  }
}