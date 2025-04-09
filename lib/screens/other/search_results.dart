import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_swap/controllers/user_controller.dart';
import 'package:skill_swap/screens/other/profile_screen.dart';
import 'package:skill_swap/utils/constants.dart';
import 'package:skill_swap/utils/transition.dart';

class SearchResults extends StatefulWidget {
  const SearchResults({super.key, required this.searchValue});
  final String searchValue;

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  bool isLoading = true;
  List results = [];
  List usersData = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> users = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    users =
        (await FirebaseFirestore.instance
                .collection('users')
                .where('skills', arrayContains: widget.searchValue)
                .get())
            .docs;
    if (mounted) {
      isLoading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          users.isNotEmpty
                              ? "Showing People who have ${widget.searchValue} as their skill."
                              : "No users found with searched skill",
                          style: TextStyle(fontSize: medium),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    if (users.isNotEmpty)
                      Divider(color: Colors.grey, indent: 10, endIndent: 10),
                    if (users.isNotEmpty)
                      Flexible(
                        child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder:
                              (context, index) =>
                                  users[index].id == UserController.user.email
                                      ? SizedBox.shrink()
                                      : ListTile(
                                        leading: CircleAvatar(
                                          radius: 18,
                                          foregroundImage:
                                              users[index]
                                                          .data()["profilePic"] ==
                                                      null
                                                  ? users[index]
                                                              .data()["gender"] ==
                                                          "Male"
                                                      ? AssetImage(
                                                        'assets/images/avatarm.png',
                                                      )
                                                      : AssetImage(
                                                        'assets/images/avatarf.png',
                                                      )
                                                  : NetworkImage(
                                                    users[index]
                                                        .data()['profilePic'],
                                                  ),
                                        ),
                                        title: Text(
                                          users[index].data()['name'],
                                        ),
                                        onTap:
                                            () => Navigator.of(context).push(
                                              transitionToNextScreen(
                                                ProfileScreen(
                                                  user: User.fromJson(
                                                    users[index].data(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                      ),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}
