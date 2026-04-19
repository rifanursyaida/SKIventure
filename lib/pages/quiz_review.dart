import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// =========================
// DUOLINGO COLOR TOKENS
// =========================
class DuoColors {
  static const green       = Color(0xFF58CC02);
  static const greenDark   = Color(0xFF46A302);
  static const greenLight  = Color(0xFFD7F5B1);
  static const blue        = Color(0xFF1CB0F6);
  static const blueLight   = Color(0xFFDDF4FF);
  static const yellow      = Color(0xFFFFD900);
  static const yellowLight = Color(0xFFFFF9C4);
  static const orange      = Color(0xFFFF9600);
  static const orangeLight = Color(0xFFFFECCC);
  static const red         = Color(0xFFFF4B4B);
  static const redLight    = Color(0xFFFFDDDD);
  static const purple      = Color(0xFFCE82FF);
  static const purpleLight = Color(0xFFF4DDFF);
  static const ink         = Color(0xFF1F1F1F);
  static const inkLight    = Color(0xFF777777);
  static const snow        = Color(0xFFFFFFFF);
  static const polar       = Color(0xFFF7F7F7);
  static const borderGray  = Color(0xFFE5E5E5);
}

class QuizReviewPage extends StatelessWidget {
  const QuizReviewPage({super.key});

  // score → color + emoji
  ({Color color, Color bgColor, String emoji}) _scoreStyle(int score, int total) {
    if (total == 0) return (color: DuoColors.inkLight, bgColor: DuoColors.polar, emoji: '❔');
    final pct = score / total;
    if (pct == 1.0) return (color: DuoColors.yellow,  bgColor: DuoColors.yellowLight, emoji: '🏆');
    if (pct >= 0.6) return (color: DuoColors.green,   bgColor: DuoColors.greenLight,  emoji: '⭐');
    return              (color: DuoColors.red,     bgColor: DuoColors.redLight,    emoji: '💪');
  }

  // materi → color pair
  ({Color color, Color bgColor}) _materiStyle(String materi) {
    switch (materi.toLowerCase().trim()) {
      case 'abu_bakar': return (color: DuoColors.blue,   bgColor: DuoColors.blueLight);
      case 'umar':      return (color: DuoColors.orange, bgColor: DuoColors.orangeLight);
      case 'utsman':    return (color: DuoColors.purple, bgColor: DuoColors.purpleLight);
      case 'ali':       return (color: DuoColors.green,  bgColor: DuoColors.greenLight);
      default:          return (color: DuoColors.inkLight, bgColor: DuoColors.polar);
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}'
          '  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.polar,

      // ── APP BAR ──────────────────────────────
      appBar: AppBar(
        elevation: 0,
        backgroundColor: DuoColors.snow,
        foregroundColor: DuoColors.ink,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: const Text(
          'Hasil Quiz',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: DuoColors.ink,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: DuoColors.borderGray),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quiz_results')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          // ⏳ LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: DuoColors.green,
                strokeWidth: 3,
              ),
            );
          }

          // ❗ EMPTY
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('📋', style: TextStyle(fontSize: 52)),
                  SizedBox(height: 14),
                  Text(
                    'Belum ada data quiz',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: DuoColors.ink,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Hasil quiz siswa akan muncul di sini',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: DuoColors.inkLight,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              // ✅ Semua field di-cast ke int dengan aman
              final correct   = (item['correct_answer'] ?? 0).toInt();
              final total     = (item['total_question'] ?? 0).toInt();
              final score     = (item['score'] ?? 0).toInt();
              final materi    = item['materi_id'] ?? '-';
              final studentId = item['student_id'] ?? '-';

              final timestamp = item['created_at'] as Timestamp?;
              final date = timestamp != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                  timestamp.millisecondsSinceEpoch)
                  : null;

              final ss = _scoreStyle(score, total);  // sudah int, tidak perlu .toInt() lagi
              final ms = _materiStyle(materi);

              return _QuizResultCard(
                index: index,
                studentId: studentId,
                materi: materi,
                score: score,
                total: total,
                correct: correct,
                date: date,
                scoreColor: ss.color,
                scoreBgColor: ss.bgColor,
                scoreEmoji: ss.emoji,
                materiColor: ms.color,
                materiBgColor: ms.bgColor,
              );
            },
          );
        },
      ),
    );
  }
}

// =========================
// QUIZ RESULT CARD
// =========================
class _QuizResultCard extends StatelessWidget {
  final int index;
  final String studentId;
  final String materi;
  final int score;
  final int total;
  final int correct;
  final DateTime? date;
  final Color scoreColor;
  final Color scoreBgColor;
  final String scoreEmoji;
  final Color materiColor;
  final Color materiBgColor;

  const _QuizResultCard({
    required this.index,
    required this.studentId,
    required this.materi,
    required this.score,
    required this.total,
    required this.correct,
    required this.date,
    required this.scoreColor,
    required this.scoreBgColor,
    required this.scoreEmoji,
    required this.materiColor,
    required this.materiBgColor,
  });

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}'
          '  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _materiLabel(String m) {
    switch (m.toLowerCase().trim()) {
      case 'abu_bakar': return 'Abu Bakar';
      case 'umar':      return 'Umar Bin Khattab';
      case 'utsman':    return 'Utsman Bin Affan';
      case 'ali':       return 'Ali Bin Abi Thalib';
      default:          return m;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? correct / total : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: DuoColors.snow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: DuoColors.borderGray, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [

          // ── TOP ROW ────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                // Rank number bubble
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: DuoColors.polar,
                    shape: BoxShape.circle,
                    border: Border.all(color: DuoColors.borderGray, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: DuoColors.inkLight,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Student ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('students')
                            .doc(studentId)
                            .get(),
                        builder: (context, snap) {
                          final name = (snap.hasData && snap.data!.exists)
                              ? (snap.data!.data() as Map<String, dynamic>)['name'] ?? studentId
                              : studentId;
                          return Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: DuoColors.ink,
                              fontFamily: 'Nunito',
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                      const SizedBox(height: 2),
                      // Materi pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: materiBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _materiLabel(materi),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: materiColor,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Score badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: scoreBgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: scoreColor.withOpacity(0.35), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Text(scoreEmoji,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 5),
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: scoreColor,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── DIVIDER ────────────────────────
          const Divider(height: 1, color: DuoColors.borderGray),

          // ── BOTTOM STATS ROW ───────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              children: [

                // Progress bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: pct.toDouble(),
                          minHeight: 8,
                          backgroundColor: DuoColors.borderGray,
                          valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$correct/$total benar',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: DuoColors.inkLight,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),

                if (date != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 14, color: DuoColors.inkLight),
                      const SizedBox(width: 5),
                      Text(
                        _formatDate(date!),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DuoColors.inkLight,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}