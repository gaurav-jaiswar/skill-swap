import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skill_swap/controllers/user_controller.dart';
import 'package:skill_swap/utils/extensions.dart';

class LoginProvider extends ChangeNotifier {
  bool isLoading = false;
  final auth = FirebaseAuth.instance;
  String? error;
  Future<bool> login(String id, String password, BuildContext context) async {
    if (id.isNotEmpty && password.isNotEmpty) {
      isLoading = true;
      notifyListeners();
      try {
        await auth.signInWithEmailAndPassword(email: id, password: password);
        await UserController.init();
        error = null;
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "invalid-credential":
            error = "User not found, Please Register";
            break;
          case "invalid-email":
            error = "Invalid Email";
            break;
          default:
            error = e.code.capitalize().replaceAll('-', " ");
        }
        isLoading = false;
        notifyListeners();
        return false;
      }
      isLoading = false;
      notifyListeners();
      return true;
    }
    return false;
  }
}

class RegisterProvider extends ChangeNotifier {
  String? gender;
  String? error;
  bool isLoading = false;
  bool showError = false;

  Future<bool> register({
    required String name,
    required String dob,
    required String email,
    required String password,
  }) async {
    if (name.isEmpty ||
        dob.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        gender == null) {
      showError = true;
      notifyListeners();
      return false;
    }
    bool success = false;
    showError = true;
    isLoading = true;
    notifyListeners();
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseFirestore.instance.collection("users").doc(email).set({
        "name": name,
        "dob": dob,
        "gender": gender,
        'email': email,
        'skills': [], //
        "skillsNeeded": [], //
        'availability': [], //
        "bio": null, //
        "ratings": {},
        "profilePic": null,
        "coverPic": null,
        "activeSwaps": {},
        "completedSwaps": {},
        'chats': {},
        'swapRequestsMade': {},
        'swapRequestsReceived': {},
      });
      success = true;
    } on FirebaseAuthException catch (e) {
      error = e.code.capitalize().replaceAll("-", " ");
      success = false;
    }
    showError = true;
    isLoading = false;
    notifyListeners();
    return success;
  }
}
