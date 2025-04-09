import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_swap/controllers/models.dart';
import 'package:skill_swap/controllers/user_controller.dart';
import 'package:skill_swap/utils/constants.dart';
import 'package:skill_swap/utils/extensions.dart';
import 'package:skill_swap/widgets/loading_popup.dart';

class ShowRequestMade extends StatefulWidget {
  const ShowRequestMade({
    super.key,
    required this.request,
    required this.requestedBy,
    required this.requestedTo,
  });
  final SwapRequestModel request;
  final User requestedBy;
  final User requestedTo;

  @override
  State<ShowRequestMade> createState() => _ShowRequestMadeState();
}

class _ShowRequestMadeState extends State<ShowRequestMade> {
  Set skillsOffering = {};

  @override
  void initState() {
    super.initState();
    skillsOffering.addAll(widget.request.skillsOffering);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Swap Request"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.request.status == "Counter offered")
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Counter offer has been created by ${widget.requestedTo.name.toString().split(' ')[0]}. Please check the revised request.",
                  style: TextStyle(
                    fontSize: mediumSmall,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (widget.request.status == "Counter offered")
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
                        "Skills you want to learn",
                        style: TextStyle(fontSize: medium),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  Wrap(
                    children: [
                      for (String skill in widget.request.skillsNeeded)
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
                        widget.request.counter
                            ? "Skills ${widget.requestedTo.name.toString().split(' ')[0]} wants to learn"
                            : "Skills you are offering",
                        style: TextStyle(fontSize: medium),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  Wrap(
                    children: [
                      for (String skill in skillsOffering)
                        SkillElement(skill: skill),
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
            if (widget.request.status == "Declined")
              Text(
                "${widget.requestedTo.name.toString().split(" ")[0]} has declined for the swap you can delete this Swap.",
                style: TextStyle(color: Colors.red, fontSize: mediumSmall),
                textAlign: TextAlign.center,
              ),
            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (widget.request.counter &&
                    widget.request.status == "Counter offered")
                  ElevatedButton(
                    onPressed: () async {
                      //Logic to accept a counter offer
                      showLoadingPopup(context, "Accepting Counter Offer");
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.request.userId)
                          .update({
                            "swapRequestsReceived.${widget.request.requestId}":
                                widget.request
                                    .copyWith(
                                      userId: UserController.user.email,
                                      unread: 1,
                                      counter: true,
                                      status: "Counter Accepted",
                                    )
                                    .toJson(),
                          });
                      await UserController.update({
                        "swapRequestsMade.${widget.request.requestId}":
                            widget.request
                                .copyWith(
                                  counter: true,
                                  unread: 0,
                                  status: "Counter Accepted",
                                )
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
                      "  Accept  ",
                      style: TextStyle(fontSize: medium, height: 2),
                    ),
                  ),

                ElevatedButton(
                  onPressed: () async {
                    //Logic to delete request
                    showLoadingPopup(context, "Deleting request");
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.request.userId)
                        .update({
                          "swapRequestsReceived.${widget.request.requestId}":
                              FieldValue.delete(),
                        });
                    await UserController.update({
                      "swapRequestsMade.${widget.request.requestId}":
                          FieldValue.delete(),
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
                    "  Delete  ",
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
}

class SkillElement extends StatelessWidget {
  const SkillElement({super.key, required this.skill});

  final String skill;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color.fromARGB(255, 92, 92, 92),
      ),
      child: Text(skill.capitalize(), style: TextStyle(fontSize: mediumSmall)),
    );
  }
}
