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

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // runApp(const MainApp());

  runApp(
    shadcn.ShadcnApp(
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

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hodien',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: Utils.messengerKey,
      routes: {
        '/home': (context) => Home(),
        '/settings': (context) => const SettingsPage(),
        '/humorTest': (context) => HumorTestScreen(),
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
              // User is logged in, check if humor profile exists
              return FutureBuilder<bool>(
                future: UserService().checkHumorProfileExists(),
                builder: (context, profileSnapshot) {
                  if (profileSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (profileSnapshot.hasError ||
                      !(profileSnapshot.data ?? false)) {
                    // Profile doesn't exist, send to test
                    return HumorTestScreen();
                  } else {
                    return Home(); // Profile exists
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
