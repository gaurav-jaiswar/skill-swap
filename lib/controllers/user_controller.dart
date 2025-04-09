import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserController {
  UserController._();

  static late User user;

  static Future<void> init() async {
    user = User.fromJson(
      (await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.email)
              .get())
          .data()!,
    );
  }

  static Future<void> update(updateData) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .update(updateData);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    await init();
  }
}

class User {
  List? skills, availability, skillsNeeded;
  String? gender, dob, profilePic, name, bio, coverPic, email;
  Map? chats,
      swapRequestsMade,
      activeSwaps,
      completedSwaps,
      ratings,
      swapRequestsReceived;

  User.fromJson(Map json) {
    skills = json['skills'] ?? [];
    activeSwaps = json['activeSwaps'] ?? {};
    ratings = json['ratings'] ?? {};
    completedSwaps = json['completedSwaps'] ?? {};
    availability = json['availability'] ?? [];
    skillsNeeded = json['skillsNeeded'] ?? [];
    swapRequestsMade = json['swapRequestsMade'] ?? {};
    swapRequestsReceived = json['swapRequestsReceived'] ?? {};
    gender = json['gender'];
    dob = json['dob'];
    profilePic = json['profilePic'];
    name = json['name'];
    email = json['email'];
    bio = json['bio'];
    coverPic = json['coverPic'];
    chats = json['chats'] ?? {};
  }
}
