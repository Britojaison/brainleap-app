import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'otp_verification_view.dart';
import 'signup_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  static const routeName = '/login';

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isEmailValid {
    final email = _emailController.text.trim();
    return email.isNotEmpty && email.contains('@');
  }

  bool get _isPasswordValid {
    if (!_showPassword) return true;
    return _passwordController.text.trim().length >= 6;
  }

  Future<void> _handleContinue(AuthProvider authProvider) async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();

    if (!_isEmailValid) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    if (_showPassword) {
      if (!authProvider.isEmailRegistered(email)) {
        setState(() {
          _errorMessage =
              'That email address is not registered. Enter a different one or sign up.';
        });
        return;
      }

      final password = _passwordController.text.trim();
      if (!authProvider.validatePassword(email, password)) {
        setState(() {
          _errorMessage = 'Password must be at least 6 characters.';
        });
        return;
      }

      await authProvider.mockAuthenticate(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed in successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!authProvider.isEmailRegistered(email)) {
      setState(() {
        _errorMessage =
            'That email address is not registered.\nEnter a different one or sign up.';
      });
      return;
    }

    authProvider.sendMockOtp(email);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpVerificationView(email: email),
      ),
    );
  }

  void _togglePassword() {
    setState(() {
      _showPassword = !_showPassword;
      _errorMessage = null;
      if (!_showPassword) {
        _passwordController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              final isContinueEnabled = _isEmailValid && _isPasswordValid;

              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 48),
                            const Text(
                              'Log in with email',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Welcome back! Enter your email to continue learning.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              'Email address',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: _showPassword
                                  ? TextInputAction.next
                                  : TextInputAction.done,
                              decoration: const InputDecoration(
                                hintText: 'Enter your email address',
                              ),
                              onChanged: (_) => setState(() {
                                _errorMessage = null;
                              }),
                            ),
                            if (_showPassword) ...[
                              const SizedBox(height: 24),
                              const Text(
                                'Password',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  hintText:
                                      'Enter your password (6+ characters)',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                onChanged: (_) => setState(() {
                                  _errorMessage = null;
                                }),
                              ),
                            ],
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _togglePassword,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                alignment: Alignment.centerLeft,
                              ),
                              child: Text(
                                _showPassword
                                    ? 'Use email OTP instead'
                                    : 'Use password instead',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(fontSize: 14),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const SignupView(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Sign up',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isContinueEnabled
                                    ? () => _handleContinue(authProvider)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                  backgroundColor: _showPassword
                                      ? Colors.black
                                      : const Color(0xFF111827),
                                  disabledBackgroundColor:
                                      const Color(0xFFE5E7EB),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  _showPassword ? 'Sign in' : 'Continue',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
