import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../config/theme.dart';
import '../../models/food_log_model.dart';
import '../../providers/nutrition_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

const uuid = Uuid();

class NutritionPage extends ConsumerStatefulWidget {
  const NutritionPage({super.key});

  @override
  ConsumerState<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends ConsumerState<NutritionPage> {
  final _formKey = GlobalKey<FormState>();
  String _mealType = 'breakfast';
  String? _selectedFood;
  final _customFoodController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();

  // Common foods database (simplified)
  final Map<String, Map<String, dynamic>> _foodDatabase = {
    'Chicken Breast (100g)': {
      'calories': 165.0,
      'protein': 31.0,
      'carbs': 0.0,
      'fats': 3.6,
      'serving': 100.0,
      'unit': 'g'
    },
    'Brown Rice (1 cup)': {
      'calories': 216.0,
      'protein': 5.0,
      'carbs': 45.0,
      'fats': 1.8,
      'serving': 1.0,
      'unit': 'cup'
    },
    'Banana': {
      'calories': 105.0,
      'protein': 1.3,
      'carbs': 27.0,
      'fats': 0.4,
      'serving': 1.0,
      'unit': 'piece'
    },
    'Egg': {
      'calories': 78.0,
      'protein': 6.3,
      'carbs': 0.6,
      'fats': 5.3,
      'serving': 1.0,
      'unit': 'piece'
    },
    'Oatmeal (1 cup)': {
      'calories': 307.0,
      'protein': 11.0,
      'carbs': 55.0,
      'fats': 5.3,
      'serving': 1.0,
      'unit': 'cup'
    },
    'Salmon (100g)': {
      'calories': 206.0,
      'protein': 22.0,
      'carbs': 0.0,
      'fats': 13.0,
      'serving': 100.0,
      'unit': 'g'
    },
    'Avocado': {
      'calories': 234.0,
      'protein': 2.9,
      'carbs': 12.0,
      'fats': 21.0,
      'serving': 1.0,
      'unit': 'piece'
    },
    'Greek Yogurt (1 cup)': {
      'calories': 100.0,
      'protein': 17.0,
      'carbs': 6.0,
      'fats': 0.7,
      'serving': 1.0,
      'unit': 'cup'
    },
    'Apple': {
      'calories': 95.0,
      'protein': 0.5,
      'carbs': 25.0,
      'fats': 0.3,
      'serving': 1.0,
      'unit': 'piece'
    },
    'Almonds (28g)': {
      'calories': 164.0,
      'protein': 6.0,
      'carbs': 6.0,
      'fats': 14.0,
      'serving': 28.0,
      'unit': 'g'
    },
  };

  @override
  void dispose() {
    _customFoodController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  void _selectFood(String? food) {
    if (food != null && _foodDatabase.containsKey(food)) {
      final foodData = _foodDatabase[food]!;
      setState(() {
        _selectedFood = food;
        _servingSizeController.text = foodData['serving'].toString();
        _caloriesController.text = foodData['calories'].toString();
        _proteinController.text = foodData['protein'].toString();
        _carbsController.text = foodData['carbs'].toString();
        _fatsController.text = foodData['fats'].toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final foodLogs = ref.watch(foodLogsProvider);
    final totals = ref.watch(todayNutritionTotalsProvider);
    final calorieGoal = user?.dailyCalorieGoal ?? 2000;

    return Scaffold(
      backgroundColor: AppTheme.lightGreen,
      appBar: AppBar(
        title: const Text('Nutrition Tracker'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Daily nutrition dashboard
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Nutrition',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),

                    // Calories
                    _NutrientBar(
                      label: 'Calories',
                      value: totals.calories,
                      goal: calorieGoal.toDouble(),
                      unit: 'kcal',
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),

                    // Protein
                    _NutrientBar(
                      label: 'Protein',
                      value: totals.protein,
                      goal: (calorieGoal * 0.3 / 4), // 30% of calories, 4 cal/g
                      unit: 'g',
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),

                    // Carbs
                    _NutrientBar(
                      label: 'Carbs',
                      value: totals.carbs,
                      goal: (calorieGoal * 0.4 / 4), // 40% of calories, 4 cal/g
                      unit: 'g',
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),

                    // Fats
                    _NutrientBar(
                      label: 'Fats',
                      value: totals.fats,
                      goal: (calorieGoal * 0.3 / 9), // 30% of calories, 9 cal/g
                      unit: 'g',
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
            ),

            // Add food form
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Log Food',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),

                      // Meal type
                      DropdownButtonFormField<String>(
                        value: _mealType,
                        decoration: const InputDecoration(
                          labelText: 'Meal Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'breakfast', child: Text('Breakfast')),
                          DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
                          DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
                          DropdownMenuItem(value: 'snack', child: Text('Snack')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _mealType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Food selection
                      DropdownButtonFormField<String>(
                        value: _selectedFood,
                        decoration: const InputDecoration(
                          labelText: 'Select Food',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Custom Food'),
                          ),
                          ..._foodDatabase.keys.map((food) {
                            return DropdownMenuItem(
                              value: food,
                              child: Text(food),
                            );
                          }),
                        ],
                        onChanged: _selectFood,
                      ),
                      const SizedBox(height: 16),

                      // Custom food name
                      if (_selectedFood == null)
                        TextFormField(
                          controller: _customFoodController,
                          decoration: const InputDecoration(
                            labelText: 'Food Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (_selectedFood == null && (value == null || value.isEmpty)) {
                              return 'Please enter food name';
                            }
                            return null;
                          },
                        ),
                      if (_selectedFood == null) const SizedBox(height: 16),

                      // Nutritional info
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _servingSizeController,
                              decoration: const InputDecoration(
                                labelText: 'Serving',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _caloriesController,
                              decoration: const InputDecoration(
                                labelText: 'Calories',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _proteinController,
                              decoration: const InputDecoration(
                                labelText: 'Protein (g)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _carbsController,
                              decoration: const InputDecoration(
                                labelText: 'Carbs (g)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _fatsController,
                              decoration: const InputDecoration(
                                labelText: 'Fats (g)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: _logFood,
                        child: const Text('Log Food'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Food log history
            if (foodLogs.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Today\'s Meals',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: foodLogs.length,
                itemBuilder: (context, index) {
                  final log = foodLogs[foodLogs.length - 1 - index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getMealTypeColor(log.mealType),
                        child: Text(
                          log.mealType[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(log.foodName),
                      subtitle: Text(
                        '${log.calories.toInt()} kcal • P:${log.protein.toInt()}g C:${log.carbs.toInt()}g F:${log.fats.toInt()}g',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteLog(log.id),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.blue;
      case 'snack':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _logFood() {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final foodName = _selectedFood ?? _customFoodController.text;
      final servingUnit =
          _selectedFood != null ? _foodDatabase[_selectedFood]!['unit'] : 'serving';

      final foodLog = FoodLogModel(
        id: uuid.v4(),
        userId: user.id,
        timestamp: DateTime.now(),
        mealType: _mealType,
        foodName: foodName,
        servingSize: double.parse(_servingSizeController.text),
        servingUnit: servingUnit,
        calories: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text.isEmpty ? '0' : _proteinController.text),
        carbs: double.parse(_carbsController.text.isEmpty ? '0' : _carbsController.text),
        fats: double.parse(_fatsController.text.isEmpty ? '0' : _fatsController.text),
        createdAt: DateTime.now(),
      );

      ref.read(foodLogsProvider.notifier).addFoodLog(foodLog);

      showSuccessSnackbar(context, 'Food logged successfully!');

      // Reset form
      setState(() {
        _selectedFood = null;
        _customFoodController.clear();
        _servingSizeController.clear();
        _caloriesController.clear();
        _proteinController.clear();
        _carbsController.clear();
        _fatsController.clear();
      });
    }
  }

  void _deleteLog(String id) {
    ref.read(foodLogsProvider.notifier).deleteFoodLog(id);
  }
}

class _NutrientBar extends StatelessWidget {
  final String label;
  final double value;
  final double goal;
  final String unit;
  final Color color;

  const _NutrientBar({
    required this.label,
    required this.value,
    required this.goal,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (value / goal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              '${value.toInt()} / ${goal.toInt()} $unit',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }
}
