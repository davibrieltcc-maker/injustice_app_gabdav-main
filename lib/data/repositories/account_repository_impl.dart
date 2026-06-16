import '../../core/typedefs/types_defs.dart';
import 'account_repository_interface.dart';
import '../services/account_local_storage_interface.dart';
import '../../domain/models/account_entity.dart';

final class AccountRepositoryImpl implements IAccountRepository {
  final IAccountLocalStorage _localStorage;

  AccountRepositoryImpl({required IAccountLocalStorage localStorage})
      : _localStorage = localStorage;

  @override
  Future<ListAccountResult> getAccounts() => _localStorage.getAccounts();

  @override
  Future<VoidResult> saveAccount(Account account) =>
      _localStorage.saveAccount(account);

  @override
  Future<VoidResult> updateAccount(Account account) =>
      _localStorage.updateAccount(account);

  @override
  Future<VoidResult> deleteAccount(String id) =>
      _localStorage.deleteAccount(id);
}
