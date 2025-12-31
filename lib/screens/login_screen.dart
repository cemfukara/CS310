import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';

/// Login Screen - User input form with validation
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();

  // Track if form has been submitted (to show errors on first attempt)
  bool _hasSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Validate email format
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    const emailRegex = r'^[^@]+@[^@]+\.[^@]+$';
    if (!RegExp(emailRegex).hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Handle login form submission
  void _handleLogin() async {
    setState(() {
      _hasSubmitted = true;
    });

    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      // Attempt login
      bool success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success) {
        if (mounted) {
          // ✅ FIX: Do NOT navigate manually.
          // AuthWrapper in main.dart detects the login and swaps to Home automatically.
          FocusScope.of(context).unfocus();
        }
      } else {
        if (mounted) {
          // Show the error from Firebase
          _showErrorDialog(
            authProvider.errorMessage ??
                "Login failed. Please check your credentials.",
          );
        }
      }
    }
  }

  /// Show error dialog with validation summary
  void _showErrorDialog([String? message]) {
    final errors = <String>[];

    if (_validateEmail(_emailController.text) != null) {
      errors.add('• ${_validateEmail(_emailController.text)}');
    }
    if (_validatePassword(_passwordController.text) != null) {
      errors.add('• ${_validatePassword(_passwordController.text)}');
    }

    String content = message ?? errors.join('\n');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppStyles.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppStyles.borderRadiusMediumAll,
            side: const BorderSide(color: AppStyles.lightGray, width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppStyles.errorRed.withOpacity(0.1),
                  borderRadius: AppStyles.borderRadiusSmallAll,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: AppStyles.errorRed,
                  size: AppStyles.iconSizeMedium,
                ),
              ),
              const SizedBox(width: AppStyles.paddingMedium),
              const Expanded(
                child: Text('Error', style: AppStyles.headingSmall),
              ),
            ],
          ),
          content: Text(content, style: AppStyles.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: AppStyles.labelLarge.copyWith(
                  color: AppStyles.primaryPurple,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppStyles.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen
                ? AppStyles.paddingLarge
                : AppStyles.paddingXLarge,
            vertical: AppStyles.paddingLarge,
          ),
          child: SizedBox(
            height: screenHeight - 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppStyles.paddingLarge),
                      decoration: BoxDecoration(
                        color: AppStyles.primaryPurple.withOpacity(0.1),
                        borderRadius: AppStyles.borderRadiusLargeAll,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 48,
                        color: AppStyles.primaryPurple,
                      ),
                    ),
                    const SizedBox(height: AppStyles.paddingLarge),
                    Text(
                      'Welcome to Promise',
                      style: AppStyles.headingLarge.copyWith(
                        fontSize: isSmallScreen ? 28 : 32,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppStyles.paddingMedium),
                    Text(
                      'Your commitment and schedule management app',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppStyles.mediumGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: AppStyles.paddingXLarge),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Email Address', style: AppStyles.labelLarge),
                          const SizedBox(height: AppStyles.paddingSmall),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'your.email@example.com',
                              prefixIcon: const Icon(Icons.email_outlined),
                              prefixIconColor: AppStyles.primaryPurple,
                            ),
                            validator: _validateEmail,
                            onChanged: (_) {
                              if (_hasSubmitted) {
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppStyles.paddingLarge),

                      // Password Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Password', style: AppStyles.labelLarge),
                          const SizedBox(height: AppStyles.paddingSmall),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              prefixIconColor: AppStyles.primaryPurple,
                              suffixIcon: const Icon(
                                Icons.visibility_off_outlined,
                              ),
                              suffixIconColor: AppStyles.mediumGray,
                            ),
                            validator: _validatePassword,
                            onChanged: (_) {
                              if (_hasSubmitted) {
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppStyles.paddingXLarge),

                      // Login Button
                      ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.light
                              ? AppStyles
                                    .primaryPurple // Custom color
                              : null, // null = fall back to global theme (dark mode)
                          padding: const EdgeInsets.symmetric(
                            vertical: AppStyles.paddingMedium,
                          ),
                        ),
                        child: Text(
                          'Log In',
                          style: AppStyles.labelLarge.copyWith(
                            color: AppStyles.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppStyles.paddingMedium),

                      // Sign Up Link
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: AppStyles.bodyMedium,
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
                                  style: AppStyles.labelLarge.copyWith(
                                    color: AppStyles.primaryPurple,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
