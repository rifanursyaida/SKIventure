import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'add_materi_page.dart';

class AppColors {
  static const Color emerald = Color(0xFF0D9373);
  static const Color emeraldDark = Color(0xFF065F46);
  static const Color gold = Color(0xFFF59E0B);
  static const Color cream = Color(0xFFFFFBF0);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textMedium = Color(0xFF374151);
}

class MateriPage extends StatefulWidget {
  const MateriPage({super.key});

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  String? role;
  bool isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    loadRole();
  }

  void loadRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() => isLoadingRole = false);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        role = doc.data()?['role'];
        isLoadingRole = false;
      });
    } catch (e) {
      setState(() => isLoadingRole = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text("Materi SKI"),
        backgroundColor: AppColors.emeraldDark,
      ),

      // 🔥 FAB hanya teacher
      floatingActionButton: (!isLoadingRole && role == 'teacher')
          ? FloatingActionButton(
        backgroundColor: AppColors.gold,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddMateriPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,

      body: isLoadingRole
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('materi')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Terjadi kesalahan"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text("Belum ada materi"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return _materiCard(context, docs[index]);
            },
          );
        },
      ),
    );
  }

  Widget _materiCard(BuildContext context, QueryDocumentSnapshot data) {
    final title = data['title'] ?? '';
    final subtitle = data['subtitle'] ?? '';
    final videoId = data['videoId'] ?? '';
    final description = data['description'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎥 Thumbnail
          GestureDetector(
            onTap: videoId.isNotEmpty
                ? () => _openPlayer(context, videoId, title)
                : null,
            child: ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Image.network(
                    videoId.isNotEmpty
                        ? 'https://img.youtube.com/vi/$videoId/mqdefault.jpg'
                        : 'https://via.placeholder.com/300x180',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  if (videoId.isNotEmpty)
                    const Positioned.fill(
                      child: Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 📄 Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textMedium),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _openPlayer(BuildContext context, String videoId, String title) {
    showDialog(
      context: context,
      builder: (_) => _VideoDialog(videoId: videoId, title: title),
    );
  }
}

class _VideoDialog extends StatefulWidget {
  final String videoId;
  final String title;

  const _VideoDialog({
    required this.videoId,
    required this.title,
  });

  @override
  State<_VideoDialog> createState() => _VideoDialogState();
}

class _VideoDialogState extends State<_VideoDialog> {
  late YoutubePlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(autoPlay: true),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title: Text(widget.title),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          YoutubePlayer(controller: controller),
        ],
      ),
    );
  }
}