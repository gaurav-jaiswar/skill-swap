import 'package:flutter/material.dart';
import 'package:skill_swap/utils/constants.dart';

class Community extends StatelessWidget {
  const Community({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: const Text(
        "Community\nComing Soon...",
        style: TextStyle(fontSize: large, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }
}
