import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceReviewPage extends StatelessWidget {
  final String teacherId;

  const AttendanceReviewPage({
    super.key,
    required this.teacherId,
  });

  // Resolve studentId → nama siswa
  Future<String> _getStudentName(String studentId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .get();
      if (doc.exists && doc.data()!.containsKey('name')) {
        return doc['name'];
      }
      return studentId; // fallback ke ID jika tidak ditemukan
    } catch (_) {
      return studentId;
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
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
        ),
        title: const Text(
          "Rekap Absensi",
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('teacher_id', isEqualTo: teacherId)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          // ✅ Tampilkan error agar mudah diagnosis
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("⚠️", style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 12),
                    Text(
                      "Error: ${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFF4B4B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF58CC02)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("📋", style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text(
                    "Belum ada data absensi",
                    style: TextStyle(
                      color: Color(0xFFAFAFAF),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final doc = data[index];
              final studentId = doc['student_id'] as String;
              final status = doc['status'] as String;
              final date = doc['date'] as Timestamp;

              final isHadir = status == "hadir";
              final isIzin = status == "izin";

              final statusColor = isHadir
                  ? const Color(0xFF58CC02)
                  : isIzin
                  ? const Color(0xFFFFB100)
                  : const Color(0xFFFF4B4B);
              final statusShadow = isHadir
                  ? const Color(0xFF46A302)
                  : isIzin
                  ? const Color(0xFFCC8E00)
                  : const Color(0xFFCC3333);
              final cardBorderColor = isHadir
                  ? const Color(0xFF58CC02).withOpacity(0.25)
                  : isIzin
                  ? const Color(0xFFFFB100).withOpacity(0.25)
                  : const Color(0xFFFF4B4B).withOpacity(0.25);
              final cardBgColor = isHadir
                  ? const Color(0xFFF0FDE8)
                  : isIzin
                  ? const Color(0xFFFFFBEB)
                  : const Color(0xFFFFF0F0);
              final statusEmoji = isHadir ? "✅" : isIzin ? "📝" : "🤒";
              final statusIcon = isHadir
                  ? Icons.check_circle_rounded
                  : isIzin
                  ? Icons.edit_note_rounded
                  : Icons.cancel_rounded;

              final dateObj = date.toDate();
              final formattedDate =
                  "${dateObj.day.toString().padLeft(2, '0')}/"
                  "${dateObj.month.toString().padLeft(2, '0')}/"
                  "${dateObj.year}  "
                  "${dateObj.hour.toString().padLeft(2, '0')}:"
                  "${dateObj.minute.toString().padLeft(2, '0')}";

              return FutureBuilder<String>(
                future: _getStudentName(studentId),
                builder: (context, nameSnap) {
                  final studentName = nameSnap.data ?? studentId;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(18),
                      border:
                      Border.all(color: cardBorderColor, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: cardBorderColor,
                          offset: const Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icon status
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: statusColor.withOpacity(0.3),
                                width: 1.5),
                          ),
                          child: Icon(statusIcon,
                              color: statusColor, size: 22),
                        ),

                        const SizedBox(width: 14),

                        // Info siswa & tanggal
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✅ Tampilkan nama siswa, bukan ID
                              Text(
                                studentName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF3C3C3C),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(
                                      Icons.calendar_today_rounded,
                                      size: 11,
                                      color: Color(0xFFAFAFAF)),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFAFAFAF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Badge status
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(99),
                            border: Border(
                              bottom: BorderSide(
                                  color: statusShadow, width: 3),
                            ),
                          ),
                          child: Text(
                            "$statusEmoji ${status.toUpperCase()}",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}