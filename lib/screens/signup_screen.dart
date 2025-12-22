import 'package:flutter/material.dart';
// --- FIX: Hide the conflicting AuthProvider class from Firebase ---
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../providers/auth_provider.dart'; // Your custom AuthProvider

/// Sign Up Screen - User registration with email and password
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
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

  // --- VALIDATION LOGIC ---

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'At least one uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'At least one number';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) return 'First name is required';
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) return 'Last name is required';
    return null;
  }

  // --- SIGN UP LOGIC ---

  Future<void> _handleSignUp() async {
    if (!_agreedToTerms) {
      _showErrorDialog('Terms & Conditions', 'You must agree to the Terms & Conditions to continue.');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Use your custom AuthProvider (now unambiguous)
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final String email = _emailController.text.trim();
        final String password = _passwordController.text.trim();
        final String displayName = "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";

        // 1. Create User in Firebase Auth
        final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          final user = userCredential.user!;

          // 2. Update Auth Profile (Name) - AWAIT ensures it finishes
          await user.updateDisplayName(displayName);

          // 3. Create Public Firestore Document - AWAIT ensures it finishes
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'createdBy': user.uid, // <--- CRITICAL FIX: Required by Security Rules
            'email': email,
            'displayName': displayName,
            'searchEmail': email.toLowerCase(),
          });

          // 4. Force app refresh so Profile screen gets the new name
          await authProvider.refreshUser();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome ${_firstNameController.text}! Account created.'),
              backgroundColor: AppStyles.successGreen,
            ),
          );

          // 5. FIX: Pop instead of pushing.
          // AuthWrapper in main.dart detects the login and shows Home automatically.
          Navigator.of(context).pop();
        }

      } on FirebaseAuthException catch (e) {
        String errorMessage = e.message ?? 'An unknown error occurred.';
        if (e.code == 'email-already-in-use') errorMessage = 'This email is already registered.';
        if (e.code == 'weak-password') errorMessage = 'The password provided is too weak.';

        if (mounted) _showErrorDialog('Registration Failed', errorMessage);
      } catch (e) {
        if (mounted) _showErrorDialog('Error', 'Something went wrong: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

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

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            'By using Promise, you agree to our terms. We protect your data and privacy.',
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() => _agreedToTerms = true);
              Navigator.pop(context);
            },
            child: const Text('Agree'),
          ),
        ],
      ),
    );
  }

  // --- BUILD UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppStyles.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create Account', style: TextStyle(color: AppStyles.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Join Promise Today', style: AppStyles.headingLarge, textAlign: TextAlign.center),
              const SizedBox(height: 20),

              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name', prefixIcon: Icon(Icons.person_outline)),
                validator: _validateFirstName,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name', prefixIcon: Icon(Icons.person_outline)),
                validator: _validateLastName,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                validator: _validateEmail,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                    activeColor: AppStyles.primaryPurple,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showTermsDialog,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: 'I agree to the ', style: AppStyles.bodySmall),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: AppStyles.bodySmall.copyWith(color: AppStyles.primaryPurple, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryPurple,
                  foregroundColor: AppStyles.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ', style: AppStyles.bodyMedium),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Sign In', style: AppStyles.bodyMedium.copyWith(color: AppStyles.primaryPurple, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}