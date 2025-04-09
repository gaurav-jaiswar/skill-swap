import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  SearchProvider() {
    getSearchData();
    searchController.addListener(() {
      results = [];
      results.addAll(
        searchData.where(
          (item) =>
              item.contains(searchController.text.toString().toLowerCase()),
        ),
      );
      notifyListeners();
    });
  }

  List searchData = [];
  List results = [];

  TextEditingController searchController = TextEditingController();

  void getSearchData() async {
    searchData = (await FirebaseFirestore.instance
            .collection('data')
            .doc('skills')
            .get())
        .get('skills');
  }

  void getUsers() {}
}
