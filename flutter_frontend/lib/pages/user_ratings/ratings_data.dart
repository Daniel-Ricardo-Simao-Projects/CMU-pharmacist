import 'package:flutter_frontend/pages/user_ratings/individual_bar.dart';

class RatingData {
  final int oneStar;
  final int twoStar;
  final int threeStar;
  final int fourStar;
  final int fiveStar;

  RatingData({
      required this.oneStar,
      required this.twoStar,
      required this.threeStar,
      required this.fourStar,
      required this.fiveStar
  });

  List<IndividualBar> ratingData = [];

  void initializeRatingData() {
    ratingData = [
      IndividualBar(x: 1, y: oneStar),
      IndividualBar(x: 2, y: twoStar),
      IndividualBar(x: 3, y: threeStar),
      IndividualBar(x: 4, y: fourStar),
      IndividualBar(x: 5, y: fiveStar),
    ];
  }
}
