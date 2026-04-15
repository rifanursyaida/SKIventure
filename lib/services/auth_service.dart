import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔥 REGISTER (DEFAULT = TEACHER)
  Future<String?> register(
      String email,
      String password,
      String name,
      ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) return "User gagal dibuat";

      // Simpan ke Firestore
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': 'teacher', // 🔥 penting
        'created_at': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // 🔥 LOGIN
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // 🔥 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 🔥 GET CURRENT USER
  User? get currentUser => _auth.currentUser;

  // 🔥 GET ROLE USER
  Future<String?> getUserRole() async {
    try {
      final user = _auth.currentUser;

      if (user == null) return null;

      final doc = await _db.collection('users').doc(user.uid).get();

      if (!doc.exists) return null;

      return doc.data()?['role'];
    } catch (e) {
      return null;
    }
  }

  // 🔥 CEK APAKAH TEACHER
  Future<bool> isTeacher() async {
    final role = await getUserRole();
    return role == 'teacher';
  }
}