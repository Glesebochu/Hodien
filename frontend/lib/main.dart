import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/authpage.dart';
import 'pages/home.dart';
import 'pages/humorTest.dart';
import 'pages/settings.dart';
import 'utils/utils.dart';
import './services/user_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

// Global navigator and theme notifier
final navigatorKey = GlobalKey<NavigatorState>();
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Connect to emulators if TEST_MODE is enabled
  const isTesting = bool.fromEnvironment('TEST_MODE');
  if (isTesting) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  runApp(
    shadcn.ShadcnApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      home: const AppRoot(), // Contains ValueListenableBuilder
      theme: shadcn.ThemeData(
        colorScheme: shadcn.ColorSchemes.lightYellow(),
        radius: 0.5,
      ),
    ),
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return MaterialApp(
          title: 'Hodien | ሆዴን',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: Utils.messengerKey,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentTheme,
          routes: {
            '/home':
                (context) => Home(
                  toggleTheme: _toggleTheme,
                  isDarkMode: currentTheme == ThemeMode.dark,
                ),
            '/settings': (context) => const SettingsPage(),
            '/humorTest': (context) => HumorTestScreen(),
          },
          home: const MainApp(), // Auth routing logic
        );
      },
    );
  }

  // Toggle between light and dark mode
  void _toggleTheme() {
    themeNotifier.value =
        themeNotifier.value == ThemeMode.dark
            ? ThemeMode.light
            : ThemeMode.dark;
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  void _toggleTheme() {
    themeNotifier.value =
        themeNotifier.value == ThemeMode.dark
            ? ThemeMode.light
            : ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          } else if (snapshot.hasData) {
            return FutureBuilder<bool>(
              future: UserService().checkHumorProfileExists(),
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (profileSnapshot.hasError ||
                    !(profileSnapshot.data ?? false)) {
                  return HumorTestScreen();
                } else {
                  return Home(
                    toggleTheme: _toggleTheme,
                    isDarkMode: isDarkMode,
                  );
                }
              },
            );
          } else {
            return const Authpage();
          }
        },
      ),
    );
  }
}
