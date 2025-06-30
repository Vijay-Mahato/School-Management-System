import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_theme.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/loading_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authViewModel = context.read<AuthViewModel>();
      await authViewModel.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        _showSuccessMessage('Login successful!');
        // Navigation is handled by GoRouter redirect
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // App Logo/Title
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 60,
                    color: AppTheme.primaryColor,
                  ),
                ).animate().scale(delay: 200.ms),

                const SizedBox(height: 32),

                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 8),

                Text(
                  'Sign in to your account',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 40),

                // Demo Credentials Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demo Credentials:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDemoCredential('Admin', 'admin@school.com', 'password123'),
                        _buildDemoCredential('Teacher', 'teacher@school.com', 'password123'),
                        _buildDemoCredential('Student', 'student@school.com', 'password123'),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.3, delay: 800.ms),

                const SizedBox(height: 32),

                // Email Field
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ).animate().slideX(begin: -0.3, delay: 1000.ms),

                const SizedBox(height: 16),

                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ).animate().slideX(begin: 0.3, delay: 1200.ms),

                const SizedBox(height: 32),

                // Login Button
                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, child) {
                    return LoadingButton(
                      text: 'Sign In',
                      isLoading: authViewModel.isLoading,
                      onPressed: _login,
                    );
                  },
                ).animate().slideY(begin: 0.3, delay: 1400.ms),

                const SizedBox(height: 24),

                // Sign Up Link
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Text(
                //       "Don't have an account? ",
                //       style: TextStyle(color: AppTheme.textSecondary),
                //     ),
                //     TextButton(
                //       onPressed: () => context.go('/signup'),
                //       child: const Text(
                //         'Sign Up',
                //         style: TextStyle(
                //           fontWeight: FontWeight.w600,
                //           color: AppTheme.primaryColor,
                //         ),
                //       ),
                //     ),
                //   ],
                // ).animate().fadeIn(delay: 1600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCredential(String role, String email, String password) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$role: $email / $password',
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.textSecondary,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
