import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String? selectedStudentId;
  String teacherId = "O9p2Nhl1CspdbrvJjHXo";
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
          'name': doc.data().containsKey('name')
              ? doc['name']
              : 'Tanpa Nama',
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
    final endOfDay =
    DateTime(now.year, now.month, now.day, 23, 59, 59);

    final snapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('student_id', isEqualTo: selectedStudentId)
        .where('date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date',
        isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> submitAbsensi() async {
    if (selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih siswa dulu')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      bool sudahAbsen = await alreadyAbsenToday();

      if (sudahAbsen) {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Siswa sudah absen hari ini')),
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
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Absensi",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: submitted ? successView() : formView(),
    );
  }

  Widget formView() {
    if (isFetchingStudents) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 🔹 CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Pilih Siswa",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF1F3F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  hint: const Text("Pilih Siswa"),
                  value: students.any((s) => s['id'] == selectedStudentId)
                      ? selectedStudentId
                      : null,
                  items: students.map((siswa) {
                    return DropdownMenuItem<String>(
                      value: siswa['id'],
                      child: Text(siswa['name'] ?? 'Tanpa Nama'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStudentId = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Status Kehadiran",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    statusChip("Hadir", "hadir", Colors.green),
                    statusChip("Izin", "izin", Colors.orange),
                    statusChip("Sakit", "sakit", Colors.red),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // 🔹 BUTTON DUOLINGO STYLE
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58CC02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              onPressed: isLoading ? null : submitAbsensi,
              child: isLoading
                  ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
                  : const Text(
                "Submit",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget statusChip(String label, String value, Color color) {
    final selected = status == value;

    return GestureDetector(
      onTap: () => setState(() => status = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget successView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF58CC02),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 50),
          ),
          const SizedBox(height: 20),
          const Text(
            "Berhasil!",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text("Status: $status"),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58CC02),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              setState(() {
                submitted = false;
                selectedStudentId = null;
              });
            },
            child: const Text("Input Lagi"),
          )
        ],
      ),
    );
  }
}