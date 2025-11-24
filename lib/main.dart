import 'package:flutter/material.dart';
import 'package:promise/screens/home_dashboard_screen.dart';
import 'package:promise/screens/login_screen.dart';
import 'package:promise/screens/signup_screen.dart';
import 'package:promise/screens/profile_screen.dart';
import 'package:promise/screens/schedule_screen.dart';
import 'package:promise/utils/app_styles.dart';

void main() {
  runApp(const PromiseApp());
}

/// Main Promise Application
class PromiseApp extends StatelessWidget {
  const PromiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Promise - Commitment & Schedule Management',
      theme: AppStyles.buildAppTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
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
            appBar: AppBar(
              title: const Text('Page Not Found'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppStyles.errorRed,
                  ),
                  const SizedBox(height: AppStyles.paddingLarge),
                  Text(
                    '404 - Page Not Found',
                    style: AppStyles.headingMedium,
                  ),
                  const SizedBox(height: AppStyles.paddingMedium),
                  Text(
                    'The requested route "${settings.name}" does not exist.',
                    style: AppStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppStyles.paddingLarge),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      '/home',
                    ),
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
