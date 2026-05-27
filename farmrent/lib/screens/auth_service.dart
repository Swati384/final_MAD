import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  User? get user => _user;

  AuthService() {
    _auth.authStateChanges().listen((User? u) {
      _user = u;
      notifyListeners();
    });
  }

  /// 🔽 COPY AND REPLACE THIS ENTIRE METHOD INSIDE YOUR FILE 🔽
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      // 1. Create account inside Firebase Authentication core
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Build profile entry inside your live Cloud Firestore 'users' collection
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'address': 'Not set',
          'profileUrl': null,
          'borrowerRating': 5.0,
          'lenderRating': 5.0,
          'walletBalance': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Login System Engine Route
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign Out Route
  Future<void> signOut() async {
    await _auth.signOut();
  }
}