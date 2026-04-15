import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔥 CREATE
  Future<String?> addStudent(String name, String email) async {
    try {
      final user = _auth.currentUser;

      if (user == null) return "User tidak ditemukan";

      await _firestore.collection('students').add({
        "name": name.trim(),
        "email": email.trim(),
        "createdBy": user.uid,
        "createdAt": FieldValue.serverTimestamp(),
      });

      return null; // sukses
    } catch (e) {
      return e.toString();
    }
  }

  // 🔥 READ (STREAM - REALTIME)
  Stream<QuerySnapshot> getStudents() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('students')
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 🔥 UPDATE
  Future<String?> updateStudent(
      String id,
      String name,
      String email,
      ) async {
    try {
      await _firestore.collection('students').doc(id).update({
        "name": name.trim(),
        "email": email.trim(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // 🔥 DELETE
  Future<String?> deleteStudent(String id) async {
    try {
      await _firestore.collection('students').doc(id).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}