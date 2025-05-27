import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/authpage.dart';
import 'pages/home.dart';
import 'pages/humorTest.dart';
import 'pages/settings.dart';
import 'pages/search_page.dart';
import 'utils/utils.dart';
import './services/user_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Future main() async {
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
      home: const MainApp(),
      theme: shadcn.ThemeData(
        colorScheme: shadcn.ColorSchemes.lightYellow(),
        radius: 0.5,
      ),
    ),
  );
}

final navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hodien',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: Utils.messengerKey,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routes: {
        '/home':
            (context) => Home(toggleTheme: toggleTheme, isDarkMode: isDarkMode),
        '/settings': (context) => const SettingsPage(),
        '/humorTest': (context) => HumorTestScreen(),
        '/search': (context) => SearchPage(),
      },
      home: Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('something went wrong'));
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
                      toggleTheme: toggleTheme,
                      isDarkMode: isDarkMode,
                    );
                  }
                },
              );
            } else {
              return Authpage();
            }
          },
        ),
      ),
    );
  }
}
