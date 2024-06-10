import 'package:flutter/material.dart';

class AppBarBackButton extends StatelessWidget {
  const AppBarBackButton({super.key,required this.onPressed,});
final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        Theme.of(context).platform == TargetPlatform.android
            ? Icons.arrow_back
            : Icons.arrow_back_ios_new,
      ),
    );
  }
}
