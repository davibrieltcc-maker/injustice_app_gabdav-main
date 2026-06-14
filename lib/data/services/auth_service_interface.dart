import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthService {
  Stream<User?> get authStateChanges;

  User? get currentUser;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> updateDisplayName(String displayName);

  Future<void> updateEmail({
    required String newEmail,
    required String currentPassword,
  });

  Future<void> updatePassword({
    required String newPassword,
    required String currentPassword,
  });

  Future<void> signOut();
}
