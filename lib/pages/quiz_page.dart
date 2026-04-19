import 'dart:async';
import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  final String studentId;
  final String teacherId;
  final String materiId; // nama khalifah

  const QuizPage({
    super.key,
    required this.studentId,
    required this.teacherId,
    required this.materiId,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestion = 0;
  int score = 0;
  int correctAnswer = 0;
  int timeLeft = 30;
  Timer? timer;

  List<Map<String, dynamic>> questions = [
    // ===== EXISTING (tetap dipertahankan) =====
    {
      'question': 'Siapa khalifah pertama?',
      'options': ['Ali', 'Umar', 'Abu Bakar', 'Utsman'],
      'answer': 2,
      'khalifah': 'Abu Bakar'
    },

    // ===== TAMBAHAN (total 20 soal, 5 per khalifah) =====

    // Abu Bakar
    {
      'question': 'Apa gelar Abu Bakar?',
      'options': ['Al-Faruq', 'As-Siddiq', 'Dzun Nurain', 'Al-Murtadha'],
      'answer': 1,
      'khalifah': 'Abu Bakar'
    },
    {
      'question': 'Apa fokus utama Abu Bakar?',
      'options': ['Ekspansi', 'Kodifikasi Quran', 'Memerangi murtad', 'Administrasi'],
      'answer': 2,
      'khalifah': 'Abu Bakar'
    },
    {
      'question': 'Berapa lama Abu Bakar memerintah?',
      'options': ['2 tahun', '5 tahun', '10 tahun', '1 tahun'],
      'answer': 0,
      'khalifah': 'Abu Bakar'
    },
    {
      'question': 'Siapa sahabat dekat Nabi?',
      'options': ['Umar', 'Ali', 'Abu Bakar', 'Utsman'],
      'answer': 2,
      'khalifah': 'Abu Bakar'
    },

    // Umar
    {
      'question': 'Siapa khalifah kedua?',
      'options': ['Ali', 'Umar', 'Utsman', 'Abu Bakar'],
      'answer': 1,
      'khalifah': 'Umar'
    },
    {
      'question': 'Gelar Umar?',
      'options': ['As-Siddiq', 'Al-Faruq', 'Dzun Nurain', 'Al-Amin'],
      'answer': 1,
      'khalifah': 'Umar'
    },
    {
      'question': 'Apa keunggulan Umar?',
      'options': ['Lembut', 'Tegas', 'Pemalu', 'Diam'],
      'answer': 1,
      'khalifah': 'Umar'
    },
    {
      'question': 'Apa sistem yang dibuat Umar?',
      'options': ['Pajak', 'Kalender Hijriyah', 'Bank', 'Sekolah'],
      'answer': 1,
      'khalifah': 'Umar'
    },
    {
      'question': 'Wilayah meluas saat Umar?',
      'options': ['Mekkah', 'Persia & Romawi', 'Madinah', 'Yaman'],
      'answer': 1,
      'khalifah': 'Umar'
    },

    // Utsman
    {
      'question': 'Siapa khalifah ketiga?',
      'options': ['Ali', 'Umar', 'Utsman', 'Abu Bakar'],
      'answer': 2,
      'khalifah': 'Utsman'
    },
    {
      'question': 'Gelar Utsman?',
      'options': ['As-Siddiq', 'Al-Faruq', 'Dzun Nurain', 'Al-Amin'],
      'answer': 2,
      'khalifah': 'Utsman'
    },
    {
      'question': 'Jasa besar Utsman?',
      'options': ['Perang', 'Kodifikasi Al-Quran', 'Ekonomi', 'Hukum'],
      'answer': 1,
      'khalifah': 'Utsman'
    },
    {
      'question': 'Sifat Utsman?',
      'options': ['Keras', 'Pemalu', 'Kasih sayang', 'Pendiam'],
      'answer': 1,
      'khalifah': 'Utsman'
    },
    {
      'question': 'Utsman wafat karena?',
      'options': ['Sakit', 'Dibunuh', 'Perang', 'Tua'],
      'answer': 1,
      'khalifah': 'Utsman'
    },

    // Ali
    {
      'question': 'Siapa khalifah keempat?',
      'options': ['Ali', 'Umar', 'Utsman', 'Abu Bakar'],
      'answer': 0,
      'khalifah': 'Ali'
    },
    {
      'question': 'Keistimewaan Ali?',
      'options': ['Kaya', 'Cerdas & berani', 'Pemalu', 'Tua'],
      'answer': 1,
      'khalifah': 'Ali'
    },
    {
      'question': 'Ali adalah?',
      'options': ['Paman Nabi', 'Sepupu & menantu Nabi', 'Sahabat biasa', 'Guru'],
      'answer': 1,
      'khalifah': 'Ali'
    },
    {
      'question': 'Masa Ali ditandai?',
      'options': ['Damai', 'Konflik internal', 'Ekspansi', 'Ekonomi'],
      'answer': 1,
      'khalifah': 'Ali'
    },
    {
      'question': 'Ali wafat karena?',
      'options': ['Sakit', 'Dibunuh', 'Perang', 'Tua'],
      'answer': 1,
      'khalifah': 'Ali'
    },
  ];

  List<Map<String, dynamic>> filteredQuestions = [];

  @override
  void initState() {
    super.initState();
    loadQuestionsByKhalifah(widget.materiId);
    startTimer();
  }

  void loadQuestionsByKhalifah(String khalifah) {
    filteredQuestions =
        questions.where((q) => q['khalifah'] == khalifah).toList();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    if (currentQuestion < filteredQuestions.length - 1) {
      setState(() {
        currentQuestion++;
        timeLeft = 30;
      });
    } else {
      timer?.cancel();
      showResult();
    }
  }

  void checkAnswer(int index) {
    if (index == filteredQuestions[currentQuestion]['answer']) {
      score += 10;
      correctAnswer++;
    }
    nextQuestion();
  }

  void showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hasil Quiz'),
        content: Text('Score: $score\nBenar: $correctAnswer'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = filteredQuestions[currentQuestion];

    return Scaffold(
      appBar: AppBar(title: Text(widget.materiId)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentQuestion + 1) / filteredQuestions.length,
            ),
            const SizedBox(height: 20),
            Text(question['question']),
            const SizedBox(height: 20),
            ...List.generate(4, (index) {
              return ElevatedButton(
                onPressed: () => checkAnswer(index),
                child: Text(question['options'][index]),
              );
            }),
            const Spacer(),
            Text('Waktu: $timeLeft detik')
          ],
        ),
      ),
    );
  }
}
