import '../../data/services/session_storage_interface.dart';
import '../../domain/facades/account_facade_usecases_interface.dart';
import '../commands/account_commands.dart';
import 'account_commands_viewmodel.dart';
import 'account_state_viewmodel.dart';

class AccountViewModel {
  late final AccountStateViewModel _state;

  AccountStateViewModel get accountState => _state;

  late final AccountCommandsViewmodel commands;

  final ISessionStorage sessionStorage;

  AccountViewModel(IAccountFacadeUseCases facade, this.sessionStorage) {
    _state = AccountStateViewModel();
    commands = AccountCommandsViewmodel(
      state: _state,
      getAccountsCommand: GetAccountsCommand(facade),
      saveAccountCommand: SaveAccountCommand(facade),
      updateAccountCommand: UpdateAccountCommand(facade),
      deleteAccountCommand: DeleteAccountCommand(facade),
    );
  }

  GetAccountsCommand get getAccountsCommand => commands.getAccountsCommand;
  SaveAccountCommand get saveAccountCommand => commands.saveAccountCommand;
  DeleteAccountCommand get deleteAccountCommand => commands.deleteAccountCommand;
  UpdateAccountCommand get updateAccountCommand => commands.updateAccountCommand;
}
