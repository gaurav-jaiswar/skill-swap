import 'package:flutter/material.dart';
import 'package:skill_swap/utils/constants.dart';
import 'package:skill_swap/utils/extensions.dart';

class ShowSkills extends StatefulWidget {
  const ShowSkills({
    super.key,
    required this.skills,
    required this.appBarTitle,
    required this.selection,
    this.isOwner,
    this.selectedSkills,
  });
  final List skills;
  final String appBarTitle;
  final bool selection;
  final bool? isOwner;
  final Set? selectedSkills;

  @override
  State<ShowSkills> createState() => _ShowSkillsState();
}

class _ShowSkillsState extends State<ShowSkills> {
  Set selectedSkills = {};
  List skills = [];

  @override
  void initState() {
    super.initState();
    selectedSkills.addAll(widget.selectedSkills ?? {});
    skills.addAll(widget.skills);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.appBarTitle), titleSpacing: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: skills.length,
                itemBuilder:
                    (context, index) => ListTile(
                      title: Text(skills[index].toString().capitalize()),
                      shape: Border(bottom: BorderSide(color: Colors.grey)),
                      minTileHeight: 50,
                      trailing:
                          widget.selection
                              ? Checkbox(
                                value: selectedSkills.contains(
                                  widget.skills[index],
                                ),
                                onChanged: (value) {
                                  if (value!) {
                                    selectedSkills.add(widget.skills[index]);
                                    setState(() {});
                                  } else {
                                    selectedSkills.remove(widget.skills[index]);
                                    setState(() {});
                                  }
                                },
                              )
                              : widget.isOwner == true
                              ? IconButton(
                                onPressed: () {
                                  selectedSkills.add(skills.removeAt(index));
                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                                icon: Icon(Icons.delete_outline),
                              )
                              : null,
                    ),
              ),
            ),
            if (widget.selection || widget.isOwner == true)
              ElevatedButton(
                onPressed: () {
                  if (widget.selection || widget.isOwner == true) {
                    Navigator.of(
                      context,
                    ).pop(selectedSkills.isNotEmpty ? selectedSkills : null);
                  }
                },
                child: Text(
                  widget.isOwner == true ? '   Update   ' : '   Proceed   ',
                  style: TextStyle(fontSize: medium),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
