import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/account_viewmodel.dart';
import '../widgets/animated_fade_slide.dart';
import '../widgets/app_drawer.dart';
import '../widgets/game_resource_card.dart';
import '../widgets/loading_indicator.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final AccountViewModel _vmAccount;

  @override
  void initState() {
    super.initState();
    _vmAccount = injector.get<AccountViewModel>();
    _vmAccount.commands.fetchAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Injustice 2 Mobile',
          style: context.textStyles.titleLarge?.semiBold,
        ),
        actions: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final currentUser = snapshot.data;
              if (currentUser == null) return const SizedBox.shrink();

              final displayName =
                  currentUser.displayName ?? currentUser.email ?? 'Usuário';
              final initial = displayName.isNotEmpty
                  ? displayName[0].toUpperCase()
                  : 'U';

              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.goNamed(AppRouteNames.profile),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            child: Text(
                              initial,
                              style: context.textStyles.labelSmall?.bold
                                  .withColor(
                                Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            displayName,
                            style: context.textStyles.bodySmall?.semiBold,
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Watch((context) {
        if (_vmAccount.commands.getAccountCommand.isExecuting.value) {
          return const LoadingIndicator(message: 'Carregando conta...');
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: !_vmAccount.accountState.hasAccount.value
              ? _buildAboutContent(context)
              : _accountHeaderCard(context),
        );
      }),
    );
  }

  Widget _buildAboutContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      key: const ValueKey('about'),
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedFadeSlide(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.secondary.withValues(alpha: 0.8),
                      colorScheme.tertiary.withValues(alpha: 0.6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.secondary.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.videogame_asset,
                  size: 72,
                  color: colorScheme.onSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedFadeSlide(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Bem-vindo ao Game App',
              style: context.textStyles.headlineMedium?.bold.withColor(
                colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedFadeSlide(
            delay: const Duration(milliseconds: 180),
            child: _InfoSection(
              titulo: 'Descrição',
              conteudo:
                  'Um jogo épico de RPG onde você controla heróis poderosos, '
                  'explora mundos fantásticos e enfrenta desafios emocionantes. '
                  'Personalize seus personagens, desenvolva habilidades únicas e '
                  'embarque em uma jornada inesquecível.',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedFadeSlide(
            delay: const Duration(milliseconds: 260),
            child: _InfoSection(
              titulo: 'Recursos',
              conteudo:
                  '• Sistema de combate estratégico\n'
                  '• Mais de 50 personagens únicos\n'
                  '• Mundos vastos para explorar\n'
                  '• Sistema de progressão profundo\n'
                  '• Modo multiplayer cooperativo\n'
                  '• Eventos semanais exclusivos',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AnimatedFadeSlide(
            delay: const Duration(milliseconds: 340),
            child: Center(
              child: FilledButton.icon(
                onPressed: () => context.goNamed(AppRouteNames.accountCreate),
                icon: const Icon(Icons.person_add),
                label: const Text('Criar Conta para Começar'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountHeaderCard(BuildContext context) {
    final account = _vmAccount.accountState.state.value!;

    return RefreshIndicator(
      key: const ValueKey('account'),
      onRefresh: () async => await _vmAccount.commands.fetchAccount(),
      color: Theme.of(context).colorScheme.secondary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedFadeSlide(
              child: _AccountHeaderCard(
                displayName: account.displayName,
                email: account.email,
                level: account.level,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 100),
              child: Text(
                'Recursos',
                style: context.textStyles.titleLarge?.semiBold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 180),
              child: Row(
                children: [
                  Expanded(
                    child: GameResourceCard(
                      icon: Icons.diamond,
                      label: 'Gemas',
                      value: account.gems.toString(),
                      accentColor: LightModeColors.lightInversePrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: GameResourceCard(
                      icon: Icons.bolt,
                      label: 'Energia',
                      value: account.energy.toString(),
                      accentColor: const Color(0xFF4ADE80),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: GameResourceCard(
                      icon: Icons.monetization_on,
                      label: 'Gold',
                      value: NumberFormat.compact(
                        locale: 'en_US',
                      ).format(account.gold),
                      accentColor: const Color(0xFFFBBF24),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 340),
              child: Text(
                'Informações da Conta',
                style: context.textStyles.titleLarge?.semiBold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 420),
              child: _InfoCard(
                icon: Icons.calendar_today,
                label: 'Data de Criação',
                value: DateFormat('dd/MM/yyyy').format(account.createdAt),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 500),
              child: Center(
                child: FilledButton.icon(
                  onPressed: () => context.goNamed(
                    AppRouteNames.characters,
                    extra: account,
                  ),
                  icon: const Icon(Icons.people),
                  label: const Text('Ver Meus Personagens'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountHeaderCard extends StatelessWidget {
  final String displayName;
  final String email;
  final int level;

  const _AccountHeaderCard({
    required this.displayName,
    required this.email,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.secondary.withValues(alpha: 0.85),
            colorScheme.tertiary.withValues(alpha: 0.7),
            colorScheme.secondary.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: colorScheme.onSecondary,
                child: Text(
                  displayName[0].toUpperCase(),
                  style: context.textStyles.headlineMedium?.copyWith(
                    color: colorScheme.primary,
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
                      style: context.textStyles.headlineSmall?.bold,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: context.textStyles.bodyMedium?.withColor(
                        colorScheme.onSecondary.withValues(alpha: 0.9),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.military_tech,
                  color: colorScheme.onSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Level $level',
                  style: context.textStyles.titleMedium?.bold.withColor(
                    colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: colorScheme.secondary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textStyles.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: context.textStyles.titleMedium?.semiBold),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String titulo;
  final String conteudo;

  const _InfoSection({required this.titulo, required this.conteudo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: context.textStyles.titleLarge?.semiBold.withColor(
            colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            conteudo,
            style: context.textStyles.bodyMedium?.withColor(
              colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
