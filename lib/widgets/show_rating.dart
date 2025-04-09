import 'package:flutter/material.dart';
import 'package:skill_swap/utils/constants.dart';

class ShowRatingWidget extends StatelessWidget {
  const ShowRatingWidget({super.key, required this.ratings});
  final List ratings;

  @override
  Widget build(BuildContext context) {
    int total = 0;
    for (int rating in ratings) {
      total += rating;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: Colors.amber),

        Text(
          "  ${ratings.isEmpty ? "0.0" : (total / ratings.length).toStringAsFixed(1)}",
          style: TextStyle(fontSize: medium),
        ),
      ],
    );
  }
}
