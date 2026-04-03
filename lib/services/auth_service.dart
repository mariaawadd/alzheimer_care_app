import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign Up Function
  Future<User?> signUp(String email, String password, String role, String language) async {
    try {
      // 1. Create the user in Firebase Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, 
          password: password
      );
    
      // 2. Save the user details to Firestore
      // We are adding 'language' and 'status' for your research goals
      await _db.collection('users').doc(result.user!.uid).set({
        'email': email,
        'role': role,
        'language': language,      // 'English' or 'Egyptian Arabic'
        'status': 'Normal',        // Default status for sensors
        'lastMovement': DateTime.now(), // Timestamp for activity monitoring
        'linkedUser': null,        // Placeholder for Caregiver/Patient connection
      });

      return result.user;
    } on FirebaseAuthException catch (e) {
      // Passes specific Firebase errors (e.g., "Email already in use") to the UI
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
  // Sign Out Method
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get User Role from Firestore
  Future<String?> getUserRole(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    return doc['role'];
  }
}