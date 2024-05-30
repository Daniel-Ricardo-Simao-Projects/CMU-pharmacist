import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/pages/user_ratings/ratings_data.dart';

class RatingsGraph extends StatelessWidget {
  final Map<int, int> histogram;
  const RatingsGraph({super.key, required this.histogram});

  @override
  Widget build(BuildContext context) {
    RatingData myRatings = RatingData(
      oneStar: histogram[1] ?? 0,
      twoStar: histogram[2] ?? 0,
      threeStar: histogram[3] ?? 0,
      fourStar: histogram[4] ?? 0,
      fiveStar: histogram[5] ?? 0,
    );

    myRatings.initializeRatingData();
    return BarChart(BarChartData(
      maxY: 40,
      minY: 0,
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(
        show: true,
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barGroups: myRatings.ratingData.map((data) {
        return BarChartGroupData(x: data.x, barRods: [
          BarChartRodData(
            width: 20,
            toY: data.y.toDouble(),
            color: Colors.amber,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 40,
              color: Colors.grey[300],
            ),
          )
        ]);
      }).toList(),
    ));
  }
}
