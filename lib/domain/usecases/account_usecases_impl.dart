import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/account_repository_interface.dart';
import 'account_usecases_interfaces.dart';

final class GetAccountsUseCaseImpl implements IGetAccountsUseCase {
  final IAccountRepository _repository;

  GetAccountsUseCaseImpl({required IAccountRepository repository})
      : _repository = repository;

  @override
  Future<ListAccountResult> call(NoParams params) => _repository.getAccounts();
}

final class SaveAccountUseCaseImpl implements ISaveAccountUseCase {
  final IAccountRepository _repository;

  SaveAccountUseCaseImpl({required IAccountRepository repository})
      : _repository = repository;

  @override
  Future<VoidResult> call(AccountParams params) async {
    await Future.delayed(const Duration(seconds: 1));
    return _repository.saveAccount(params.account);
  }
}

final class DeleteAccountUseCaseImpl implements IDeleteAccountUseCase {
  final IAccountRepository _repository;

  DeleteAccountUseCaseImpl({required IAccountRepository repository})
      : _repository = repository;

  @override
  Future<VoidResult> call(AccountIdParams params) async {
    await Future.delayed(const Duration(seconds: 1));
    return _repository.deleteAccount(params.id);
  }
}

final class UpdateAccountUseCaseImpl implements IUpdateAccountUseCase {
  final IAccountRepository _repository;

  UpdateAccountUseCaseImpl({required IAccountRepository repository})
      : _repository = repository;

  @override
  Future<VoidResult> call(AccountParams params) async {
    await Future.delayed(const Duration(seconds: 1));
    return _repository.updateAccount(params.account);
  }
}
