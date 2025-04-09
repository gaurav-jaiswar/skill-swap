import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_swap/controllers/user_controller.dart';
import 'package:skill_swap/utils/constants.dart';
import 'package:skill_swap/widgets/loading_popup.dart';

class RatingsWidget extends StatefulWidget {
  const RatingsWidget({
    super.key,
    required this.rating,
    required this.user,
    required this.swapId,
  });
  final int rating;
  final User user;
  final String swapId;

  @override
  State<RatingsWidget> createState() => _RatingsWidegtStgee();
}

class _RatingsWidegtStgee extends State<RatingsWidget> {
  int rating = 0;
  @override
  void initState() {
    super.initState();
    rating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color.fromARGB(255, 68, 78, 87),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 1; i <= 5; i++)
                InkWell(
                  onTap:
                      () => setState(() {
                        rating = i;
                      }),
                  child: Icon(
                    rating >= i
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amberAccent,
                    size: 40,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Rate ${widget.user.name!.split(' ')[0]} based on your Swap.",
            style: TextStyle(
              fontSize: mediumSmall,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              showLoadingPopup(context, "Submitting...");
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.user.email)
                  .update({'ratings.${widget.swapId}': rating});
              widget.user.ratings =
                  (await FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.user.email)
                          .get())
                      .data()!['ratings'] ??
                  {};
              Navigator.of(context).pop();
            },
            child: Text('Submit', style: TextStyle(fontSize: mediumSmall)),
          ),
        ],
      ),
    );
  }
}
