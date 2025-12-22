import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Sign Up Screen - User registration with email and password
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- VALIDATION LOGIC (UNCHANGED) ---

  /// Validate email format using regex
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password strength
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validate confirm password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate first name
  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    if (value.length < 2) {
      return 'First name must be at least 2 characters';
    }
    return null;
  }

  /// Validate last name
  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    if (value.length < 2) {
      return 'Last name must be at least 2 characters';
    }
    return null;
  }

  // --- MODIFIED HANDLER ---

  /// Handle sign up submission
  Future<void> _handleSignUp() async { // Made async
    // 1. Check Terms
    if (!_agreedToTerms) {
      _showErrorDialog(
        'Terms & Conditions',
        'You must agree to the Terms & Conditions to continue.',
      );
      return;
    }

    // 2. Validate Forms
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // 3. Create Firebase User
        final UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // 4. Update Display Name
        String displayName = "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";

        if (userCredential.user != null) {
          await userCredential.user!.updateDisplayName(displayName);

          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
            'uid': userCredential.user!.uid,
            'email': _emailController.text.trim(),
            'displayName': displayName,
            'searchEmail': _emailController.text.trim().toLowerCase(),
          });
        }

        // 4. Update Display Name (Since you have First/Last name inputs)
        // This ensures the user's name is stored in their Auth profile immediately.
        if (userCredential.user != null) {
          await userCredential.user!.updateDisplayName(
              "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}"
          );
        }

        if (mounted) {
          // Success UI
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome ${_firstNameController.text}! Account created successfully.',
              ),
              backgroundColor: AppStyles.successGreen,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: AppStyles.borderRadiusSmallAll,
              ),
            ),
          );

          // Note: Firebase automatically logs the user in after signup.
          // You might want to navigate to '/home' instead of '/login',
          // but I kept your original routing logic here.
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          });
        }
      } on FirebaseAuthException catch (e) {
        // 5. Handle Specific Firebase Errors
        String errorMessage;

        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'This email is already registered. Please sign in.';
            break;
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is badly formatted.';
            break;
          default:
            errorMessage = e.message ?? 'An unknown error occurred.';
        }

        if (mounted) {
          _showErrorDialog('Registration Failed', errorMessage);
        }
      } catch (e) {
        // Handle generic errors
        if (mounted) {
          _showErrorDialog('Error', 'Something went wrong. Please try again.');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  /// Show error dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // I have kept your Build method EXACTLY as it was.
    // No changes were made to the UI layout below.

    final screenWidth = MediaQuery.of(context).size.width;
    // Unused variable warning, but kept to preserve your code structure
    // final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppStyles.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: AppStyles.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 20.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Join Promise Today',
                style: AppStyles.headingLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppStyles.paddingSmall),
              Text(
                'Create an account to start managing your commitments',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppStyles.mediumGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppStyles.paddingXLarge),

              // First Name Field
              Text(
                'First Name',
                style: AppStyles.labelLarge,
              ),
              const SizedBox(height: AppStyles.paddingSmall),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  hintText: 'Enter your first name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: AppStyles.borderRadiusSmallAll,
                  ),
                ),
                validator: _validateFirstName,
              ),
              const SizedBox(height: AppStyles.paddingMedium),

              // Last Name Field
              Text(
                'Last Name',
                style: AppStyles.labelLarge,
              ),
              const SizedBox(height: AppStyles.paddingSmall),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  hintText: 'Enter your last name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: AppStyles.borderRadiusSmallAll,
                  ),
                ),
                validator: _validateLastName,
              ),
              const SizedBox(height: AppStyles.paddingMedium),

              // Email Field
              Text(
                'Email Address',
                style: AppStyles.labelLarge,
              ),
              const SizedBox(height: AppStyles.paddingSmall),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: AppStyles.borderRadiusSmallAll,
                  ),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: AppStyles.paddingMedium),

              // Password Field
              Text(
                'Password',
                style: AppStyles.labelLarge,
              ),
              const SizedBox(height: AppStyles.paddingSmall),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppStyles.borderRadiusSmallAll,
                  ),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: AppStyles.paddingSmall),

              // Password Requirements
              Container(
                padding: const EdgeInsets.all(AppStyles.paddingMedium),
                decoration: BoxDecoration(
                  color: AppStyles.nearWhite,
                  borderRadius: AppStyles.borderRadiusSmallAll,
                  border: Border.all(color: AppStyles.lightGray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password Requirements:',
                      style: AppStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppStyles.paddingSmall),
                    _buildRequirement('At least 6 characters'),
                    _buildRequirement('At least 1 uppercase letter'),
                    _buildRequirement('At least 1 number'),
                  ],
                ),
              ),
              const SizedBox(height: AppStyles.paddingMedium),

              // Confirm Password Field
              Text(
                'Confirm Password',
                style: AppStyles.labelLarge,
              ),
              const SizedBox(height: AppStyles.paddingSmall),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  hintText: 'Confirm your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(
                            () =>
                        _obscureConfirmPassword = !_obscureConfirmPassword,
                      );
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppStyles.borderRadiusSmallAll,
                  ),
                ),
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: AppStyles.paddingMedium),

              // Terms & Conditions Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (value) {
                      setState(() => _agreedToTerms = value ?? false);
                    },
                    activeColor: AppStyles.primaryPurple,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _showTermsDialog();
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'I agree to the ',
                              style: AppStyles.bodySmall,
                            ),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: AppStyles.bodySmall.copyWith(
                                color: AppStyles.primaryPurple,
                                fontWeight: FontWeight.bold,
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
              const SizedBox(height: AppStyles.paddingLarge),

              // Sign Up Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryPurple,
                  foregroundColor: AppStyles.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppStyles.paddingMedium,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppStyles.borderRadiusSmallAll,
                  ),
                  disabledBackgroundColor: AppStyles.mediumGray,
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation(AppStyles.white),
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Create Account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: AppStyles.paddingLarge),

              // Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppStyles.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Sign In',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppStyles.primaryPurple,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.paddingXLarge),
            ],
          ),
        ),
      ),
    );
  }

  /// Build requirement item with checkmark (UNCHANGED)
  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppStyles.paddingSmall),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppStyles.successGreen,
          ),
          const SizedBox(width: AppStyles.paddingSmall),
          Text(
            text,
            style: AppStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  /// Show terms & conditions dialog (UNCHANGED)
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: SingleChildScrollView(
          child: Text(
            'By creating an account and using the Promise app, you agree to:\n\n'
                '1. Provide accurate and complete information\n'
                '2. Maintain confidentiality of your account\n'
                '3. Use the app for lawful purposes only\n'
                '4. Not interfere with app functionality\n'
                '5. Accept our data privacy policies\n\n'
                'The Promise app is provided "as is" without warranties. We are not liable for any indirect or consequential damages.\n\n'
                'You may cancel your account at any time. Deletion of account data is permanent.',
            style: AppStyles.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _agreedToTerms = true);
              Navigator.pop(context);
            },
            child: const Text('Agree & Accept'),
          ),
        ],
      ),
    );
  }
}