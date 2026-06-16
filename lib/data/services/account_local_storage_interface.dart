import '../../core/typedefs/types_defs.dart';
import '../../domain/models/account_entity.dart';

abstract interface class IAccountLocalStorage {
  Future<ListAccountResult> getAccounts();
  Future<VoidResult> saveAccount(Account account);
  Future<VoidResult> updateAccount(Account account);
  Future<VoidResult> deleteAccount(String id);
}
