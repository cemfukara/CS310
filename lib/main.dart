import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Providers
import 'package:promise/providers/auth_provider.dart';
import 'package:promise/providers/promise_provider.dart';
import 'package:promise/providers/theme_provider.dart';
import 'package:promise/providers/friends_provider.dart';
import 'package:promise/providers/gamification_provider.dart';

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
        // 1. Independent Providers
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // 2. Services (Injected as a standard Provider, not ChangeNotifier)
        Provider<DatabaseService>(create: (_) => FirestoreService()),

        // 3. Dependent Providers (Using ProxyProvider CORRECTLY)

        // Fix: PromiseProvider depends on DatabaseService
        ChangeNotifierProxyProvider<DatabaseService, PromiseProvider>(
          create: (context) => PromiseProvider(context.read<DatabaseService>()),
          update: (_, db, previous) => previous!..update(db),
        ),

        // Fix: GamificationProvider depends on DatabaseService
        ChangeNotifierProxyProvider<DatabaseService, GamificationProvider>(
          create: (context) =>
              GamificationProvider(context.read<DatabaseService>()),
          update: (_, db, previous) => previous!..update(db),
        ),

        // Fix: FriendsProvider depends on AuthProvider AND DatabaseService
        ChangeNotifierProxyProvider2<
          AuthProvider,
          DatabaseService,
          FriendsProvider
        >(
          create: (context) => FriendsProvider(
            context.read<AuthProvider>(),
            context.read<DatabaseService>(),
          ),
          update: (_, auth, db, previous) => previous!..update(auth, db),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Promise',
      theme: AppStyles.buildAppTheme(
        isDarkMode: Provider.of<ThemeProvider>(context).isDark,
      ),
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
      return const HomeDashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}
