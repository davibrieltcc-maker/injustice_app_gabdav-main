import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/messages/auth_error_messages.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/validators/email_str_validator.dart';
import '../../../core/validators/empty_str_validator.dart';
import '../../../core/validators/passwor_full_validator.dart';
import '../../../data/services/auth_service_interface.dart';
import '../../functions/ui_functions.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/input_text_field.dart';

class AuthPageView extends StatefulWidget {
  final bool startOnSignUp;
  const AuthPageView({super.key, this.startOnSignUp = false});

  @override
  State<AuthPageView> createState() => _AuthPageViewState();
}

class _AuthPageViewState extends State<AuthPageView>
    with SingleTickerProviderStateMixin {
  late final IAuthService _authService;
  late final AnimationController _heroController;
  late final Animation<double> _heroPulse;

  int _activeTab = 0;

  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  final _loginEmailFocus = FocusNode();
  final _loginPasswordFocus = FocusNode();
  bool _loginLoading = false;

  final _signUpFormKey = GlobalKey<FormState>();
  final _signUpNameCtrl = TextEditingController();
  final _signUpEmailCtrl = TextEditingController();
  final _signUpPasswordCtrl = TextEditingController();
  final _signUpNameFocus = FocusNode();
  final _signUpEmailFocus = FocusNode();
  final _signUpPasswordFocus = FocusNode();
  bool _signUpLoading = false;

  bool get _isLoading => _loginLoading || _signUpLoading;

  @override
  void initState() {
    super.initState();
    _authService = injector.get<IAuthService>();
    _activeTab = widget.startOnSignUp ? 1 : 0;
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _heroPulse = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _heroController.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _loginEmailFocus.dispose();
    _loginPasswordFocus.dispose();
    _signUpNameCtrl.dispose();
    _signUpEmailCtrl.dispose();
    _signUpPasswordCtrl.dispose();
    _signUpNameFocus.dispose();
    _signUpEmailFocus.dispose();
    _signUpPasswordFocus.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (_isLoading || _activeTab == index) return;
    setState(() => _activeTab = index);
  }

  Future<void> _signIn() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _loginLoading = true);
    try {
      await _authService.signInWithEmailAndPassword(
        email: _loginEmailCtrl.text.trim(),
        password: _loginPasswordCtrl.text,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showAuthSnackBar(
        context,
        AuthErrorMessages.fromFirebaseAuthException(e),
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;
      showAuthSnackBar(
        context,
        'Não foi possível entrar. Tente novamente.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _loginLoading = false);
    }
  }

  Future<void> _signUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;
    setState(() => _signUpLoading = true);
    try {
      await _authService.createUserWithEmailAndPassword(
        email: _signUpEmailCtrl.text.trim(),
        password: _signUpPasswordCtrl.text,
        displayName: _signUpNameCtrl.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showAuthSnackBar(
        context,
        AuthErrorMessages.fromFirebaseAuthException(e),
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;
      showAuthSnackBar(
        context,
        'Não foi possível criar a conta. Tente novamente.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _signUpLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
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
          ),
          Positioned(
            top: -50,
            right: -20,
            child: _GlowOrb(
              color: colorScheme.secondary.withValues(alpha: 0.22),
              size: 180,
            ),
          ),
          Positioned(
            top: 110,
            left: -40,
            child: _GlowOrb(
              color: LightModeColors.lightInversePrimary.withValues(alpha: 0.14),
              size: 140,
            ),
          ),
          Column(
            children: [
              SizedBox(height: topPadding + 16),
              _HeroSection(
                heroPulse: _heroPulse,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 28),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 32,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PillTabBar(
                          activeIndex: _activeTab,
                          onTabSelected: _switchTab,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                        const SizedBox(height: 28),
                        AnimatedCrossFade(
                          firstChild: _LoginForm(
                            formKey: _loginFormKey,
                            emailCtrl: _loginEmailCtrl,
                            passwordCtrl: _loginPasswordCtrl,
                            emailFocus: _loginEmailFocus,
                            passwordFocus: _loginPasswordFocus,
                            isLoading: _loginLoading,
                            onSubmit: _signIn,
                          ),
                          secondChild: _SignUpForm(
                            formKey: _signUpFormKey,
                            nameCtrl: _signUpNameCtrl,
                            emailCtrl: _signUpEmailCtrl,
                            passwordCtrl: _signUpPasswordCtrl,
                            nameFocus: _signUpNameFocus,
                            emailFocus: _signUpEmailFocus,
                            passwordFocus: _signUpPasswordFocus,
                            isLoading: _signUpLoading,
                            onSubmit: _signUp,
                          ),
                          crossFadeState: _activeTab == 0
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 220),
                          sizeCurve: Curves.easeInOut,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final Animation<double> heroPulse;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _HeroSection({
    required this.heroPulse,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScaleTransition(
          scale: heroPulse,
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [colorScheme.secondary, colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.secondary.withValues(alpha: 0.55),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              Icons.gavel_rounded,
              size: 38,
              color: colorScheme.onSecondary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'INJUSTICE',
          style: textTheme.headlineLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Gerencie suas batalhas com maestria',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onPrimary.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _PillTabBar extends StatelessWidget {
  final int activeIndex;
  final void Function(int) onTabSelected;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _PillTabBar({
    required this.activeIndex,
    required this.onTabSelected,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _PillTab(
            label: 'Entrar',
            isActive: activeIndex == 0,
            onTap: () => onTabSelected(0),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          _PillTab(
            label: 'Cadastrar',
            isActive: activeIndex == 1,
            onTap: () => onTabSelected(1),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _PillTab({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isActive ? colorScheme.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: colorScheme.secondary.withValues(alpha: 0.38),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: isActive
                    ? colorScheme.onSecondary
                    : colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _LoginForm({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.emailFocus,
    required this.passwordFocus,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputTextField(
            controller: emailCtrl,
            focusNode: emailFocus,
            label: 'E-mail',
            hint: 'Digite seu e-mail',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          InputTextField(
            controller: passwordCtrl,
            focusNode: passwordFocus,
            label: 'Senha',
            hint: 'Digite sua senha',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            label: 'ENTRAR',
            isLoading: isLoading,
            onPressed: onSubmit,
            icon: Icons.login,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _SignUpForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final FocusNode nameFocus;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _SignUpForm({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.nameFocus,
    required this.emailFocus,
    required this.passwordFocus,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputTextField(
            controller: nameCtrl,
            focusNode: nameFocus,
            label: 'Nome',
            hint: 'Digite seu nome',
            prefixIcon: Icons.account_circle_outlined,
            textInputAction: TextInputAction.next,
            validator: (v) => validateField(v, [EmptyStrValidator()]),
          ),
          const SizedBox(height: AppSpacing.md),
          InputTextField(
            controller: emailCtrl,
            focusNode: emailFocus,
            label: 'E-mail',
            hint: 'Digite seu e-mail',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) => validateField(v, [
              EmptyStrValidator(),
              EmailStrValidator(),
            ]),
          ),
          const SizedBox(height: AppSpacing.md),
          InputTextField(
            controller: passwordCtrl,
            focusNode: passwordFocus,
            label: 'Senha',
            hint: 'Crie uma senha segura',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            validator: (v) => validateField(v, [
              EmptyStrValidator(),
              PassworFullValidator(),
            ]),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PasswordRequirementsHint(controller: passwordCtrl),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'CADASTRAR',
            isLoading: isLoading,
            onPressed: onSubmit,
            icon: Icons.how_to_reg,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _PasswordRequirementsHint extends StatefulWidget {
  final TextEditingController controller;
  const _PasswordRequirementsHint({required this.controller});

  @override
  State<_PasswordRequirementsHint> createState() =>
      _PasswordRequirementsHintState();
}

class _PasswordRequirementsHintState extends State<_PasswordRequirementsHint> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    final colorScheme = Theme.of(context).colorScheme;

    final checks = [
      (label: 'Maiúscula', met: RegExp(r'[A-Z]').hasMatch(text)),
      (label: 'Minúscula', met: RegExp(r'[a-z]').hasMatch(text)),
      (label: 'Número', met: RegExp(r'\d').hasMatch(text)),
      (label: 'Símbolo', met: RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(text)),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: checks.map((c) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              c.met ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 13,
              color: c.met ? Colors.greenAccent : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              c.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: c.met
                        ? Colors.greenAccent
                        : colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.6,
            spreadRadius: size * 0.25,
          ),
        ],
      ),
    );
  }
}
