import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:promise/providers/theme_provider.dart';
import 'package:provider/provider.dart';

// Providers
import 'package:promise/providers/auth_provider.dart';
import 'package:promise/providers/promise_provider.dart';

// Services
import 'package:promise/services/database_service.dart'; // The Interface
import 'package:promise/services/firestore_service.dart'; // The Implementation

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
        // 1. Auth Provider (Keeps track of who is logged in)
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // 2. Database Service (Linked to Auth)
        // We use ProxyProvider so that if Auth changes (Log In/Out),
        // we create a fresh FirestoreService instance.
        ProxyProvider<AuthProvider, DatabaseService>(
          update: (_, auth, __) {
            // We instantiate the specific implementation (FirestoreService) here.
            // FirestoreService internally uses FirebaseAuth to get the user ID,
            // but recreating it here ensures the stream resets on login.
            return FirestoreService();
          },
        ),

        // 3. Promise Provider (Depends on DatabaseService)
        // When DatabaseService is ready/updated, this initializes the PromiseProvider
        // which immediately starts listening to the Firestore stream.
        ChangeNotifierProxyProvider<DatabaseService, PromiseProvider>(
          create: (context) => PromiseProvider(
            Provider.of<DatabaseService>(context, listen: false),
          ),
          update: (_, db, previous) {
            // If we have an existing provider, we could technically update it,
            // but creating a new one is safer to ensure clean state on user switch.
            return PromiseProvider(db);
          },
        ),
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
      theme: AppStyles.buildAppTheme(
        isDarkMode: Provider.of<ThemeProvider>(context).isDark,
      ),
      debugShowCheckedModeBanner: false,
      // The AuthWrapper decides which screen to show first
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeDashboardScreen(),
        // Uncomment these as you build the screens to avoid errors:
        // '/schedule': (context) => const ScheduleScreen(),
        // '/profile': (context) => const ProfileScreen(),
        // '/new-promise': (context) => const NewPromiseScreen(),
        // '/edit-promise': (context) => const EditPromiseScreen(),
      },
    );
  }
}

/// A Helper Widget to handle the initial navigation based on Auth State
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // We listen to the AuthProvider to decide what to show
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If user is logged in, show the Dashboard. Otherwise, show Login.
    if (authProvider.isAuthenticated) {
      return const HomeDashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}
