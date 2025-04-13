import 'package:flutter/material.dart';
import 'models/search_page.dart';

void main() {
  runApp(const MainApp(
    home: SearchPage(),
    debugShowCheckedModeBanner: false,
  ));
}
class MainApp extends StatelessWidget {
  final Widget home;
  final bool debugShowCheckedModeBanner;

  const MainApp({
    super.key,
    required this.home,
    this.debugShowCheckedModeBanner = true,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: home,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
    );
  }
}

