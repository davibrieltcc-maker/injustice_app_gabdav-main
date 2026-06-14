import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service_interface.dart';

class FirebaseAuthServiceImpl implements IAuthService {
  FirebaseAuthServiceImpl({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.updateDisplayName(displayName.trim());
    await credential.user?.reload();
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    final user = _requireUser();
    await user.updateDisplayName(displayName.trim());
    await user.reload();
  }

  @override
  Future<void> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    final user = _requireUser();
    await _reauthenticate(user, currentPassword);
    await user.updateEmail(newEmail.trim());
    await user.reload();
  }

  @override
  Future<void> updatePassword({
    required String newPassword,
    required String currentPassword,
  }) async {
    final user = _requireUser();
    await _reauthenticate(user, currentPassword);
    await user.updatePassword(newPassword);
    await user.reload();
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  User _requireUser() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Nenhum usuário autenticado.',
      );
    }
    return user;
  }

  Future<void> _reauthenticate(User user, String currentPassword) async {
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
  }
}
