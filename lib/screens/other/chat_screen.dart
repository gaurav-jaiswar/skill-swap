import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_swap/controllers/user_controller.dart';
import 'package:skill_swap/screens/other/profile_screen.dart';
import 'package:skill_swap/utils/transition.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.userId, this.fromHome = true});
  final String userId;
  final bool fromHome;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Stream<DocumentSnapshot<Map<String, dynamic>>>? chatStream;
  late DocumentReference<Map<String, dynamic>> channelRef;
  TextEditingController message = TextEditingController();
  late Map personInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getChannel();
  }

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  void getChannel() async {
    if (widget.fromHome ||
        UserController.user.chats!.containsKey(widget.userId)) {
      personInfo = UserController.user.chats![widget.userId];
      final channel = personInfo['channel'];
      channelRef = FirebaseFirestore.instance.collection('chats').doc(channel);
      chatStream = channelRef.snapshots();
    } else {
      final otherUser = User.fromJson(
        (await FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userId)
                .get())
            .data()!,
      );
      final docId = await FirebaseFirestore.instance.collection('chats').add({
        "messages": [],
      });
      UserController.update({
        FieldPath(['chats', otherUser.email!]): {
          'name': otherUser.name!,
          'profilePic': otherUser.profilePic,
          'unread': 0,
          'channel': docId.id,
          'email': otherUser.email,
          'lastModified': Timestamp.now(),
          'gender': otherUser.gender,
        },
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUser.email!)
          .update({
            FieldPath(['chats', UserController.user.email!]): {
              'name': UserController.user.name!,
              'profilePic': UserController.user.profilePic,
              'unread': 0,
              'channel': docId.id,
              'email': UserController.user.email!,
              'lastModified': Timestamp.now(),
              'gender': UserController.user.gender,
            },
          });
      channelRef = docId;
      chatStream = docId.snapshots();
      personInfo = {
        'name': otherUser.name!,
        'profilePic': otherUser.profilePic,
        'unread': 0,
        'channel': docId.id,
        'email': otherUser.email,
        'lastModified': Timestamp.now(),
        'gender': otherUser.gender,
      };
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void sendMessage(String message) {
    channelRef.update({
      'messages': FieldValue.arrayUnion([
        {
          'message': message.trim(),
          'sender': UserController.user.email!,
          'time': Timestamp.now(),
        },
      ]),
    });
    FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
      FieldPath([
        'chats',
        UserController.user.email!,
        'unread',
      ]): FieldValue.increment(1),
      FieldPath(['chats', UserController.user.email!, 'lastModified']):
          Timestamp.now(),
    });

    UserController.update({
      FieldPath(['chats', widget.userId, 'lastModified']): Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
          appBar: AppBar(
            leadingWidth: 64,
            leading: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back),
                  CircleAvatar(
                    radius: 20,
                    foregroundImage:
                        personInfo["profilePic"] == null
                            ? personInfo["gender"] == "Male"
                                ? AssetImage('assets/images/avatarm.png')
                                : AssetImage('assets/images/avatarf.png')
                            : NetworkImage(personInfo['profilePic']),
                  ),
                ],
              ),
            ),
            title: InkWell(
              onTap: () {
                if (widget.fromHome) {
                  Navigator.of(context).push(
                    transitionToNextScreen(
                      ProfileScreen(user: User.fromJson(personInfo)),
                    ),
                  );
                }
              },
              child: Text(personInfo['name']),
            ),
            titleSpacing: 10,
          ),
          body:
              chatStream == null
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: StreamBuilder<
                            DocumentSnapshot<Map<String, dynamic>>
                          >(
                            stream: chatStream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox.shrink();
                              }
                              final messages =
                                  (snapshot.data!.data()!['messages'] as List)
                                      .reversed
                                      .toList();
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(UserController.user.email)
                                  .update({
                                    FieldPath([
                                          'chats',
                                          widget.userId,
                                          'unread',
                                        ]):
                                        0,
                                  });
                              return ListView.builder(
                                reverse: true,
                                itemCount: messages.length,
                                itemBuilder:
                                    (context, index) => Align(
                                      alignment:
                                          messages[index]['sender'] ==
                                                  UserController.user.email
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                      child: Container(
                                        margin: const EdgeInsets.all(4),
                                        padding: const EdgeInsets.all(8),
                                        constraints: BoxConstraints(
                                          maxWidth:
                                              MediaQuery.sizeOf(context).width *
                                              .8,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              messages[index]['sender'] ==
                                                      UserController.user.email
                                                  ? Colors.blueAccent
                                                  : Colors.grey,
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(12),
                                            topRight: const Radius.circular(12),
                                            bottomLeft:
                                                messages[index]['sender'] ==
                                                        UserController
                                                            .user
                                                            .email
                                                    ? const Radius.circular(12)
                                                    : Radius.zero,
                                            bottomRight:
                                                messages[index]['sender'] ==
                                                        UserController
                                                            .user
                                                            .email
                                                    ? Radius.zero
                                                    : const Radius.circular(12),
                                          ),
                                        ),
                                        child: Text(messages[index]['message']),
                                      ),
                                    ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          autofocus: true,
                          controller: message,
                          maxLines: 4,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: "Enter Message",
                            suffix: InkWell(
                              onTap: () {
                                if (message.text.trim().isNotEmpty) {
                                  sendMessage(message.text);
                                  message.text = "";
                                }
                              },
                              child: Icon(Icons.send),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
        );
  }
}
