import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign Up Function
  Future<User?> signUp(String email, String password, String role) async {
    try {
      // 1. Create the account in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      // 2. Save the User Role (Caregiver/Patient) in Firestore
      await _db.collection('users').doc(user!.uid).set({
        'uid': user.uid,
        'email': email,
        'role': role,
        'createdAt': DateTime.now(),
      });

      return user;
    } catch (e) {
      print("Error during signup: ${e.toString()}");
      return null;
    }
  }
}