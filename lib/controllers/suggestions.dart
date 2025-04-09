import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_swap/utils/extensions.dart';

class Suggestions {
  static List<MapEntry> getSuggestions(Map data) {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> users =
        data['users'];
    final Set skills = data['skills'];
    final userId = data['userId'];
    List<MapEntry> result = [];
    for (var user in users) {
      if (user.id == userId) {
        continue;
      }
      final skills2 = Set.from(user.data()['skills']);
      final commonSkills = skills.intersection(skills2);
      if (commonSkills.isNotEmpty) {
        String skills = '';
        for (var skill in commonSkills) {
          skills += "${skill.toString().capitalize()}, ";
        }
        result.add(MapEntry(skills, user.data()));
      }
    }
    return result;
  }
}
