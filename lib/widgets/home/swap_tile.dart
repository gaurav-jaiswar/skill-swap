import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_swap/controllers/models.dart';
import 'package:skill_swap/controllers/user_controller.dart';
import 'package:skill_swap/screens/other/complete_swap.dart';
import 'package:skill_swap/utils/constants.dart';
import 'package:skill_swap/utils/extensions.dart';
import 'package:skill_swap/utils/transition.dart';

class SwapTile extends StatefulWidget {
  const SwapTile({
    super.key,
    required this.swapData,
    required this.isCompleted,
  });
  final SwapModel swapData;
  final bool isCompleted;

  @override
  State<SwapTile> createState() => _SwapTileState();
}

class _SwapTileState extends State<SwapTile> {
  late User user;
  bool isLoading = true;
  String skillsNeeded = '';
  String skillsOffering = '';

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    user = User.fromJson(
      (await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.swapData.userId)
              .get())
          .data()!,
    );
    for (String skill in widget.swapData.skillsNeeded) {
      skillsNeeded += "${skill.capitalize()}, ";
    }
    for (String skill in widget.swapData.skillsOffering) {
      skillsOffering += "${skill.capitalize()}, ";
    }
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? SizedBox.shrink()
        : InkWell(
          onTap: () {
            if (!widget.isCompleted) {
              Navigator.of(context).push(
                transitionToNextScreen(
                  CompleteSwapScreen(
                    user: user,
                    swap: widget.swapData,
                    appBarTitle: "Active Swap",
                    isCompleted: widget.isCompleted,
                  ),
                ),
              );
            } else {
              Navigator.of(context).push(
                transitionToNextScreen(
                  CompleteSwapScreen(
                    user: user,
                    swap: widget.swapData,
                    appBarTitle: "Completed Swap",
                    isCompleted: widget.isCompleted,
                  ),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color.fromARGB(255, 68, 78, 87),
              border: Border.all(color: Colors.grey[600]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width * .55,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(255, 83, 92, 100),
                    border: Border.all(color: Colors.grey[600]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        foregroundImage:
                            UserController.user.profilePic == null
                                ? UserController.user.gender == "Male"
                                    ? AssetImage('assets/images/avatarm.png')
                                    : AssetImage('assets/images/avatarf.png')
                                : NetworkImage(UserController.user.profilePic!),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              UserController.user.name ?? "User Name",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: mediumSmall + 2,
                              ),
                            ),

                            Text(
                              skillsOffering,
                              maxLines: 2,
                              style: TextStyle(overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.swap_vert_rounded, size: 40),
                ),

                Container(
                  width: MediaQuery.sizeOf(context).width * .55,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(255, 83, 92, 100),
                    border: Border.all(color: Colors.grey[600]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        foregroundImage:
                            user.profilePic == null
                                ? user.gender == "Male"
                                    ? AssetImage('assets/images/avatarm.png')
                                    : AssetImage('assets/images/avatarf.png')
                                : NetworkImage(user.profilePic!),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user.name ?? "User Name",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: mediumSmall + 2,
                              ),
                            ),

                            Text(
                              skillsNeeded,
                              maxLines: 2,
                              style: TextStyle(overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
