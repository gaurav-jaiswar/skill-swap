import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_swap/controllers/models.dart';
import 'package:skill_swap/controllers/user_controller.dart';
import 'package:skill_swap/screens/other/profile_screen.dart';
import 'package:skill_swap/screens/other/show_request_made.dart';
import 'package:skill_swap/utils/constants.dart';
import 'package:skill_swap/utils/transition.dart';
import 'package:skill_swap/widgets/loading_popup.dart';
import 'package:skill_swap/widgets/ratings.dart';

class CompleteSwapScreen extends StatelessWidget {
  const CompleteSwapScreen({
    super.key,

    required this.appBarTitle,
    required this.user,
    required this.swap,
    required this.isCompleted,
  });
  final SwapModel swap;
  final String appBarTitle;
  final User user;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Align(alignment: Alignment.centerLeft, child: Text("  Swap Mate")),
            ListTile(
              leading: CircleAvatar(
                radius: 18,
                foregroundImage:
                    user.profilePic == null
                        ? user.gender == "Male"
                            ? AssetImage('assets/images/avatarm.png')
                            : AssetImage('assets/images/avatarf.png')
                        : NetworkImage(user.profilePic!),
              ),
              title: Text(user.name ?? "User name"),
              onTap:
                  () => Navigator.of(
                    context,
                  ).push(transitionToNextScreen(ProfileScreen(user: user))),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.green[600]!),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color.fromARGB(255, 68, 78, 87),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        isCompleted
                            ? "Skills you learned"
                            : "Skills you want to learn",
                        style: TextStyle(fontSize: medium),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  Wrap(
                    children: [
                      for (String skill in swap.skillsNeeded)
                        SkillElement(skill: skill),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color.fromARGB(255, 68, 78, 87),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isCompleted
                            ? "Skills you shared"
                            : "Skills you are sharing",
                        style: TextStyle(fontSize: medium),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  Wrap(
                    children: [
                      for (String skill in swap.skillsOffering)
                        SkillElement(skill: skill),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            if (!isCompleted)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Note: ',
                    style: TextStyle(
                      fontSize: mediumSmall,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      "A Swap to be marked completed from both Swapmates to be completed",
                      style: TextStyle(fontSize: mediumSmall),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (swap.completed && !isCompleted)
              Text(
                "This swap has been marked completed by ${user.name!.split(' ')[0]}. ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: mediumSmall,
                  fontWeight: FontWeight.w500,
                  color: Colors.lightGreenAccent,
                ),
              ),

            if (isCompleted)
              RatingsWidget(
                rating: user.ratings![swap.id] ?? 0,
                user: user,
                swapId: swap.id,
              ),
            const Spacer(),
            if (!swap.completedByMe && !isCompleted)
              ElevatedButton(
                onPressed: () async {
                  if (swap.completed) {
                    showLoadingPopup(context, "Completing Swap");
                    await UserController.update({
                      "activeSwaps.${swap.id}": FieldValue.delete(),
                      'completedSwaps.${swap.id}': swap.toJson(),
                      'skills': FieldValue.arrayUnion(swap.skillsNeeded),
                      'skillsNeeded': FieldValue.arrayRemove(swap.skillsNeeded),
                    });
                    final swapJson =
                        (await FirebaseFirestore.instance
                                .collection('users')
                                .doc(swap.userId)
                                .get())
                            .data()!['activeSwaps'][swap.id];
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(swap.userId)
                        .update({
                          "activeSwaps.${swap.id}": FieldValue.delete(),
                          'completedSwaps.${swap.id}': swapJson,
                          'skills': FieldValue.arrayUnion(swap.skillsOffering),
                          'skillsNeeded': FieldValue.arrayRemove(
                            swap.skillsOffering,
                          ),
                        });
                  } else {
                    showLoadingPopup(context, "Updating Swap");
                    await UserController.update({
                      "activeSwaps.${swap.id}.completedByMe": true,
                    });
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(swap.userId)
                        .update({"activeSwaps.${swap.id}.completed": true});
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey[600]!),
                  ),
                ),
                child: Text(
                  'Complete Swap',
                  style: TextStyle(fontSize: medium),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
