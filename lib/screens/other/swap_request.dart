import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_swap/controllers/models.dart';
import 'package:skill_swap/controllers/user_controller.dart';
import 'package:skill_swap/screens/other/show_skills.dart';
import 'package:skill_swap/utils/constants.dart';
import 'package:skill_swap/utils/extensions.dart';
import 'package:skill_swap/utils/toast.dart';
import 'package:skill_swap/utils/transition.dart';
import 'package:skill_swap/widgets/loading_popup.dart';

class SwapRequest extends StatefulWidget {
  const SwapRequest({super.key, required this.skills, required this.userId});
  final List skills;
  final String userId;

  @override
  State<SwapRequest> createState() => _SwapRequestState();
}

class _SwapRequestState extends State<SwapRequest> {
  Set skillsOffering = {};
  Set skillsNeeded = {};
  TextEditingController message = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Swap Request'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
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
                        "Add Skills you want to offer",
                        style: TextStyle(fontSize: medium),
                      ),
                      InkWell(
                        onTap: () async {
                          final skills = await Navigator.of(context).push(
                            transitionToNextScreen(
                              ShowSkills(
                                skills: UserController.user.skills!,
                                appBarTitle: "Select Skill to offer",
                                selection: true,
                                selectedSkills: skillsOffering,
                              ),
                            ),
                          );
                          if (skills is Set) {
                            skillsOffering.addAll(skills);
                            setState(() {});
                          }
                        },
                        child: Icon(Icons.add),
                      ),
                    ],
                  ),
                  if (skillsOffering.isNotEmpty) SizedBox(height: 15),
                  if (skillsOffering.isNotEmpty)
                    Wrap(
                      children: [
                        for (String skill in skillsOffering)
                          skillElement(skill, skillsOffering),
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
                        "Add Skills you want to learn",
                        style: TextStyle(fontSize: medium),
                      ),
                      InkWell(
                        onTap: () async {
                          final skills = await Navigator.of(context).push(
                            transitionToNextScreen(
                              ShowSkills(
                                skills: widget.skills,
                                appBarTitle: "Select Skill to learn",
                                selection: true,
                                selectedSkills: skillsNeeded,
                              ),
                            ),
                          );
                          if (skills is Set) {
                            skillsNeeded.addAll(skills);
                            setState(() {});
                          }
                        },
                        child: Icon(Icons.add),
                      ),
                    ],
                  ),
                  if (skillsNeeded.isNotEmpty) SizedBox(height: 15),
                  if (skillsNeeded.isNotEmpty)
                    Wrap(
                      children: [
                        for (String skill in skillsNeeded)
                          skillElement(skill, skillsNeeded),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              focusNode: focusNode,
              onTapOutside: (event) => focusNode.unfocus(),
              controller: message,
              minLines: 3,
              maxLines: 7,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusColor: const Color.fromARGB(255, 68, 78, 87),
                fillColor: const Color.fromARGB(255, 68, 78, 87),
                hintText: "Message (Optional)",
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed:
                  skillsNeeded.isNotEmpty && skillsOffering.isNotEmpty
                      ? () async {
                        showLoadingPopup(context, "Creating Swap Request...");
                        final request = SwapRequestModel(
                          requestId:
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          userId: UserController.user.email!,
                          skillsNeeded: skillsNeeded.toList(),
                          skillsOffering: skillsOffering.toList(),
                          createdOn: Timestamp.now(),
                          status: "Pending",
                          message: message.text,
                          unread: 1,
                        );

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.userId)
                            .update({
                              "swapRequestsReceived.${request.requestId}":
                                  request.toJson(),
                            });

                        request.userId = widget.userId;
                        request.unread = 0;
                        await UserController.update({
                          "swapRequestsMade.${request.requestId}":
                              request.toJson(),
                        });
                        Toast.showToast(message: "Swap Created successfully");
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.grey[700]!),
                ),
              ),
              child: Text(
                "  Create Request  ",
                style: TextStyle(fontSize: medium, height: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget skillElement(String skill, Set skills) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color.fromARGB(255, 92, 92, 92),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(skill.capitalize()),
          const SizedBox(width: 5),
          Transform.rotate(
            angle: 3.147 / 4,
            child: InkWell(
              onTap: () => setState(() => skills.remove(skill)),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
