import 'package:flutter/material.dart';
import 'package:skill_swap/controllers/user_controller.dart';
import 'package:skill_swap/screens/navbar/profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Profile(user: user)));
  }
}
