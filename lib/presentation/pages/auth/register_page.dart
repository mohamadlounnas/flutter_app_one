import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_one/core/utils/validators.dart';
import 'package:flutter_one/presentation/providers/app_providers.dart';
import 'package:flutter_one/presentation/widgets/responsive_layout.dart';

/// Register page with Reddit-inspired design
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return Validators.validateRequired(value, 'Confirm Password');
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _handleRegister(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      final authController = AuthProvider.of(context);
      final success = await authController.register(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );
      if (success && mounted) {
        context.go('/posts');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = AuthProvider.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), centerTitle: true),
      body: SafeArea(
        child: ResponsiveLayout(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 800;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: isWide
                          ? Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.article_outlined, size: 96, color: theme.colorScheme.primary),
                                      const SizedBox(height: 12),
                                      Text('Create your account', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text('Join our community and start sharing', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 8),
                                      if (authController.error != null) ...[
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(color: theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(8)),
                                          child: Row(children: [Icon(Icons.error_outline, color: theme.colorScheme.error), const SizedBox(width: 8), Expanded(child: Text(authController.error!, style: TextStyle(color: theme.colorScheme.error))), IconButton(icon: const Icon(Icons.close), onPressed: authController.clearError, color: theme.colorScheme.error)]),
                                        ),
                                        const SizedBox(height: 16),
                                      ],

                                      TextFormField(controller: _nameController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()), validator: Validators.validateName),
                                      const SizedBox(height: 16),
                                      TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()), validator: Validators.validatePhone),
                                      const SizedBox(height: 16),
                                      TextFormField(controller: _passwordController, obscureText: _obscurePassword, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))), validator: Validators.validatePassword),
                                      const SizedBox(height: 16),
                                      TextFormField(controller: _confirmPasswordController, obscureText: _obscureConfirmPassword, decoration: InputDecoration(labelText: 'Confirm Password', prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword))), validator: _validateConfirmPassword),
                                      const SizedBox(height: 24),
                                      FilledButton(onPressed: authController.isLoading ? null : () => _handleRegister(context), child: Padding(padding: const EdgeInsets.all(12), child: authController.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Create Account'))),
                                      const SizedBox(height: 16),
                                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Already have an account?'), TextButton(onPressed: () => context.pop(), child: const Text('Login'))]),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 40),
                                Icon(Icons.article_outlined, size: 80, color: theme.colorScheme.primary),
                                const SizedBox(height: 16),
                                Text('Join our community', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                const SizedBox(height: 8),
                                Text('Create an account to start posting', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                                const SizedBox(height: 32),
                                if (authController.error != null) ...[
                                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(Icons.error_outline, color: theme.colorScheme.error), const SizedBox(width: 8), Expanded(child: Text(authController.error!, style: TextStyle(color: theme.colorScheme.error))), IconButton(icon: const Icon(Icons.close), onPressed: authController.clearError, color: theme.colorScheme.error)])),
                                  const SizedBox(height: 16),
                                ],
                                TextFormField(controller: _nameController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()), validator: Validators.validateName),
                                const SizedBox(height: 16),
                                TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()), validator: Validators.validatePhone),
                                const SizedBox(height: 16),
                                TextFormField(controller: _passwordController, obscureText: _obscurePassword, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))), validator: Validators.validatePassword),
                                const SizedBox(height: 16),
                                TextFormField(controller: _confirmPasswordController, obscureText: _obscureConfirmPassword, decoration: InputDecoration(labelText: 'Confirm Password', prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword))), validator: _validateConfirmPassword),
                                const SizedBox(height: 24),
                                FilledButton(onPressed: authController.isLoading ? null : () => _handleRegister(context), child: Padding(padding: const EdgeInsets.all(12), child: authController.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Create Account'))),
                                const SizedBox(height: 16),
                                Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Already have an account?'), TextButton(onPressed: () => context.pop(), child: const Text('Login'))]),
                                const SizedBox(height: 16),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

