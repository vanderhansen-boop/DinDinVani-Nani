import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).signIn(
          _email.text.trim(),
          _password.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authNotifierProvider);
    final isLoading = state is AuthLoading;

    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AuthLogo(),
                    const SizedBox(height: 40),
                    AuthTextField(
                      controller: _email,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe o email';
                        if (!v.contains('@')) return 'Email invalido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _password,
                      label: 'Senha',
                      icon: Icons.lock_outline,
                      obscureText: _obscure,
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) {
                        if (v == null || v.length < 6) return 'Minimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    AuthButton(
                      label: 'Entrar',
                      icon: Icons.login,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: const Text('Nao tem conta? Cadastre-se'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
