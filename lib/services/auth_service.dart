import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign Up Function
  Future<User?> signUp(String email, String password, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    
      // Save the user role to Firestore
      await _db.collection('users').doc(result.user!.uid).set({
        'email': email,
        'role': role,
      });

    return result.user;
  } on FirebaseAuthException catch (e) {
    // This sends the specific Firebase error message back to your screen
    throw e.message ?? "An unknown error occurred.";
  } catch (e) {
    throw "An unexpected error occurred.";
  }
}
  // Login Function
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // Get User Role from Firestore
  Future<String?> getUserRole(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    return doc['role'];
  }
}