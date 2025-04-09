import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_swap/controllers/user_controller.dart';
import 'package:skill_swap/screens/other/chat_screen.dart';
import 'package:skill_swap/utils/transition.dart';

class Chat extends StatelessWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(UserController.user.email!)
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: Text("No chats found"));
              }

              final chats =
                  snapshot.data!.data()!['chats'].values.toList() as List;
              chats.sort(
                (a, b) => a['lastModified'].compareTo(b['lastModified']),
              );
              return chats.isEmpty
                  ? Center(child: Text("No Chats found!"))
                  : ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(chats[index]['name']),
                        leading: CircleAvatar(
                          radius: 25,
                          foregroundImage:
                              chats[index]['profilePic'] == null
                                  ? chats[index]["gender"] == "Male"
                                      ? AssetImage('assets/images/avatarm.png')
                                      : AssetImage('assets/images/avatarf.png')
                                  : NetworkImage(chats[index]['profilePic']),
                        ),
                        trailing:
                            chats[index]['unread'] == 0
                                ? null
                                : Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.amberAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    chats[index]['unread'].toString(),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                        onTap:
                            () => Navigator.of(context).push(
                              transitionToNextScreen(
                                ChatScreen(userId: chats[index]['email']),
                              ),
                            ),
                      );
                    },
                  );
            },
          ),
        ),
      ],
    );
  }
}
