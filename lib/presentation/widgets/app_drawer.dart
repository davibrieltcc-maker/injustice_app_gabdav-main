import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/account_viewmodel.dart';

/// Drawer reutilizável para navegação entre páginas
class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final _vmAccount = injector.get<AccountViewModel>();

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _DrawerHeader(),
          _DrawerTile(
            icon: Icons.home,
            label: 'Início',
            isSelected: currentRoute == AppPaths.home,
            onTap: () {
              context.pop();
              if (currentRoute != AppPaths.home) {
                context.goNamed(AppRouteNames.home);
              }
            },
          ),
          Watch(
            (_) => _DrawerTile(
              icon: Icons.person_add,
              label: _vmAccount.accountState.hasAccount.value
                  ? 'Editar Conta'
                  : 'Criar Conta',
              isSelected: currentRoute == AppPaths.accountCreate,
              onTap: () {
                context.pop();
                if (currentRoute != AppPaths.accountCreate) {
                  context.goNamed(AppRouteNames.accountCreate);
                }
              },
            ),
          ),
          Watch((_) {
            final hasAccount = _vmAccount.accountState.hasAccount.value;

            return _DrawerTile(
              icon: Icons.people,
              label: 'Personagens',
              isSelected: currentRoute == AppPaths.characters,
              enabled: hasAccount,
              onTap: hasAccount
                  ? () {
                      context.pop();
                      final account = _vmAccount.accountState.state.value!;
                      if (currentRoute != AppPaths.characters) {
                        context.goNamed(
                          AppRouteNames.characters,
                          extra: account,
                        );
                      }
                    }
                  : null,
            );
          }),
          _DrawerTile(
            icon: Icons.info_outline,
            label: 'Sobre',
            isSelected: currentRoute == AppPaths.about,
            onTap: () {
              context.pop();
              if (currentRoute != AppPaths.about) {
                context.goNamed(AppRouteNames.about);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final displayName = user?.displayName ?? user?.email ?? 'Jogador';
        final initial = displayName.isNotEmpty
            ? displayName[0].toUpperCase()
            : 'J';

        return DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.primaryContainer,
                colorScheme.secondary.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: colorScheme.onSecondary,
                    child: Text(
                      initial,
                      style: context.textStyles.headlineSmall?.bold.withColor(
                        colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: context.textStyles.titleMedium?.bold.withColor(
                            colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user?.email != null)
                          Text(
                            user!.email!,
                            style: context.textStyles.bodySmall?.withColor(
                              colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(
                    Icons.videogame_asset,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Injustice 2 Mobile',
                    style: context.textStyles.labelLarge?.withColor(
                      colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool enabled;
  final VoidCallback? onTap;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = colorScheme.secondary;
    final inactiveColor = enabled
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.secondary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: isSelected
              ? Border.all(
                  color: colorScheme.secondary.withValues(alpha: 0.3),
                )
              : null,
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? activeColor : inactiveColor,
          ),
          title: Text(
            label,
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          selected: isSelected,
          enabled: enabled,
          onTap: onTap,
        ),
      ),
    );
  }
}
