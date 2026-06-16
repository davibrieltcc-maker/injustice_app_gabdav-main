import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service_interface.dart';
import 'session_storage_interface.dart';

final class SessionFirestoreService implements ISessionStorage {
  final FirebaseFirestore _firestore;
  final IAuthService _authService;

  SessionFirestoreService({
    required IAuthService authService,
    FirebaseFirestore? firestore,
  })  : _authService = authService,
        _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _userDoc {
    final uid = _authService.currentUser?.uid;
    if (uid == null) throw StateError('Usuário não autenticado.');
    return _firestore.collection('users').doc(uid);
  }

  @override
  Future<String?> getSelectedAccountId() async {
    final doc = await _userDoc.get();
    return doc.data()?['selectedAccountId'] as String?;
  }

  @override
  Future<void> saveSelectedAccountId(String id) async {
    await _userDoc.set({'selectedAccountId': id}, SetOptions(merge: true));
  }

  @override
  Future<void> clearSelectedAccountId() async {
    await _userDoc.update({'selectedAccountId': FieldValue.delete()});
  }
}
