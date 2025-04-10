import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/workout_data.dart';
import 'dart:math' as math;  // Import dart:math with an alias

class MyHeatMap2 extends StatelessWidget {
  const MyHeatMap2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final workoutData = Provider.of<WorkoutData>(context);
    final Map<DateTime, int> heatMapData = workoutData.getWorkoutDatesForHeatMap2();

    // Debug: Print the heatmap data to see what's being retrieved
   // print("HeatMap Data: $heatMapData");

    // Get the last 30 days
    final List<DateTime> last30Days = List.generate(
      30,
          (index) {
        DateTime rawDay = DateTime.now().subtract(Duration(days: index));
        return DateTime(rawDay.year, rawDay.month, rawDay.day);  // Normalize to start of the day
      },
    );

    // Debug: Print last 30 days to ensure they are correct
   // print("Last 30 Days: $last30Days");

    // Split the days into 3 rows
    const int columns = 10; // Number of columns per row
    final List<List<DateTime>> rows = List.generate(
      3,
          (rowIndex) => last30Days.sublist(rowIndex * columns, math.min((rowIndex + 1) * columns, last30Days.length)),
    );

    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Color.fromRGBO(31, 31, 31, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 7),
          Column(
            children: rows.map((row) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: row.map((day) {
                  final activityLevel = heatMapData[day] ?? 0;
                  return Container(
                    width: MediaQuery.of(context).size.width / 45,
                    height: MediaQuery.of(context).size.width / 45,
                    margin: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      color: activityLevel > 0 ? Colors.blue : Colors.grey[700], // Change to green for visibility
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
