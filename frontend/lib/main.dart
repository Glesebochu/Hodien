import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/authpage.dart';
import 'pages/home.dart';
import 'pages/settings.dart';
import 'pages/search_page.dart';
import 'utils/utils.dart';
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
        colorScheme: shadcn.ColorSchemes.lightSlate(),
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
      routes: {
        '/home': (context) => HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/search': (context) => const SearchPage(), // From search-module
      },
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: Utils.messengerKey,
      home: Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('something went wrong'));
            } else if (snapshot.hasData) {
              return HomePage();
            } else {
              return Authpage();
            }
          },
        ),
      ),
    );
  }
}

// void main() {
//   runApp(const MainApp(home: SearchPage(), debugShowCheckedModeBanner: false));
// }

// class MainApp extends StatelessWidget {
//   final Widget home;
//   final bool debugShowCheckedModeBanner;

//   const MainApp({
//     super.key,
//     required this.home,
//     this.debugShowCheckedModeBanner = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: home,
//       debugShowCheckedModeBanner: debugShowCheckedModeBanner,
//     );
//   }
// }
