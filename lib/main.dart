import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:promise/providers/auth_provider.dart';
import 'package:promise/providers/promise_provider.dart'; // Import PromiseProvider
import 'package:promise/services/database_service.dart'; // Import DatabaseService

// Screens
import 'package:promise/screens/home_dashboard_screen.dart';
import 'package:promise/screens/login_screen.dart';
import 'package:promise/screens/signup_screen.dart';
import 'package:promise/screens/profile_screen.dart';
import 'package:promise/screens/schedule_screen.dart';
import 'package:promise/screens/new_promise_screen.dart'; // Import NewPromiseScreen
import 'package:promise/screens/edit_promise_screen.dart'; // Import EditPromiseScreen
import 'package:promise/utils/app_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PromiseApp());
}

class PromiseApp extends StatelessWidget {
  const PromiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Auth Provider (Keeps track of who is logged in)
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // 2. ProxyProvider (Links Auth to Database)
        // Whenever AuthProvider changes (login/logout), this updates the DatabaseService
        ProxyProvider<AuthProvider, DatabaseService>(
          update: (_, auth, __) => DatabaseService(userId: auth.user?.uid),
        ),

        // 3. Promise Provider (Listens to the DatabaseService we just created)
        // It provides the list of promises to the UI
        ChangeNotifierProxyProvider<DatabaseService, PromiseProvider>(
          create: (context) => PromiseProvider(Provider.of<DatabaseService>(context, listen: false)),
          update: (_, db, previous) => PromiseProvider(db),
        ),
      ],
      child: MaterialApp(
        title: 'Promise',
        theme: AppStyles.buildAppTheme(),
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const HomeDashboardScreen(),
          '/schedule': (context) => const ScheduleScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/new-promise': (context) => const NewPromiseScreen(),
          '/edit-promise': (context) => const EditPromiseScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.isAuthenticated) {
      return const HomeDashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}