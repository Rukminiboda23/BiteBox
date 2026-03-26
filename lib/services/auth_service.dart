import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // 1. Sign In
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  // 2. Sign Up (THIS WAS MISSING)
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Create user document in Firestore with default role 'customer'
      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'role': 'customer', 
        'uid': result.user!.uid,
      });

      return result.user;
    } catch (e) {
      print("Error signing up: $e");
      return null;
    }
  }

  // 3. Check if Admin
  Future<bool> isAdmin() async {
    User? user = _auth.currentUser;
    if (user == null) return false;

    DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists && doc['role'] == 'admin') {
      return true;
    }
    return false;
  }

  // 4. Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}