import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorMessages {
  AuthErrorMessages._();

  static String fromFirebaseAuthException(FirebaseAuthException exception) {
    return switch (exception.code) {
      'weak-password' =>
        'Senha fraca. Use ao menos 6 caracteres com letras, números e símbolos.',
      'email-already-in-use' => 'Este e-mail já está cadastrado.',
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' ||
      'invalid-email' =>
        'E-mail ou senha incorretos.',
      'too-many-requests' =>
        'Muitas tentativas. Aguarde alguns minutos e tente novamente.',
      'requires-recent-login' =>
        'Por segurança, confirme sua senha atual e tente novamente.',
      'operation-not-allowed' =>
        'Login com e-mail e senha não está habilitado no Firebase.',
      _ => exception.message ?? 'Não foi possível concluir a operação.',
    };
  }
}
