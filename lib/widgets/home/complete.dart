import 'package:flutter/material.dart';
import 'package:skill_swap/utils/constants.dart';

class CompleteProfile extends StatelessWidget {
  const CompleteProfile({super.key, required this.pendingDetails});
  final int pendingDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color.fromARGB(255, 68, 78, 87),
        border: Border.all(color: Colors.grey[600]!),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Complete Your Profile", style: TextStyle(fontSize: medium)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: (4 - pendingDetails) / 4,
            minHeight: 15,
            backgroundColor: const Color.fromARGB(255, 116, 114, 114),
            borderRadius: BorderRadius.circular(15),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text("${4 - pendingDetails} / 4"),
          ),
          const Text(
            'Complete Your Profile so others can know you well.',
            style: TextStyle(fontSize: mediumSmall),
          ),
          // const SizedBox(height: 10),
          // ElevatedButton(
          //   onPressed: () async{
          //     await Navigator.of(context).push(
          //       transitionToNextScreen(
          //         const AddSkillsPage(isSkillWanted: false, update: true),
          //       ),
          //     );
          //   },
          //   style: ElevatedButton.styleFrom(
          //     minimumSize: Size.zero,
          //     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //   ),
          //   child: const Text(
          //     "Complete ->",
          //     style: TextStyle(
          //       fontSize: mediumSmall,
          //       color: Color.fromARGB(255, 165, 248, 230),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
