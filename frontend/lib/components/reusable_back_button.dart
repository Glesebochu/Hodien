import 'package:flutter/material.dart';

class ReusableBackButton extends StatelessWidget {
  final Widget? redirectTo;

  const ReusableBackButton({super.key, this.redirectTo});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        if (redirectTo != null) {
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => redirectTo!));
        } else {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        }
      },
    );
  }
}
