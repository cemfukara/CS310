import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Providers
import 'package:promise/providers/auth_provider.dart';
import 'package:promise/providers/promise_provider.dart';
import 'package:promise/providers/theme_provider.dart'; // Kept your ThemeProvider

// Services
import 'package:promise/services/database_service.dart';
import 'package:promise/services/firestore_service.dart';

// Screens
import 'package:promise/screens/home_dashboard_screen.dart';
import 'package:promise/screens/login_screen.dart';
import 'package:promise/screens/signup_screen.dart';
import 'package:promise/screens/profile_screen.dart';
import 'package:promise/screens/schedule_screen.dart';
import 'package:promise/screens/new_promise_screen.dart';
import 'package:promise/screens/edit_promise_screen.dart';
import 'package:promise/utils/app_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        // 1. Auth Provider
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // 2. Database Service (Linked to Auth)
        ProxyProvider<AuthProvider, DatabaseService>(
          update: (_, auth, __) {
            return FirestoreService();
          },
        ),

        // 3. Promise Provider (Depends on DatabaseService)
        ChangeNotifierProxyProvider<DatabaseService, PromiseProvider>(
          create: (context) => PromiseProvider(
            Provider.of<DatabaseService>(context, listen: false),
          ),
          update: (_, db, previous) {
            return PromiseProvider(db);
          },
        ),

        // 4. Theme Provider
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const PromiseApp(),
    ),
  );
}

class PromiseApp extends StatelessWidget {
  const PromiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Promise',
      // Using your ThemeProvider logic
      theme: AppStyles.buildAppTheme(
        isDarkMode: Provider.of<ThemeProvider>(context).isDark,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),

      // --- THE FIX: ROUTES UNCOMMENTED ---
      // These must be active for Navigator.pushNamed(context, '/new-promise') to work
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeDashboardScreen(),
        '/schedule': (context) => const ScheduleScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/new-promise': (context) => const NewPromiseScreen(),
        '/edit-promise': (context) => const EditPromiseScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.isAuthenticated) {
      // Correctly points to HomeDashboardScreen, which handles the BottomNavBar
      return const HomeDashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}