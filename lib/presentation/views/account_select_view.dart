import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/account_entity.dart';
import '../controllers/account_viewmodel.dart';
import '../functions/ui_functions.dart';
import '../widgets/loading_indicator.dart';

class AccountSelectView extends StatefulWidget {
  const AccountSelectView({super.key});

  @override
  State<AccountSelectView> createState() => _AccountSelectViewState();
}

class _AccountSelectViewState extends State<AccountSelectView> {
  late final AccountViewModel _vmAccount;
  late final void Function() _disposeErrorEffect;

  @override
  void initState() {
    super.initState();
    _vmAccount = injector.get<AccountViewModel>();
    _vmAccount.commands.clearSelectedAccount();
    _loadAndRestoreSession();

    _disposeErrorEffect = effect(() {
      final msg = _vmAccount.accountState.message.value;
      if (msg != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showSnackBar(context, msg, backgroundColor: Colors.red);
          _vmAccount.accountState.clearMessage();
        });
      }
    });
  }

  @override
  void dispose() {
    _disposeErrorEffect();
    super.dispose();
  }

  Future<void> _loadAndRestoreSession() async {
    await _vmAccount.commands.fetchAccounts();
    if (!mounted) return;

    final savedId =
        await _vmAccount.sessionStorage.getSelectedAccountId();
    if (savedId == null || !mounted) return;

    final accounts = _vmAccount.accountState.accounts.value;
    final saved = accounts.where((a) => a.id == savedId).firstOrNull;
    if (saved != null && mounted) {
      _vmAccount.commands.selectAccount(saved);
      context.goNamed(AppRouteNames.home);
    }
  }

  Future<void> _selectAccount(Account account) async {
    _vmAccount.commands.selectAccount(account);
    await _vmAccount.sessionStorage.saveSelectedAccountId(account.id);
    if (mounted) context.goNamed(AppRouteNames.home);
  }

  void _addProfile() {
    _vmAccount.commands.clearSelectedAccount();
    context.goNamed(AppRouteNames.accountCreate);
  }

  Future<void> _deleteAccount(Account account) async {
    final confirm = await confirmDialog(
      context,
      title: 'Excluir perfil',
      message:
          'Tem certeza que deseja excluir o perfil "${account.displayName}"?\n\n'
          'Esta ação não poderá ser desfeita.',
      confirmText: 'EXCLUIR',
    );
    if (!confirm) return;
    await _vmAccount.commands.deleteAccount(account.id);
    await _vmAccount.sessionStorage.clearSelectedAccountId();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Watch((context) {
          final isLoading =
              _vmAccount.commands.getAccountsCommand.isExecuting.value ||
              _vmAccount.commands.deleteAccountCommand.isExecuting.value;

          if (isLoading) {
            return const LoadingIndicator(message: 'Carregando perfis...');
          }

          final accounts = _vmAccount.accountState.accounts.value;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quem está jogando?',
                      style: context.textStyles.headlineSmall?.bold,
                    ),
                    IconButton(
                      icon: const Icon(Icons.manage_accounts_outlined),
                      tooltip: 'Meu Perfil',
                      onPressed: () => context.goNamed(AppRouteNames.profile),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: accounts.isEmpty
                    ? _EmptyProfilesState(onAdd: _addProfile)
                    : _ProfileGrid(
                        accounts: accounts,
                        onSelect: _selectAccount,
                        onDelete: _deleteAccount,
                      ),
              ),
              if (accounts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: OutlinedButton.icon(
                    onPressed: _addProfile,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Perfil'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      foregroundColor: colorScheme.secondary,
                      side: BorderSide(
                        color: colorScheme.secondary.withValues(alpha: 0.6),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _ProfileGrid extends StatelessWidget {
  final List<Account> accounts;
  final Future<void> Function(Account) onSelect;
  final void Function(Account) onDelete;

  const _ProfileGrid({
    required this.accounts,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        mainAxisExtent: 160,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        return _ProfileTile(
          account: accounts[index],
          onTap: () => onSelect(accounts[index]),
          onDelete: () => onDelete(accounts[index]),
        );
      },
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final Account account;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProfileTile({
    required this.account,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = account.displayName.isNotEmpty
        ? account.displayName[0].toUpperCase()
        : '?';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: colorScheme.secondary,
              child: Text(
                initial,
                style: context.textStyles.headlineMedium?.bold.withColor(
                  colorScheme.onSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                account.displayName,
                style: context.textStyles.titleSmall?.semiBold,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Nv. ${account.level}',
              style: context.textStyles.bodySmall?.withColor(
                colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProfilesState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyProfilesState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 80,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Nenhum perfil encontrado',
              style: context.textStyles.titleLarge?.semiBold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Crie um perfil para começar a jogar',
              style: context.textStyles.bodyMedium?.withColor(
                colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Criar Perfil'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
