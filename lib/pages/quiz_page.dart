import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppColors {
  static const Color emerald = Color(0xFF0D9373);
  static const Color emeraldDark = Color(0xFF065F46);
  static const Color gold = Color(0xFFF59E0B);
  static const Color cream = Color(0xFFF5F7FB); // 🔥 light modern
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestion = 0;
  int score = 0;
  String? selectedAnswer;

  int timeLeft = 15;
  Timer? timer;

  final user = FirebaseAuth.instance.currentUser;

  final List<Map<String, dynamic>> questions = [
    {
      "question": "Siapa khalifah pertama setelah Rasulullah?",
      "options": [
        "Umar Bin Khattab",
        "Abu Bakar Ash-Shiddiq",
        "Ali Bin Abi Thalib",
        "Utsman Bin Affan"
      ],
      "answer": "Abu Bakar Ash-Shiddiq",
      "explanation":
      "Abu Bakar adalah sahabat terdekat Nabi dan menjadi khalifah pertama."
    },
    {
      "question": "Siapa yang membuat kalender Hijriah?",
      "options": ["Abu Bakar", "Umar Bin Khattab", "Utsman", "Ali"],
      "answer": "Umar Bin Khattab",
      "explanation":
      "Umar menetapkan kalender Hijriah sebagai sistem penanggalan Islam."
    },
    {
      "question": "Siapa yang membukukan Al-Qur’an menjadi satu mushaf?",
      "options": [
        "Utsman Bin Affan",
        "Ali",
        "Umar",
        "Abu Bakar"
      ],
      "answer": "Utsman Bin Affan",
      "explanation":
      "Utsman menyatukan Al-Qur’an menjadi satu mushaf standar."
    },
    {
      "question": "Siapa yang dikenal sangat cerdas dan ahli ilmu?",
      "options": [
        "Ali Bin Abi Thalib",
        "Umar",
        "Abu Bakar",
        "Utsman"
      ],
      "answer": "Ali Bin Abi Thalib",
      "explanation":
      "Ali dikenal sangat cerdas dan ahli dalam berbagai ilmu."
    },
  ];

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timeLeft = 15;
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft == 0) {
        nextQuestion();
      } else {
        setState(() {
          timeLeft--;
        });
      }
    });
  }

  void nextQuestion() {
    timer?.cancel();

    if (selectedAnswer == questions[currentQuestion]['answer']) {
      score++;
    }

    showExplanation();
  }

  void showExplanation() {
    final correctAnswer = questions[currentQuestion]['answer'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text("Penjelasan"),
        content: Text(
          "Jawaban benar: $correctAnswer\n\n"
              "${questions[currentQuestion]['explanation']}",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              goNext();
            },
            child: const Text("Lanjut"),
          )
        ],
      ),
    );
  }

  void goNext() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
      });
      startTimer();
    } else {
      saveResult();
    }
  }

  Future<void> saveResult() async {
    try {
      await FirebaseFirestore.instance.collection('quiz_results').add({
        'userId': user?.uid,
        'score': score,
        'total': questions.length,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {}

    showResult();
  }

  void showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text("Hasil Quiz"),
        content: Text("Skor kamu: $score / ${questions.length}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentQuestion = 0;
                score = 0;
                selectedAnswer = null;
              });
              startTimer();
            },
            child: const Text("Ulangi"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Quiz",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔥 HEADER INFO
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Soal ${currentQuestion + 1}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "⏱ $timeLeft d",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🔥 PROGRESS BAR
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (currentQuestion + 1) / questions.length,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                color: const Color(0xFF58CC02),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 QUESTION CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Text(
                question['question'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 OPTIONS
            ...question['options'].map<Widget>((option) {
              final isSelected = selectedAnswer == option;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedAnswer = option;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF58CC02).withOpacity(0.15)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF58CC02)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              );
            }).toList(),

            const Spacer(),

            // 🔥 BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: selectedAnswer == null ? null : nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Jawab",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}