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

class ShowRequest extends StatefulWidget {
  const ShowRequest({
    super.key,
    required this.request,
    required this.requestedBy,
    required this.requestedTo,
  });
  final SwapRequestModel request;
  final User requestedBy;
  final User requestedTo;

  @override
  State<ShowRequest> createState() => _ShowRequestState();
}

class _ShowRequestState extends State<ShowRequest> {
  bool editing = false;
  Set skillsOffering = {};

  @override
  void initState() {
    super.initState();
    skillsOffering.addAll(widget.request.skillsOffering);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Swap Request"),
        centerTitle: true,
        actions: [
          if (!editing && !widget.request.counter)
            IconButton(
              onPressed: () {
                setState(() {
                  editing = true;
                });
              },
              icon: Icon(Icons.edit),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Skills ${widget.requestedBy.name} want to learn",
                        style: TextStyle(fontSize: medium),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  Wrap(
                    children: [
                      for (String skill in widget.request.skillsNeeded)
                        skillElement(
                          skill,
                          Set<String>.from(widget.request.skillsNeeded),
                          false,
                        ),
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
                        "Skills ${widget.requestedBy.name.toString().split(' ')[0]} wants to offer",
                        style: TextStyle(fontSize: medium),
                      ),
                      if (editing)
                        InkWell(
                          onTap: () async {
                            final skills = await Navigator.of(context).push(
                              transitionToNextScreen(
                                ShowSkills(
                                  skills: widget.requestedBy.skills!,
                                  appBarTitle: "Select Skill to learn",
                                  selection: true,
                                  selectedSkills: skillsOffering,
                                ),
                              ),
                            );
                            if (skills is Set) {
                              skillsOffering = skills;
                              setState(() {});
                            }
                          },
                          child: Icon(Icons.add),
                        ),
                    ],
                  ),
                  SizedBox(height: 15),

                  Wrap(
                    children: [
                      for (String skill in skillsOffering)
                        skillElement(skill, skillsOffering, true),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (widget.request.message.isNotEmpty)
              Text(
                '  Message',
                style: TextStyle(
                  fontSize: medium,
                  fontWeight: FontWeight.w500,
                  height: 2,
                ),
              ),
            if (widget.request.message.isNotEmpty)
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 68, 78, 87),
                  border: Border.all(color: Colors.grey[600]!),
                ),
                child: Text(
                  widget.request.message,
                  style: TextStyle(fontSize: mediumSmall),
                ),
              ),

            const SizedBox(height: 20),
            if (widget.request.status == "Counter Accepted")
              Align(
                alignment: Alignment.center,
                child: Text(
                  "${widget.requestedBy.name.toString().split(" ")[0]} has accepted revised Swap.",
                  style: TextStyle(color: Colors.red, fontSize: mediumSmall),
                  textAlign: TextAlign.center,
                ),
              ),
            const Spacer(),

            if (widget.request.status != "Counter offered")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (editing) {
                        //Logic to create a counter offer

                        final proceed = await showConfirmationDialog();
                        if (proceed != true) {
                          return;
                        }
                        showLoadingPopup(context, "Creating Counter Offer");
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.request.userId)
                            .update({
                              "swapRequestsMade.${widget.request.requestId}":
                                  widget.request
                                      .copyWith(
                                        userId: UserController.user.email,
                                        skillsOffering: skillsOffering.toList(),
                                        unread: 1,
                                        counter: true,
                                        status: "Counter offered",
                                      )
                                      .toJson(),
                            });
                        await UserController.update({
                          "swapRequestsReceived.${widget.request.requestId}":
                              widget.request
                                  .copyWith(
                                    counter: true,
                                    unread: 0,
                                    status: "Counter offered",
                                    skillsOffering: skillsOffering.toList(),
                                  )
                                  .toJson(),
                        });
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      } else {
                        //Logic to accept
                        showLoadingPopup(context, "Accepting Swap");
                        SwapModel swap = SwapModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          userId: widget.requestedTo.email!,
                          skillsNeeded: widget.request.skillsNeeded,
                          skillsOffering: widget.request.skillsOffering,
                          createdOn: Timestamp.now(),
                        );

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.request.userId)
                            .update({
                              "swapRequestsMade.${widget.request.requestId}":
                                  FieldValue.delete(),
                              'activeSwaps.${swap.id}': swap.toJson(),
                            });
                        swap = SwapModel(
                          id: swap.id,
                          userId: widget.request.userId,
                          skillsNeeded: swap.skillsOffering,
                          skillsOffering: swap.skillsNeeded,
                          createdOn: swap.createdOn,
                        );
                        await UserController.update({
                          "swapRequestsReceived.${widget.request.requestId}":
                              FieldValue.delete(),
                          'activeSwaps.${swap.id}': swap.toJson(),
                        });
                        Toast.showToast(message: "Swap Accepted!");
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.grey[700]!),
                      ),
                    ),
                    child: Text(
                      editing ? "  Create Counter Offer  " : "  Accept  ",
                      style: TextStyle(fontSize: medium, height: 2),
                    ),
                  ),
                  if (!editing)
                    ElevatedButton(
                      onPressed: () async {
                        showLoadingPopup(context, "Updating Swap");
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.request.userId)
                            .update({
                              "swapRequestsMade.${widget.request.requestId}":
                                  widget.request
                                      .copyWith(
                                        userId: UserController.user.email,
                                        unread: 1,
                                        status: "Declined",
                                      )
                                      .toJson(),
                            });
                        await UserController.update({
                          "swapRequestsReceived.${widget.request.requestId}":
                              widget.request
                                  .copyWith(unread: 0, status: "Declined")
                                  .toJson(),
                        });
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.grey[700]!),
                        ),
                      ),
                      child: Text(
                        "  Decline  ",
                        style: TextStyle(fontSize: medium, height: 2),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget skillElement(String skill, Set skills, bool isEditable) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color.fromARGB(255, 92, 92, 92),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(skill.capitalize(), style: TextStyle(fontSize: mediumSmall)),
          if (isEditable && editing) const SizedBox(width: 5),
          if (isEditable && editing)
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

  Future showConfirmationDialog() async {
    return showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "You can create a counter offer only once. Are you sure you want to create one?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: mediumSmall,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text("  Yes  "),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("  No  "),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
