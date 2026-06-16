import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/account_entity.dart';
import '../../domain/models/account_mapper.dart';
import 'account_local_storage_interface.dart';
import 'auth_service_interface.dart';

final class AccountFirestoreService implements IAccountLocalStorage {
  final FirebaseFirestore _firestore;
  final IAuthService _authService;

  AccountFirestoreService({
    required IAuthService authService,
    FirebaseFirestore? firestore,
  })  : _authService = authService,
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _accountsRef {
    final uid = _authService.currentUser?.uid;
    if (uid == null) throw StateError('Usuário não autenticado.');
    return _firestore.collection('users').doc(uid).collection('accounts');
  }

  @override
  Future<ListAccountResult> getAccounts() async {
    try {
      final snapshot = await _accountsRef.get();
      final accounts = snapshot.docs
          .map((doc) => AccountMapper.fromMap(doc.data()))
          .toList();
      if (accounts.isEmpty) return Error(EmptyResultFailure());
      return Success(accounts);
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao obter contas: $e'));
    }
  }

  @override
  Future<VoidResult> saveAccount(Account account) async {
    try {
      await _accountsRef.doc(account.id).set(AccountMapper.toMap(account));
      return Success(null);
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao salvar conta: $e'));
    }
  }

  @override
  Future<VoidResult> updateAccount(Account account) async {
    try {
      await _accountsRef.doc(account.id).update(AccountMapper.toMap(account));
      return Success(null);
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao atualizar conta: $e'));
    }
  }

  @override
  Future<VoidResult> deleteAccount(String id) async {
    try {
      // Deleta os personagens da subcoleção antes de deletar a conta
      final charsSnap =
          await _accountsRef.doc(id).collection('characters').get();
      for (final doc in charsSnap.docs) {
        await doc.reference.delete();
      }
      await _accountsRef.doc(id).delete();
      return Success(null);
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao deletar conta: $e'));
    }
  }
}
