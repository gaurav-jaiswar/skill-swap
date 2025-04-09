import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_swap/controllers/models.dart';
import 'package:skill_swap/controllers/user_controller.dart';
import 'package:skill_swap/screens/other/show_request.dart';
import 'package:skill_swap/screens/other/show_request_made.dart';
import 'package:skill_swap/utils/constants.dart';
import 'package:skill_swap/utils/extensions.dart';
import 'package:skill_swap/utils/transition.dart';

class SwapRequestTile extends StatefulWidget {
  const SwapRequestTile({
    super.key,
    required this.swapData,
    required this.isRequestReceived,
  });
  final SwapRequestModel swapData;
  final bool isRequestReceived;

  @override
  State<SwapRequestTile> createState() => _SwapRequestTileState();
}

class _SwapRequestTileState extends State<SwapRequestTile> {
  late User user;
  late User userRequested;
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
    if (widget.isRequestReceived) {
      userRequested = user;
      user = UserController.user;
    } else {
      userRequested = UserController.user;
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
            if (user.email == UserController.user.email) {
              Navigator.of(context).push(
                transitionToNextScreen(
                  ShowRequest(
                    request: widget.swapData,
                    requestedBy: userRequested,
                    requestedTo: user,
                  ),
                ),
              );
            } else {
              Navigator.of(context).push(
                transitionToNextScreen(
                  ShowRequestMade(
                    request: widget.swapData,
                    requestedBy: userRequested,
                    requestedTo: user,
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
              border: Border.all(
                color:
                    widget.swapData.unread > 0
                        ? Colors.amberAccent
                        : Colors.grey[600]!,
              ),
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
                            userRequested.profilePic == null
                                ? userRequested.gender == "Male"
                                    ? AssetImage('assets/images/avatarm.png')
                                    : AssetImage('assets/images/avatarf.png')
                                : NetworkImage(userRequested.profilePic!),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              userRequested.name ?? "User Name",
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
