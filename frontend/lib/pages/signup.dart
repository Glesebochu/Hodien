import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  final VoidCallback onClickedSignIn;

  const SignupPage({super.key, required this.onClickedSignIn});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
