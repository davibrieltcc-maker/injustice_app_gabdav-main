import '../../core/typedefs/types_defs.dart';
import 'account_facade_usecases_interface.dart';
import '../usecases/account_usecases_interfaces.dart';

final class AccountFacadeUsecasesImpl implements IAccountFacadeUseCases {
  final IGetAccountsUseCase _getAccountsUseCase;
  final ISaveAccountUseCase _saveAccountUseCase;
  final IUpdateAccountUseCase _updateAccountUseCase;
  final IDeleteAccountUseCase _deleteAccountUseCase;

  AccountFacadeUsecasesImpl({
    required IGetAccountsUseCase getAccountsUseCase,
    required ISaveAccountUseCase saveAccountUseCase,
    required IUpdateAccountUseCase updateAccountUseCase,
    required IDeleteAccountUseCase deleteAccountUseCase,
  }) : _getAccountsUseCase = getAccountsUseCase,
       _saveAccountUseCase = saveAccountUseCase,
       _updateAccountUseCase = updateAccountUseCase,
       _deleteAccountUseCase = deleteAccountUseCase;

  @override
  Future<ListAccountResult> getAccounts(NoParams params) =>
      _getAccountsUseCase(params);

  @override
  Future<VoidResult> saveAccount(AccountParams params) =>
      _saveAccountUseCase(params);

  @override
  Future<VoidResult> deleteAccount(AccountIdParams params) =>
      _deleteAccountUseCase(params);

  @override
  Future<VoidResult> updateAccount(AccountParams params) =>
      _updateAccountUseCase(params);
}
