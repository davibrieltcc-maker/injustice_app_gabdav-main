import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/account_facade_usecases_interface.dart';
import '../../domain/models/account_entity.dart';

final class GetAccountsCommand
    extends ParameterizedCommand<List<Account>, Failure, NoParams> {
  final IAccountFacadeUseCases _accountFacadeUseCases;

  GetAccountsCommand(this._accountFacadeUseCases);

  @override
  Future<ListAccountResult> execute() async {
    return await _accountFacadeUseCases.getAccounts(());
  }
}

final class SaveAccountCommand
    extends ParameterizedCommand<void, Failure, AccountParams> {
  final IAccountFacadeUseCases _accountFacadeUseCases;

  SaveAccountCommand(this._accountFacadeUseCases);

  @override
  Future<VoidResult> execute() async {
    if (parameter == null) {
      return Error(InputFailure('Parametro nulo para criar conta.'));
    }
    return await _accountFacadeUseCases.saveAccount(parameter!);
  }
}

final class UpdateAccountCommand
    extends ParameterizedCommand<void, Failure, AccountParams> {
  final IAccountFacadeUseCases _accountFacadeUseCases;

  UpdateAccountCommand(this._accountFacadeUseCases);

  @override
  Future<VoidResult> execute() async {
    if (parameter == null) {
      return Error(InputFailure('Parametro nulo para atualizar conta.'));
    }
    return await _accountFacadeUseCases.updateAccount(parameter!);
  }
}

final class DeleteAccountCommand
    extends ParameterizedCommand<void, Failure, AccountIdParams> {
  final IAccountFacadeUseCases _accountFacadeUseCases;

  DeleteAccountCommand(this._accountFacadeUseCases);

  @override
  Future<VoidResult> execute() async {
    if (parameter == null) {
      return Error(InputFailure('Parametro nulo para deletar conta.'));
    }
    return await _accountFacadeUseCases.deleteAccount(parameter!);
  }
}
