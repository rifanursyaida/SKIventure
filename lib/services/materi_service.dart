import 'package:cloud_firestore/cloud_firestore.dart';

class MateriService {
  final materiRef = FirebaseFirestore.instance.collection('materi');

  // 🔥 CREATE
  Future<void> addMateri({
    required String title,
    required String subtitle,
    required String videoId,
  }) async {
    await materiRef.add({
      'title': title,
      'subtitle': subtitle,
      'videoId': videoId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 🔥 READ (STREAM)
  Stream<QuerySnapshot> getMateri() {
    return materiRef.orderBy('createdAt', descending: true).snapshots();
  }

  // 🔥 UPDATE
  Future<void> updateMateri(
      String id, {
        required String title,
        required String subtitle,
        required String videoId,
      }) async {
    await materiRef.doc(id).update({
      'title': title,
      'subtitle': subtitle,
      'videoId': videoId,
    });
  }

  // 🔥 DELETE
  Future<void> deleteMateri(String id) async {
    await materiRef.doc(id).delete();
  }
}