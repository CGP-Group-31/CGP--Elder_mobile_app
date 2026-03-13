import 'package:flutter/material.dart';
import '../theme.dart';
import '../meals/meal_page.dart';

class MealsReminderScreen extends StatelessWidget {
  final String? initialMealTime;
  final String? initialScheduledFor;

  const MealsReminderScreen({
    super.key,
    this.initialMealTime,
    this.initialScheduledFor,
  });

  @override
  Widget build(BuildContext context) {
    return MealPage(
      initialMealTime: initialMealTime,
      initialScheduledFor: initialScheduledFor,
    );
  }
}