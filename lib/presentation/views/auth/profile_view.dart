import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/messages/auth_error_messages.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/typedefs/types_defs.dart';
import '../../../core/validators/email_str_validator.dart';
import '../../../core/validators/empty_str_validator.dart';
import '../../../core/validators/passwor_full_validator.dart';
import '../../../data/services/auth_service_interface.dart';
import '../../../data/services/session_storage_interface.dart';
import '../../functions/ui_functions.dart';
import '../../widgets/animated_fade_slide.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/input_text_field.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final IAuthService _authService;
  late final ISessionStorage _sessionStorage;

  final _formKey = GlobalKey<FormState>();
  final _nameField = _createField();
  final _emailField = _createField();
  final _currentPasswordField = _createField();
  final _newPasswordField = _createField();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = injector.get<IAuthService>();
    _sessionStorage = injector.get<ISessionStorage>();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    if (user == null) return;

    _nameField.controller.text = user.displayName ?? '';
    _emailField.controller.text = user.email ?? '';
  }

  @override
  void dispose() {
    for (final field in [
      _nameField,
      _emailField,
      _currentPasswordField,
      _newPasswordField,
    ]) {
      field.focus.dispose();
      field.controller.dispose();
    }
    super.dispose();
  }

  static FormFieldControl _createField() {
    return (
      key: GlobalKey<FormFieldState>(),
      focus: FocusNode(),
      controller: TextEditingController(),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _authService.currentUser;
    if (user == null) return;

    final newName = _nameField.controller.text.trim();
    final newEmail = _emailField.controller.text.trim();
    final currentPassword = _currentPasswordField.controller.text;
    final newPassword = _newPasswordField.controller.text.trim();

    final nameChanged = newName != (user.displayName ?? '');
    final emailChanged = newEmail != (user.email ?? '');
    final passwordChanged = newPassword.isNotEmpty;

    if (!nameChanged && !emailChanged && !passwordChanged) {
      showAuthSnackBar(context, 'Nenhuma alteração foi feita.');
      return;
    }

    if ((emailChanged || passwordChanged) && currentPassword.isEmpty) {
      showAuthSnackBar(
        context,
        'Informe sua senha atual para alterar e-mail ou senha.',
        isError: true,
      );
      _currentPasswordField.focus.requestFocus();
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (nameChanged) {
        await _authService.updateDisplayName(newName);
      }

      if (emailChanged) {
        await _authService.updateEmail(
          newEmail: newEmail,
          currentPassword: currentPassword,
        );
      }

      if (passwordChanged) {
        await _authService.updatePassword(
          newPassword: newPassword,
          currentPassword: currentPassword,
        );
      }

      if (!mounted) return;

      _currentPasswordField.controller.clear();
      _newPasswordField.controller.clear();
      _loadUserData();

      showAuthSnackBar(context, 'Perfil atualizado com sucesso!');
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
        'Não foi possível atualizar o perfil.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await _sessionStorage.clearSelectedAccountId();
    await _authService.signOut();
    if (!mounted) return;
    context.goNamed(AppRouteNames.login);
  }

  String _userInitial() {
    final user = _authService.currentUser;
    final name = user?.displayName ?? user?.email ?? 'U';
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = _authService.currentUser;

    return AuthScaffold(
      headerIcon: Icons.manage_accounts_outlined,
      title: 'Meu Perfil',
      subtitle: user?.email,
      showGlow: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => context.goNamed(AppRouteNames.home),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedFadeSlide(
              child: Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: colorScheme.secondary,
                  child: Text(
                    _userInitial(),
                    style: context.textStyles.headlineMedium?.bold.withColor(
                      colorScheme.onSecondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionLabel(label: 'Dados pessoais'),
            const SizedBox(height: AppSpacing.sm),
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 80),
              child: InputTextField(
                fieldKey: _nameField.key,
                controller: _nameField.controller,
                focusNode: _nameField.focus,
                label: 'Nome',
                hint: 'Digite seu nome',
                prefixIcon: Icons.account_circle_outlined,
                enabled: !_isLoading,
                validator: (value) =>
                    validateField(value, [EmptyStrValidator()]),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 160),
              child: InputTextField(
                fieldKey: _emailField.key,
                controller: _emailField.controller,
                focusNode: _emailField.focus,
                label: 'E-mail',
                hint: 'Digite seu e-mail',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
                validator: (value) => validateField(value, [
                  EmptyStrValidator(),
                  EmailStrValidator(),
                ]),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionLabel(label: 'Segurança'),
            const SizedBox(height: AppSpacing.sm),
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 240),
              child: InputTextField(
                fieldKey: _currentPasswordField.key,
                controller: _currentPasswordField.controller,
                focusNode: _currentPasswordField.focus,
                label: 'Senha atual',
                hint: 'Necessária para alterar e-mail ou senha',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                enabled: !_isLoading,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 320),
              child: InputTextField(
                fieldKey: _newPasswordField.key,
                controller: _newPasswordField.controller,
                focusNode: _newPasswordField.focus,
                label: 'Nova senha',
                hint: 'Deixe em branco para manter a atual',
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: true,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  return validateField(value, [
                    PassworFullValidator(),
                  ]);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 400),
              child: AppPrimaryButton(
                label: 'SALVAR ALTERAÇÕES',
                isLoading: _isLoading,
                onPressed: _saveProfile,
                icon: Icons.save_outlined,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 480),
              child: OutlinedButton(
                onPressed: _isLoading ? null : _signOut,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  foregroundColor: colorScheme.secondary,
                  side: BorderSide(
                    color: colorScheme.secondary.withValues(alpha: 0.7),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  'SAIR DA CONTA',
                  style: context.textStyles.titleMedium?.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: context.textStyles.titleSmall?.semiBold.withColor(
            colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
