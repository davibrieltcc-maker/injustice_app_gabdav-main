import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Layout compartilhado para telas de autenticação com gradiente e card central.
class AuthScaffold extends StatelessWidget {
  final Widget child;
  final IconData headerIcon;
  final String title;
  final String? subtitle;
  final PreferredSizeWidget? appBar;
  final bool showGlow;

  const AuthScaffold({
    super.key,
    required this.child,
    required this.headerIcon,
    required this.title,
    this.subtitle,
    this.appBar,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  LightModeColors.lightPrimaryContainer,
                  colorScheme.primary,
                ],
              ),
            ),
          ),
          if (showGlow)
            Positioned(
              top: -80,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.secondary.withValues(alpha: 0.25),
                      blurRadius: 80,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),
          if (showGlow)
            Positioned(
              bottom: -100,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: LightModeColors.lightInversePrimary.withValues(alpha: 0.18),
                      blurRadius: 70,
                      spreadRadius: 30,
                    ),
                  ],
                ),
              ),
            ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingLg,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AuthHeaderIcon(icon: headerIcon),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        title,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          subtitle!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      Container(
                        padding: AppSpacing.paddingLg,
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.35),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: child,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthHeaderIcon extends StatefulWidget {
  final IconData icon;

  const _AuthHeaderIcon({required this.icon});

  @override
  State<_AuthHeaderIcon> createState() => _AuthHeaderIconState();
}

class _AuthHeaderIconState extends State<_AuthHeaderIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              colorScheme.secondary.withValues(alpha: 0.9),
              colorScheme.tertiary.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          widget.icon,
          size: 40,
          color: colorScheme.onSecondary,
        ),
      ),
    );
  }
}
