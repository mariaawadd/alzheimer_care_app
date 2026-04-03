import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- SIGN UP ---
  Future<User?> signUp(String email, String password, String role, String language) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _db.collection('users').doc(result.user!.uid).set({
        'email': email,
        'role': role,
        'language': language,
        'linkedUser': null,
        'status': 'Normal',
        'lastMovement': DateTime.now(),
      });

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Error";
    }
  }

  // --- LOGIN ---
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.currentUser != null 
          ? await _auth.signInWithEmailAndPassword(email: email, password: password)
          : await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      throw e.toString();
    }
  }

  // --- SIGN OUT ---
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- LINK BY EMAIL (Fixed Syntax) ---
  Future<String> linkByEmail(String patientEmail) async {
    try {
      var query = await _db
          .collection('users')
          .where('email', isEqualTo: patientEmail.trim())
          .where('role', isEqualTo: 'Patient')
          .get();

      if (query.docs.isEmpty) {
        return "link_not_found";
      }

      String patientId = query.docs.first.id;
      String caregiverId = _auth.currentUser!.uid;

      // 2. Silently link them in the background
      await _db.collection('users').doc(caregiverId).update({
        'linkedUser': patientId,
      });
      await _db.collection('users').doc(patientId).update({
        'linkedUser': caregiverId,
      });

      return "link_success";
    } catch (e) {
      return "link_error";
    }
  }
  Future<String?> getUserRole(String uid) async {
    try {
     DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.get('role') as String?;
      }
      return null;
    } catch (e) {
      return null;
  }
}

}