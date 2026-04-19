import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AppColors {
  static const Color emerald = Color(0xFF0D9373);
  static const Color emeraldDark = Color(0xFF065F46);
  static const Color gold = Color(0xFFF59E0B);
  static const Color cream = Color(0xFFF5F7FB); // 🔥 ubah jadi light modern
  static const Color textDark = Color(0xFF1F2937);
}

class MateriPage extends StatefulWidget {
  const MateriPage({super.key});

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  late YoutubePlayerController controller;

  String currentVideoId = "Y8flRf3LQhY";

  @override
  void initState() {
    super.initState();
    controller = YoutubePlayerController(
      initialVideoId: currentVideoId,
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
  }

  void changeVideo(String videoId) {
    controller.load(videoId);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget materiButton(String title, String videoId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF58CC02),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 3,
          ),
          onPressed: () => changeVideo(videoId),
          child: Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget expandableMateri({
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
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
      child: ExpansionTile(
        tilePadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(height: 1.5),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Materi Khulafaur Rasyidin",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 🔥 VIDEO CARD
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: YoutubePlayer(
                controller: controller,
                showVideoProgressIndicator: true,
              ),
            ),
          ),

          // 🔥 SCROLL
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Pilih Video",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 10),

                  materiButton("Abu Bakar", "Y8flRf3LQhY"),
                  materiButton("Umar (1)", "EuQTKmhAZ5g"),
                  materiButton("Umar (2)", "x1WNxM8bDls"),
                  materiButton("Utsman", "FP5s6qFwHS0"),
                  materiButton("Ali", "tvRVgwQ82oo"),

                  const SizedBox(height: 20),

                  expandableMateri(
                    title: "Pengertian Khulafaur Rasyidin",
                    content:
                    "Khulafaur Rasyidin adalah para khalifah pengganti Rasulullah SAW yang memimpin umat Islam setelah wafatnya beliau. Mereka memimpin dengan adil, bijaksana, dan berpedoman pada Al-Qur’an dan Hadis.",
                  ),

                  expandableMateri(
                    title: "Abu Bakar Ash-Shiddiq",
                    content:
                    "Abu Bakar adalah khalifah pertama dan sahabat terdekat Rasulullah.\n\n"
                        "Bidang Agama:\n"
                        "- Memerangi kaum murtad\n"
                        "- Menghadapi nabi palsu\n"
                        "- Mengumpulkan Al-Qur’an\n\n"
                        "Bidang Politik:\n"
                        "- Menyatukan umat Islam\n"
                        "- Mengangkat gubernur\n\n"
                        "Bidang Militer:\n"
                        "- Mengirim pasukan ke Syam\n"
                        "- Ekspansi wilayah Islam",
                  ),

                  expandableMateri(
                    title: "Umar Bin Khattab",
                    content:
                    "Umar dikenal sebagai pemimpin yang tegas dan adil.\n\n"
                        "Bidang Pemerintahan:\n"
                        "- Membentuk sistem administrasi\n"
                        "- Membuat kalender Hijriah\n\n"
                        "Bidang Hukum:\n"
                        "- Menegakkan keadilan\n\n"
                        "Bidang Militer:\n"
                        "- Memperluas wilayah Islam",
                  ),

                  expandableMateri(
                    title: "Utsman Bin Affan",
                    content:
                    "Utsman adalah khalifah ketiga.\n\n"
                        "Bidang Agama:\n"
                        "- Kodifikasi Al-Qur’an\n\n"
                        "Bidang Militer:\n"
                        "- Membentuk angkatan laut\n\n"
                        "Bidang Infrastruktur:\n"
                        "- Membangun fasilitas umum",
                  ),

                  expandableMateri(
                    title: "Ali Bin Abi Thalib",
                    content:
                    "Ali adalah khalifah keempat.\n\n"
                        "Bidang Ilmu:\n"
                        "- Mengembangkan ilmu bahasa Arab\n\n"
                        "Bidang Pemerintahan:\n"
                        "- Reformasi administrasi\n\n"
                        "Bidang Sosial:\n"
                        "- Menjaga persatuan umat",
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}