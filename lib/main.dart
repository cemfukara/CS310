import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:promise/providers/auth_provider.dart';

// Screens
import 'package:promise/screens/home_dashboard_screen.dart';
import 'package:promise/screens/login_screen.dart';
import 'package:promise/screens/signup_screen.dart';
import 'package:promise/screens/profile_screen.dart';
import 'package:promise/screens/schedule_screen.dart';
import 'package:promise/utils/app_styles.dart';

// IMPORTANT: If you used 'flutterfire configure', uncomment the line below:
// import 'firebase_options.dart';

void main() async {
  // 1. Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase
  await Firebase.initializeApp();

  runApp(const PromiseApp());
}

/// Main Promise Application
class PromiseApp extends StatelessWidget {
  const PromiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Wrap App in MultiProvider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Promise - Commitment & Schedule Management',
        theme: AppStyles.buildAppTheme(),
        debugShowCheckedModeBanner: false,

        // 4. Use AuthWrapper to decide the first screen dynamically
        home: const AuthWrapper(),

        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const HomeDashboardScreen(),
          '/schedule': (context) => const ScheduleScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
        // Fallback route handler
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Page Not Found')),
              body: const Center(child: Text('404 - Page Not Found')),
            ),
          );
        },
      ),
    );
  }
}

/// A wrapper widget that listens to Auth state
/// and decides whether to show Login or Home
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);

    // If we are currently loading (e.g. logging in), show a spinner
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If user is logged in, go to Home. Otherwise, go to Login.
    if (authProvider.isAuthenticated) {
      return const HomeDashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}