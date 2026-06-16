import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/character_entity.dart';
import '../../domain/models/character_mapper.dart';
import 'auth_service_interface.dart';
import 'character_local_storage_interface.dart';

final class CharacterFirestoreService implements ICharacterLocalStorage {
  final FirebaseFirestore _firestore;
  final IAuthService _authService;
  String? _activeAccountId;

  CharacterFirestoreService({
    required IAuthService authService,
    FirebaseFirestore? firestore,
  })  : _authService = authService,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  void setActiveAccount(String? accountId) => _activeAccountId = accountId;

  CollectionReference<Map<String, dynamic>> get _charsRef {
    final uid = _authService.currentUser?.uid;
    if (uid == null) throw StateError('Usuário não autenticado.');
    final accountId = _activeAccountId;
    if (accountId == null) throw StateError('Nenhuma conta ativa definida.');
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('accounts')
        .doc(accountId)
        .collection('characters');
  }

  @override
  Future<ListCharacterResult> getAllCharacters() async {
    try {
      final snapshot = await _charsRef.get();
      final characters = snapshot.docs
          .map((doc) => CharacterMapper.fromMap(doc.data()))
          .toList();
      if (characters.isEmpty) return Error(EmptyResultFailure());
      return Success(characters);
    } catch (e) {
      return Error(
        ApiLocalFailure('Firestore - Erro ao obter personagens: $e'),
      );
    }
  }

  @override
  Future<CharacterResult> getCharacterById(String id) async {
    try {
      final doc = await _charsRef.doc(id).get();
      if (!doc.exists || doc.data() == null) {
        return Error(DefaultFailure('Personagem não encontrado.'));
      }
      return Success(CharacterMapper.fromMap(doc.data()!));
    } catch (e) {
      return Error(
        ApiLocalFailure('Firestore - Erro ao obter personagem: $e'),
      );
    }
  }

  @override
  Future<CharacterResult> saveCharacter(Character character) async {
    try {
      await _charsRef.doc(character.id).set(CharacterMapper.toMap(character));
      return Success(character);
    } catch (e) {
      return Error(
        ApiLocalFailure('Firestore - Erro ao salvar personagem: $e'),
      );
    }
  }

  @override
  Future<CharacterResult> updateCharacter(Character character) async {
    try {
      await _charsRef
          .doc(character.id)
          .update(CharacterMapper.toMap(character));
      return Success(character);
    } catch (e) {
      return Error(
        ApiLocalFailure('Firestore - Erro ao atualizar personagem: $e'),
      );
    }
  }

  @override
  Future<CharacterResult> deleteCharacter(String id) async {
    try {
      final doc = await _charsRef.doc(id).get();
      if (!doc.exists || doc.data() == null) {
        return Error(DefaultFailure('Personagem não encontrado.'));
      }
      final character = CharacterMapper.fromMap(doc.data()!);
      await _charsRef.doc(id).delete();
      return Success(character);
    } catch (e) {
      return Error(
        ApiLocalFailure('Firestore - Erro ao deletar personagem: $e'),
      );
    }
  }
}
