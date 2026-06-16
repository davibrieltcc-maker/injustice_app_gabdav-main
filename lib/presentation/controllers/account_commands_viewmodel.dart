import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../domain/models/account_entity.dart';
import '../commands/account_commands.dart';
import 'account_state_viewmodel.dart';
import 'package:signals_flutter/signals_flutter.dart';

class AccountCommandsViewmodel {
  final AccountStateViewModel state;
  final GetAccountsCommand _getAccountsCommand;
  final SaveAccountCommand _saveAccountCommand;
  final UpdateAccountCommand _updateAccountCommand;
  final DeleteAccountCommand _deleteAccountCommand;

  AccountCommandsViewmodel({
    required this.state,
    required GetAccountsCommand getAccountsCommand,
    required SaveAccountCommand saveAccountCommand,
    required UpdateAccountCommand updateAccountCommand,
    required DeleteAccountCommand deleteAccountCommand,
  }) : _getAccountsCommand = getAccountsCommand,
       _saveAccountCommand = saveAccountCommand,
       _updateAccountCommand = updateAccountCommand,
       _deleteAccountCommand = deleteAccountCommand {
    _observeGetAccounts();
    _observeDeleteAccount();
    _observeSaveAccount();
    _observeUpdateAccount();
  }

  GetAccountsCommand get getAccountsCommand => _getAccountsCommand;
  SaveAccountCommand get saveAccountCommand => _saveAccountCommand;
  UpdateAccountCommand get updateAccountCommand => _updateAccountCommand;
  DeleteAccountCommand get deleteAccountCommand => _deleteAccountCommand;

  void _observeCommand<T>(
    Command<T, Failure> command, {
    required void Function(T data) onSuccess,
    void Function(Failure err)? onFailure,
  }) {
    effect(() {
      if (command.isExecuting.value) return;
      final result = command.result.value;
      if (result == null) return;

      result.fold(
        onSuccess: (data) {
          state.clearMessage();
          onSuccess(data);
          command.clear();
        },
        onFailure: (err) {
          state.setMessage(err.msg);
          if (onFailure != null) onFailure(err);
          command.clear();
        },
      );
    });
  }

  void _observeGetAccounts() {
    _observeCommand<List<Account>>(
      _getAccountsCommand,
      onSuccess: (accounts) => state.setAccounts(accounts),
      onFailure: (_) => state.setAccounts([]),
    );
  }

  void _observeDeleteAccount() {
    _observeCommand<void>(
      _deleteAccountCommand,
      onSuccess: (_) {
        // Limpa a seleção; AccountSelectView recarrega a lista ao montar
        state.setAccount(null);
        state.successEvent.value = AccountSuccessEvent.deleted;
      },
      onFailure: (err) => state.setMessage(err.msg),
    );
  }

  void _observeSaveAccount() {
    _observeCommand<void>(
      _saveAccountCommand,
      onSuccess: (_) {
        // A lista será recarregada quando AccountSelectView montar
        state.successEvent.value = AccountSuccessEvent.created;
      },
      onFailure: (err) => state.setMessage(err.msg),
    );
  }

  void _observeUpdateAccount() {
    _observeCommand<void>(
      _updateAccountCommand,
      onSuccess: (_) {
        // Atualiza apenas a conta selecionada (sem ler accounts no mesmo effect)
        final updated = _updateAccountCommand.parameter?.account;
        if (updated != null) {
          state.setAccount(updated);
        }
        state.successEvent.value = AccountSuccessEvent.updated;
      },
      onFailure: (err) => state.setMessage(err.msg),
    );
  }

  Future<void> fetchAccounts() async {
    state.clearMessage();
    await _getAccountsCommand.executeWith(());
  }

  Future<void> deleteAccount(String id) async {
    state.clearMessage();
    await _deleteAccountCommand.executeWith((id: id));
  }

  Future<void> saveAccount(Account account) async {
    await _saveAccountCommand.executeWith((account: account));
  }

  Future<void> updateAccount(Account account) async {
    await _updateAccountCommand.executeWith((account: account));
  }

  void selectAccount(Account account) {
    state.setAccount(account);
  }

  void clearSelectedAccount() {
    state.setAccount(null);
  }
}
