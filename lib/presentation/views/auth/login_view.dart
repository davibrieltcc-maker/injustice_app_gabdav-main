import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/messages/auth_error_messages.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/services/auth_service_interface.dart';
import '../../functions/ui_functions.dart';
import '../../widgets/animated_fade_slide.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/input_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final IAuthService _authService;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = injector.get<IAuthService>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AuthScaffold(
      headerIcon: Icons.lock_outline,
      title: 'Bem-vindo de volta',
      subtitle: 'Entre com seu e-mail e senha para continuar',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 80),
              child: InputTextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                label: 'E-mail',
                hint: 'Digite seu e-mail',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 160),
              child: InputTextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                label: 'Senha',
                hint: 'Digite sua senha',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _signIn(),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 240),
              child: AppPrimaryButton(
                label: 'ENTRAR',
                isLoading: _isLoading,
                onPressed: _signIn,
                icon: Icons.login,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 320),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Não tem conta?',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => context.goNamed(AppRouteNames.signUp),
                    child: Text(
                      'Cadastre-se',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
