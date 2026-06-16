import '../../domain/models/account_entity.dart';
import 'package:signals_flutter/signals_flutter.dart';

enum AccountSuccessEvent { created, updated, deleted }

class AccountStateViewModel {
  /// Lista de todas as contas do usuário logado
  final accounts = Signal<List<Account>>([]);

  /// Conta selecionada no momento (perfil ativo)
  final selectedAccount = Signal<Account?>(null);

  /// Alias para compatibilidade — aponta para a conta selecionada
  ReadonlySignal<Account?> get state => selectedAccount.readonly();

  final message = signal<String?>(null);
  final successEvent = signal<AccountSuccessEvent?>(null);

  late final hasAccount = computed(() => selectedAccount.value != null);
  late final hasAccounts = computed(() => accounts.value.isNotEmpty);
  late final isEditing = computed(() => hasAccount.value);
  late final canDelete = computed(() => isEditing.value);

  late final title = computed(
    () => isEditing.value ? 'Editar Conta' : 'Criar Conta',
  );

  late final labelEditMode = computed(
    () => isEditing.value ? 'SALVAR' : 'CRIAR',
  );

  void setAccounts(List<Account> newAccounts) => accounts.value = newAccounts;

  void setAccount(Account? account) => selectedAccount.value = account;

  void clearMessage() => message.value = null;

  void setMessage(String msg) => message.value = msg;

  void clearSuccessEvent() => successEvent.value = null;
}
