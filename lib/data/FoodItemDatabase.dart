import 'package:hive/hive.dart';
part 'FoodItemDatabase.g.dart';  // This file will be generated by the Hive generator

@HiveType(typeId: 3)
class FoodItemDatabase {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String calories;
  @HiveField(3)
  final String protein;
  @HiveField(4)
  final String carbs;
  @HiveField(5)
  final String fats;
  @HiveField(6)
  final DateTime date;

  FoodItemDatabase({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.date,
  });
}
