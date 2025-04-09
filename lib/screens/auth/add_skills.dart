import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skill_swap/controllers/user_controller.dart' as uc;
import 'package:skill_swap/screens/homescreen.dart';
import 'package:skill_swap/screens/other/skills_search.dart';
import 'package:skill_swap/utils/constants.dart';
import 'package:skill_swap/utils/extensions.dart';
import 'package:skill_swap/utils/transition.dart';
import 'package:skill_swap/widgets/loading_popup.dart';

class AddSkillsPage extends StatefulWidget {
  const AddSkillsPage({super.key, required this.isSkillWanted, this.update});
  final bool isSkillWanted;
  final bool? update;

  @override
  State<AddSkillsPage> createState() => _AddSkillsPageState();
}

class _AddSkillsPageState extends State<AddSkillsPage> {
  late Map<String, dynamic> data;
  bool isLoading = true;
  Set skills = {};
  Set selectedSkills = {};
  User? _user;

  @override
  void initState() {
    super.initState();
    loadData();
    _user = FirebaseAuth.instance.currentUser;
  }

  void loadData() async {
    data =
        (await FirebaseFirestore.instance
                .collection('data')
                .doc("skills")
                .get())
            .data()!;
    skills.addAll(data['skills']);
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  void saveSkills() async {
    if (selectedSkills.isEmpty || _user == null) {
      return;
    }
    showLoadingPopup(context, 'Updating...');
    final userEmail = _user!.email!.trim();
    final db = FirebaseFirestore.instance;
    final newSkills = selectedSkills.difference(skills);
    final existingSkills = selectedSkills.intersection(skills);

    final dbBatch = db.batch();
    dbBatch.update(db.collection("users").doc(userEmail), {
      'skills': FieldValue.arrayUnion(selectedSkills.toList()),
    });

    for (String skill in existingSkills) {
      dbBatch.update(db.collection('skills').doc(skill), {
        'users': FieldValue.arrayUnion([userEmail]),
      });
    }

    for (String skill in newSkills) {
      dbBatch.set(db.collection('skills').doc(skill), {
        'category': '',
        'users': [userEmail],
      });
    }

    dbBatch.update(db.collection('data').doc("skills"), {
      "newSkills": FieldValue.arrayUnion(newSkills.toList()),
      "skills": FieldValue.arrayUnion(newSkills.toList()),
    });
    await dbBatch.commit();
    Navigator.of(context).pop();
    if (widget.update == true) {
      await uc.UserController.init();
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).pushReplacement(
        transitionToNextScreen(const AddSkillsPage(isSkillWanted: true)),
      );
    }
  }

  void saveWantedSkills() async {
    if (selectedSkills.isEmpty || _user == null) {
      return;
    }
    await uc.UserController.update({
      'skillsNeeded': FieldValue.arrayUnion(selectedSkills.toList()),
    });
    if (widget.update == true) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        transitionToNextScreen(const Homescreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: widget.update ?? false,
        title: Text(
          "Add Skills",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: mediumLarge),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Add Skill ${widget.isSkillWanted ? "you want to learn" : "you are willing to share."}",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: medium),
            ),
            const SizedBox(height: 20),
            Text("Skill*", style: TextStyle(fontSize: medium - 2)),
            InkWell(
              onTap: () async {
                final data = await Navigator.of(context).push(
                  transitionToNextScreen(
                    SearchScreen(searchData: skills.toList()),
                  ),
                );
                if (data is String && data.isNotEmpty) {
                  selectedSkills.add(data);
                  setState(() {});
                }
              },
              child: Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                width: double.maxFinite,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[400]!, width: 1.5),
                  ),
                ),
                child: Text(
                  "Skill (ex: Guitar, Badminton, Calligraphy)",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: mediumSmall + 1,
                  ),
                ),
              ),
            ),
            Wrap(
              children: [
                for (String skill in selectedSkills) skillElement(skill),
              ],
            ),
            Expanded(child: SizedBox.expand()),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (widget.isSkillWanted) {
                    saveWantedSkills();
                  } else {
                    saveSkills();
                  }
                },
                child: Text(
                  "Add  +",
                  style: TextStyle(
                    fontSize: mediumSmall,
                    color: Color.fromARGB(255, 165, 248, 230),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget skillElement(String skill) {
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
              onTap: () => setState(() => selectedSkills.remove(skill)),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
