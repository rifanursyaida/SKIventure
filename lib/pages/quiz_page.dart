import 'dart:async';
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
  static const red         = Color(0xFFFF4B4B);
  static const redLight    = Color(0xFFFFDDDD);
  static const ink         = Color(0xFF1F1F1F);
  static const inkLight    = Color(0xFF777777);
  static const snow        = Color(0xFFFFFFFF);
  static const polar       = Color(0xFFF7F7F7);
  static const borderGray  = Color(0xFFE5E5E5);
}

// keep AppColors for backward compat (used in showResult icon)
class AppColors {
  static const Color emerald     = Color(0xFF58CC02);
  static const Color emeraldDark = Color(0xFF46A302);
  static const Color gold        = Color(0xFFFFD900);
  static const Color cream       = Color(0xFFF7F7F7);
}

class QuizPage extends StatefulWidget {
  final String studentId;
  final String teacherId;
  final String materiId;

  const QuizPage({
    super.key,
    required this.studentId,
    required this.teacherId,
    required this.materiId,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  late String studentId;
  late String teacherId;
  late String materiId;

  int currentQuestion = 0;
  int correctAnswer   = 0;
  double score        = 0;
  String? selectedAnswer;

  int timeLeft = 15;
  Timer? timer;

  List<Map<String, dynamic>> filteredQuestions = [];

  // progress bar animation
  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  // option press animation controllers per option index
  final Map<int, AnimationController> _optionCtrls = {};
  final Map<int, Animation<double>> _optionScales  = {};

  final List<Map<String, dynamic>> questions = [
    // ================= ABU BAKAR (5 SOAL) =================
    {
      "khalifah": "abu_bakar",
      "question": "Siapa khalifah pertama setelah Rasulullah?",
      "options": ["Umar Bin Khattab","Abu Bakar Ash-Shiddiq","Ali Bin Abi Thalib","Utsman Bin Affan"],
      "answer": "Abu Bakar Ash-Shiddiq",
      "explanation": "Abu Bakar adalah khalifah pertama."
    },
    {
      "khalifah": "abu_bakar",
      "question": "Apa gelar Abu Bakar?",
      "options": ["Al-Amin","As-Shiddiq","Al-Faruq","Dzunnurain"],
      "answer": "As-Shiddiq",
      "explanation": "Gelar beliau As-Shiddiq."
    },
    {
      "khalifah": "abu_bakar",
      "question": "Apa tugas utama Abu Bakar saat awal menjadi khalifah?",
      "options": ["Ekspansi wilayah","Memerangi nabi palsu","Membangun masjid","Menyusun pajak"],
      "answer": "Memerangi nabi palsu",
      "explanation": "Beliau memerangi kaum murtad dan nabi palsu."
    },
    {
      "khalifah": "abu_bakar",
      "question": "Siapa sahabat terdekat Nabi?",
      "options": ["Umar","Abu Bakar Ash-Shiddiq","Ali","Utsman"],
      "answer": "Abu Bakar Ash-Shiddiq",
      "explanation": "Abu Bakar sahabat terdekat Nabi."
    },
    {
      "khalifah": "abu_bakar",
      "question": "Berapa lama masa pemerintahan Abu Bakar?",
      "options": ["2 tahun","5 tahun","10 tahun","1 tahun"],
      "answer": "2 tahun",
      "explanation": "Sekitar 2 tahun."
    },

    // ================= UMAR (5 SOAL) =================
    {
      "khalifah": "umar",
      "question": "Siapa yang membuat kalender Hijriah?",
      "options": ["Abu Bakar","Umar Bin Khattab","Utsman","Ali"],
      "answer": "Umar Bin Khattab",
      "explanation": "Umar menetapkan kalender Hijriah."
    },
    {
      "khalifah": "umar",
      "question": "Apa gelar Umar?",
      "options": ["As-Shiddiq","Al-Faruq","Dzunnurain","Al-Amin"],
      "answer": "Al-Faruq",
      "explanation": "Gelar Umar adalah Al-Faruq."
    },
    {
      "khalifah": "umar",
      "question": "Apa sifat terkenal Umar?",
      "options": ["Lemah lembut","Tegas","Pemalas","Pendiam"],
      "answer": "Tegas",
      "explanation": "Umar dikenal tegas."
    },
    {
      "khalifah": "umar",
      "question": "Wilayah Islam saat Umar mengalami?",
      "options": ["Kemunduran","Perluasan besar","Tidak berubah","Hilang"],
      "answer": "Perluasan besar",
      "explanation": "Terjadi ekspansi besar."
    },
    {
      "khalifah": "umar",
      "question": "Siapa pengganti Abu Bakar?",
      "options": ["Ali","Utsman","Umar Bin Khattab","Hasan"],
      "answer": "Umar Bin Khattab",
      "explanation": "Umar menggantikan Abu Bakar."
    },

    // ================= UTSMAN (5 SOAL) =================
    {
      "khalifah": "utsman",
      "question": "Siapa yang membukukan Al-Qur'an menjadi satu mushaf?",
      "options": ["Utsman Bin Affan","Ali","Umar","Abu Bakar"],
      "answer": "Utsman Bin Affan",
      "explanation": "Utsman menyatukan mushaf."
    },
    {
      "khalifah": "utsman",
      "question": "Apa gelar Utsman?",
      "options": ["Dzunnurain","As-Shiddiq","Al-Faruq","Al-Amin"],
      "answer": "Dzunnurain",
      "explanation": "Gelar beliau Dzunnurain."
    },
    {
      "khalifah": "utsman",
      "question": "Apa sifat utama Utsman?",
      "options": ["Kikir","Dermawan","Kasar","Pemarah"],
      "answer": "Dermawan",
      "explanation": "Utsman sangat dermawan."
    },
    {
      "khalifah": "utsman",
      "question": "Utsman berasal dari suku?",
      "options": ["Quraisy","Aus","Khazraj","Tamim"],
      "answer": "Quraisy",
      "explanation": "Beliau dari Quraisy."
    },
    {
      "khalifah": "utsman",
      "question": "Apa jasa besar Utsman?",
      "options": ["Menyusun hadits","Standarisasi Al-Qur'an","Membuat hukum","Membangun kota"],
      "answer": "Standarisasi Al-Qur'an",
      "explanation": "Standarisasi mushaf."
    },

    // ================= ALI (5 SOAL) =================
    {
      "khalifah": "ali",
      "question": "Siapa yang dikenal sangat cerdas?",
      "options": ["Ali Bin Abi Thalib","Umar","Abu Bakar","Utsman"],
      "answer": "Ali Bin Abi Thalib",
      "explanation": "Ali dikenal cerdas."
    },
    {
      "khalifah": "ali",
      "question": "Ali terkenal dengan sifat?",
      "options": ["Berani","Pelit","Pemalas","Pendiam"],
      "answer": "Berani",
      "explanation": "Ali sangat berani."
    },
    {
      "khalifah": "ali",
      "question": "Ali adalah sepupu dari?",
      "options": ["Umar","Nabi Muhammad","Utsman","Abu Bakar"],
      "answer": "Nabi Muhammad",
      "explanation": "Ali sepupu Nabi."
    },
    {
      "khalifah": "ali",
      "question": "Ali juga dikenal sebagai?",
      "options": ["Ahli perang","Ahli ilmu","Pedagang","Petani"],
      "answer": "Ahli ilmu",
      "explanation": "Ali sangat berilmu."
    },
    {
      "khalifah": "ali",
      "question": "Siapa khalifah terakhir Khulafaur Rasyidin?",
      "options": ["Ali Bin Abi Thalib","Umar","Utsman","Abu Bakar"],
      "answer": "Ali Bin Abi Thalib",
      "explanation": "Ali adalah yang terakhir."
    },
  ];

  // ─────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    studentId = widget.studentId;
    teacherId = widget.teacherId;
    materiId  = widget.materiId;

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _progressAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut),
    );

    loadQuestions();
    _updateProgress();
    startTimer();
  }

  void _initOptionControllers(int count) {
    for (var c in _optionCtrls.values) c.dispose();
    _optionCtrls.clear();
    _optionScales.clear();
    for (int i = 0; i < count; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 90),
      );
      _optionCtrls[i] = ctrl;
      _optionScales[i] = Tween<double>(begin: 1.0, end: 0.96).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
      );
    }
  }

  void _updateProgress() {
    if (filteredQuestions.isEmpty) return;
    final target = (currentQuestion + 1) / filteredQuestions.length;
    _progressAnim = Tween<double>(
      begin: _progressAnim.value,
      end: target,
    ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut));
    _progressCtrl
      ..reset()
      ..forward();
  }

  // ─────────────────────────────────────────
  // LOGIC (unchanged)
  // ─────────────────────────────────────────
  void loadQuestions() {
    filteredQuestions = questions
        .where((q) =>
    q['khalifah'].toString().toLowerCase().trim() ==
        materiId.toLowerCase().trim())
        .toList();
    _initOptionControllers(
        filteredQuestions.isNotEmpty ? filteredQuestions[0]['options'].length : 4);
  }

  void startTimer() {
    timeLeft = 15;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (timeLeft == 0) {
        nextQuestion();
      } else {
        setState(() => timeLeft--);
      }
    });
  }

  void nextQuestion() {
    timer?.cancel();
    if (selectedAnswer == filteredQuestions[currentQuestion]['answer']) {
      score++;
      correctAnswer++;
    }
    showExplanation();
  }

  void showExplanation() {
    final correct  = filteredQuestions[currentQuestion]['answer'];
    final isRight  = selectedAnswer == correct;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DuoExplanationDialog(
        isCorrect: isRight,
        correctAnswer: correct,
        explanation: filteredQuestions[currentQuestion]['explanation'],
        onContinue: () {
          Navigator.pop(context);
          goNext();
        },
      ),
    );
  }

  void goNext() {
    if (currentQuestion < filteredQuestions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
      });
      _initOptionControllers(filteredQuestions[currentQuestion]['options'].length);
      _updateProgress();
      startTimer();
    } else {
      saveResult();
    }
  }

  Future<void> saveResult() async {
    try {
      await FirebaseFirestore.instance.collection('quiz_results').add({
        'correct_answer' : correctAnswer,
        'total_question' : filteredQuestions.length,
        'score'          : score,
        'materi_id'      : materiId,
        'student_id'     : studentId,
        'teacher_id'     : teacherId,
        'created_at'     : Timestamp.now(),
      });
    } catch (e) {}
    showResult();
  }

  void showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DuoResultDialog(
        score: score.toInt(),
        total: filteredQuestions.length,
        onFinish: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _progressCtrl.dispose();
    for (var c in _optionCtrls.values) c.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (filteredQuestions.isEmpty) {
      return Scaffold(
        backgroundColor: DuoColors.polar,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😕', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                "Soal tidak ditemukan untuk:\n$materiId",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: DuoColors.ink,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final question = filteredQuestions[currentQuestion];
    final options  = question['options'] as List;
    final total    = filteredQuestions.length;

    // timer color transitions: green → orange → red
    Color timerColor;
    if (timeLeft > 10)      timerColor = DuoColors.green;
    else if (timeLeft > 5)  timerColor = DuoColors.orange;
    else                    timerColor = DuoColors.red;

    return Scaffold(
      backgroundColor: DuoColors.polar,

      // ── APP BAR ──────────────────────────
      appBar: AppBar(
        elevation: 0,
        backgroundColor: DuoColors.snow,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: DuoColors.inkLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildProgressBar(),
        titleSpacing: 0,
        actions: [
          // Timer pill
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: timerColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: timerColor.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_rounded, size: 16, color: timerColor),
                  const SizedBox(width: 4),
                  Text(
                    '$timeLeft',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: timerColor,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: DuoColors.borderGray),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── QUESTION COUNTER ──────────
              Text(
                'Soal ${currentQuestion + 1} dari $total',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DuoColors.inkLight,
                  fontFamily: 'Nunito',
                ),
              ),

              const SizedBox(height: 12),

              // ── QUESTION CARD ─────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: DuoColors.snow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: DuoColors.borderGray, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: DuoColors.blueLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.help_outline_rounded,
                        color: DuoColors.blue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        question['question'],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: DuoColors.ink,
                          fontFamily: 'Nunito',
                          height: 1.4,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── OPTIONS ───────────────────
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final option    = options[i] as String;
                    final isSelected = selectedAnswer == option;
                    return _OptionTile(
                      label: option,
                      index: i,
                      isSelected: isSelected,
                      scaleAnim: _optionScales[i]!,
                      onTapDown: () => _optionCtrls[i]?.forward(),
                      onTapUp: () {
                        _optionCtrls[i]?.reverse();
                        setState(() => selectedAnswer = option);
                      },
                      onTapCancel: () => _optionCtrls[i]?.reverse(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ── SUBMIT BUTTON ─────────────
              _DuoButton(
                label: 'Jawab',
                enabled: selectedAnswer != null,
                onPressed: selectedAnswer == null ? null : nextQuestion,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: AnimatedBuilder(
        animation: _progressAnim,
        builder: (_, __) => ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: _progressAnim.value,
            minHeight: 10,
            backgroundColor: DuoColors.borderGray,
            valueColor: const AlwaysStoppedAnimation<Color>(DuoColors.green),
          ),
        ),
      ),
    );
  }
}

// =========================
// OPTION TILE
// =========================
class _OptionTile extends StatelessWidget {
  final String label;
  final int index;
  final bool isSelected;
  final Animation<double> scaleAnim;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;

  static const _letters = ['A', 'B', 'C', 'D'];

  const _OptionTile({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.scaleAnim,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: () => onTapCancel(),
      child: ScaleTransition(
        scale: scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? DuoColors.greenLight : DuoColors.snow,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? DuoColors.green : DuoColors.borderGray,
              width: isSelected ? 2.5 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? DuoColors.green.withOpacity(0.15)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 0,
                offset: Offset(0, isSelected ? 3 : 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Letter badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected ? DuoColors.green : DuoColors.polar,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? DuoColors.greenDark
                        : DuoColors.borderGray,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    _letters[index % _letters.length],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : DuoColors.inkLight,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? DuoColors.greenDark : DuoColors.ink,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: DuoColors.green,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================
// EXPLANATION DIALOG
// =========================
class _DuoExplanationDialog extends StatelessWidget {
  final bool isCorrect;
  final String correctAnswer;
  final String explanation;
  final VoidCallback onContinue;

  const _DuoExplanationDialog({
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanation,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final color  = isCorrect ? DuoColors.green : DuoColors.red;
    final bgColor = isCorrect ? DuoColors.greenLight : DuoColors.redLight;
    final emoji  = isCorrect ? '🎉' : '😅';
    final title  = isCorrect ? 'Mantap!' : 'Yuk Belajar Lagi!';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: DuoColors.snow,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji
            Text(emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 8),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 16),

            // Answer box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jawaban benar:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    correctAnswer,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: color,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const Divider(height: 16),
                  Text(
                    explanation,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: DuoColors.ink,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Continue button
            _DuoButton(
              label: 'Lanjut',
              enabled: true,
              onPressed: onContinue,
              color: color,
              shadowColor: isCorrect ? DuoColors.greenDark : const Color(0xFFCC2222),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// RESULT DIALOG
// =========================
class _DuoResultDialog extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onFinish;

  const _DuoResultDialog({
    required this.score,
    required this.total,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final pct     = total > 0 ? (score / total) : 0.0;
    final perfect = pct == 1.0;
    final good    = pct >= 0.6;

    final emoji   = perfect ? '🏆' : good ? '⭐' : '💪';
    final msg     = perfect ? 'Sempurna!' : good ? 'Bagus!' : 'Terus Semangat!';
    final color   = perfect ? DuoColors.yellow : good ? DuoColors.green : DuoColors.blue;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: DuoColors.snow,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 8),
            Text(
              'Quiz Selesai!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: DuoColors.ink,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 24),

            // Score ring area
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: DuoColors.polar,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: DuoColors.borderGray, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stars_rounded, color: AppColors.gold, size: 36),
                  const SizedBox(width: 12),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$score',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: DuoColors.ink,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        TextSpan(
                          text: ' / $total',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: DuoColors.inkLight,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            const Text(
              'Nilai kamu sudah disimpan.',
              style: TextStyle(
                fontSize: 13,
                color: DuoColors.inkLight,
                fontWeight: FontWeight.w600,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 24),

            _DuoButton(
              label: 'Selesai',
              enabled: true,
              onPressed: onFinish,
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// DUO BUTTON
// =========================
class _DuoButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onPressed;
  final Color color;
  final Color shadowColor;

  const _DuoButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.color = DuoColors.green,
    this.shadowColor = DuoColors.greenDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: enabled ? color : DuoColors.borderGray,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: enabled ? shadowColor : DuoColors.borderGray,
              width: 2,
            ),
            boxShadow: enabled
                ? [
              BoxShadow(
                color: shadowColor,
                blurRadius: 0,
                offset: const Offset(0, 5),
              ),
            ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: enabled ? Colors.white : DuoColors.inkLight,
                fontFamily: 'Nunito',
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}