import 'package:flutter/material.dart';
import 'package:skill_swap/controllers/user_controller.dart';
import 'package:skill_swap/screens/other/profile_screen.dart';
import 'package:skill_swap/utils/constants.dart';
import 'package:skill_swap/utils/transition.dart';

class SuggestionCard extends StatelessWidget {
  const SuggestionCard({super.key, required this.user, required this.skills});
  final User user;
  final String skills;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          () => Navigator.of(
            context,
          ).push(transitionToNextScreen(ProfileScreen(user: user))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: MediaQuery.sizeOf(context).width * .40,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 83, 92, 100),
          border: Border.all(color: Colors.grey[600]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              foregroundImage:
                  user.profilePic == null
                      ? user.gender == "Male"
                          ? AssetImage('assets/images/avatarm.png')
                          : AssetImage('assets/images/avatarf.png')
                      : NetworkImage(user.profilePic!),
            ),
            const SizedBox(height: 5),

            Text(
              user.name ?? "User Name",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: mediumSmall + 2,
                overflow: TextOverflow.ellipsis,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            Text(
              skills,
              maxLines: 2,
              style: TextStyle(overflow: TextOverflow.ellipsis),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
