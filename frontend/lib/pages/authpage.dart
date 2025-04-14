import 'package:flutter/material.dart';
import 'package:frontend/pages/signup.dart';
import 'package:frontend/pages/login.dart';

class Authpage extends StatefulWidget {
  const Authpage({super.key});

  @override
  State<Authpage> createState() => _AuthpageState();
}

class _AuthpageState extends State<Authpage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) =>
      isLogin
          ? LoginPage(onClickedSignUp: toggle)
          : SignupPage(onClickedSignIn: toggle);

  void toggle() {
    setState(() {
      isLogin = !isLogin;
    });
  }
}
