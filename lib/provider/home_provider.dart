import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:skill_swap/controllers/suggestions.dart';
import 'package:skill_swap/controllers/user_controller.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider() {
    init();
  }

  int pendingDetails = 0;
  List swapRequestsMade = [];
  List swapRequests = [];
  List activeSwaps = [];
  List completedSwaps = [];
  List<MapEntry> suggestions = [];
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? stream;

  void checkCompleteProfile() {
    pendingDetails = 0;
    final user = UserController.user;
    if (user.skills!.isEmpty) pendingDetails++;
    if (user.skillsNeeded!.isEmpty) pendingDetails++;
    // if (user.availability!.isEmpty) pendingDetails++;
    if (user.bio == null) pendingDetails++;
  }

  void init() {
    if (stream != null) {
      stream!.cancel();
    }
    checkCompleteProfile();
    getSuggestions();
    _getSwapRequests();
    stream = FirebaseFirestore.instance
        .collection('users')
        .doc(UserController.user.email)
        .snapshots()
        .listen((_) {
          _getSwapRequests();
          checkCompleteProfile();
        });
  }

  void _getSwapRequests() async {
    await UserController.init();
    swapRequestsMade = UserController.user.swapRequestsMade!.values.toList();
    swapRequests = UserController.user.swapRequestsReceived!.values.toList();
    activeSwaps = UserController.user.activeSwaps!.values.toList();
    completedSwaps = UserController.user.completedSwaps!.values.toList();
    swapRequests.removeWhere((request) => request['status'] == "Declined");
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  void clear() {
    swapRequests.clear();
    swapRequestsMade.clear();
    pendingDetails = 0;
  }

  void getSuggestions() async {
    final users =
        (await FirebaseFirestore.instance.collection('users').get()).docs;
    suggestions = await compute(Suggestions.getSuggestions, {
      'users': users,
      'skills': Set.from(UserController.user.skillsNeeded!),
      'userId': UserController.user.email,
    });
    notifyListeners();
  }
}
