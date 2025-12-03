import 'package:flutter/material.dart';
import 'package:flutter_one/core/utils/validators.dart';
import 'package:flutter_one/presentation/providers/app_providers.dart';
import 'package:flutter_one/presentation/widgets/responsive_layout.dart';

/// Login page with Reddit-inspired design
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authController = AuthProvider.of(context);
      final success = await authController.login(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/posts');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = AuthProvider.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
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
                                // Left side: illustration / branding
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.article_outlined, size: 96, color: theme.colorScheme.primary),
                                      const SizedBox(height: 12),
                                      Text('Welcome Back', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text('Sign in to continue and join the conversation', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                // Right side: form
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 8),
                                      // Error message
                                      if (authController.error != null) ...[
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.errorContainer,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.error_outline, color: theme.colorScheme.error),
                                              const SizedBox(width: 8),
                                              Expanded(child: Text(authController.error!, style: TextStyle(color: theme.colorScheme.error))),
                                              IconButton(icon: const Icon(Icons.close), onPressed: authController.clearError, color: theme.colorScheme.error),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],

                                      // Phone field
                                      TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()), validator: Validators.validatePhone),
                                      const SizedBox(height: 16),

                                      // Password field
                                      TextFormField(controller: _passwordController, obscureText: _obscurePassword, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))), validator: Validators.validatePassword),
                                      const SizedBox(height: 24),

                                      // Login button
                                      FilledButton(onPressed: authController.isLoading ? null : _handleLogin, child: Padding(padding: const EdgeInsets.all(12), child: authController.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Login'))),
                                      const SizedBox(height: 16),

                                      // Register link
                                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Don't have an account?"), TextButton(onPressed: () => Navigator.of(context).pushNamed('/register'), child: const Text('Sign Up'))]),
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
                                Text('Welcome Back', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                const SizedBox(height: 8),
                                Text('Sign in to continue', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                                const SizedBox(height: 40),

                                // Continue with existing form elements for mobile
                                // Error message
                                if (authController.error != null) ...[
                                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(Icons.error_outline, color: theme.colorScheme.error), const SizedBox(width: 8), Expanded(child: Text(authController.error!, style: TextStyle(color: theme.colorScheme.error))), IconButton(icon: const Icon(Icons.close), onPressed: authController.clearError, color: theme.colorScheme.error)])),
                                  const SizedBox(height: 16),
                                ],

                                // Phone field
                                TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()), validator: Validators.validatePhone),
                                const SizedBox(height: 16),

                                // Password field
                                TextFormField(controller: _passwordController, obscureText: _obscurePassword, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))), validator: Validators.validatePassword),
                                const SizedBox(height: 24),

                                // Login button
                                FilledButton(onPressed: authController.isLoading ? null : _handleLogin, child: Padding(padding: const EdgeInsets.all(12), child: authController.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Login'))),
                                const SizedBox(height: 16),

                                // Register link
                                Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Don't have an account?"), TextButton(onPressed: () => Navigator.of(context).pushNamed('/register'), child: const Text('Sign Up'))]),
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
