import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food_log_model.dart';
import '../models/meal_plan_model.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';
import 'health_provider.dart';

// Food logs provider
final foodLogsProvider = StateNotifierProvider<FoodLogsNotifier, List<FoodLogModel>>((ref) {
  return FoodLogsNotifier(ref);
});

class FoodLogsNotifier extends StateNotifier<List<FoodLogModel>> {
  FoodLogsNotifier(this.ref) : super([]) {
    _loadFoodLogs();
  }

  final Ref ref;

  void _loadFoodLogs() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final db = ref.read(databaseServiceProvider);
      state = db.getUserFoodLogsByDate(user.id, DateTime.now());
    }
  }

  Future<void> addFoodLog(FoodLogModel foodLog) async {
    final db = ref.read(databaseServiceProvider);
    await db.saveFoodLog(foodLog);
    _loadFoodLogs();
  }

  Future<void> deleteFoodLog(String id) async {
    final db = ref.read(databaseServiceProvider);
    await db.deleteFoodLog(id);
    _loadFoodLogs();
  }

  void loadDate(DateTime date) {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final db = ref.read(databaseServiceProvider);
      state = db.getUserFoodLogsByDate(user.id, date);
    }
  }

  void refresh() {
    _loadFoodLogs();
  }
}

// Today's nutrition totals provider
final todayNutritionTotalsProvider = Provider<NutritionTotals>((ref) {
  final foodLogs = ref.watch(foodLogsProvider);

  double totalCalories = 0;
  double totalProtein = 0;
  double totalCarbs = 0;
  double totalFats = 0;

  for (final log in foodLogs) {
    totalCalories += log.calories;
    totalProtein += log.protein;
    totalCarbs += log.carbs;
    totalFats += log.fats;
  }

  return NutritionTotals(
    calories: totalCalories,
    protein: totalProtein,
    carbs: totalCarbs,
    fats: totalFats,
  );
});

class NutritionTotals {
  final double calories;
  final double protein;
  final double carbs;
  final double fats;

  NutritionTotals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });
}

// Recipes provider
final recipesProvider = StateNotifierProvider<RecipesNotifier, List<RecipeModel>>((ref) {
  return RecipesNotifier(ref);
});

class RecipesNotifier extends StateNotifier<List<RecipeModel>> {
  RecipesNotifier(this.ref) : super([]) {
    _loadRecipes();
  }

  final Ref ref;

  void _loadRecipes() {
    final db = ref.read(databaseServiceProvider);
    state = db.getAllRecipes();

    // If no recipes exist, add default recipes
    if (state.isEmpty) {
      _addDefaultRecipes();
    }
  }

  void _addDefaultRecipes() async {
    final defaultRecipes = _getDefaultRecipes();
    final db = ref.read(databaseServiceProvider);

    for (final recipe in defaultRecipes) {
      await db.saveRecipe(recipe);
    }

    _loadRecipes();
  }

  Future<void> addRecipe(RecipeModel recipe) async {
    final db = ref.read(databaseServiceProvider);
    await db.saveRecipe(recipe);
    _loadRecipes();
  }

  Future<void> deleteRecipe(String id) async {
    final db = ref.read(databaseServiceProvider);
    await db.deleteRecipe(id);
    _loadRecipes();
  }

  List<RecipeModel> getRecipesByCategory(String category) {
    return state.where((r) => r.category == category).toList();
  }

  void refresh() {
    _loadRecipes();
  }

  List<RecipeModel> _getDefaultRecipes() {
    return [
      RecipeModel(
        id: 'recipe_1',
        name: 'Oatmeal with Berries',
        category: 'breakfast',
        prepTimeMinutes: 5,
        cookTimeMinutes: 5,
        servings: 1,
        ingredients: [
          '1/2 cup rolled oats',
          '1 cup milk or water',
          '1/2 cup mixed berries',
          '1 tbsp honey',
          '1 tbsp almonds',
        ],
        instructions: [
          'Bring milk/water to boil',
          'Add oats and reduce heat',
          'Cook for 5 minutes, stirring occasionally',
          'Top with berries, honey, and almonds',
        ],
        calories: 320,
        protein: 12,
        carbs: 52,
        fats: 8,
        tags: ['vegetarian', 'quick'],
      ),
      RecipeModel(
        id: 'recipe_2',
        name: 'Avocado Toast',
        category: 'breakfast',
        prepTimeMinutes: 5,
        cookTimeMinutes: 2,
        servings: 1,
        ingredients: [
          '2 slices whole grain bread',
          '1 ripe avocado',
          '1 egg',
          'Salt and pepper to taste',
          'Red pepper flakes (optional)',
        ],
        instructions: [
          'Toast the bread',
          'Mash avocado with salt and pepper',
          'Cook egg to your preference',
          'Spread avocado on toast, top with egg',
          'Sprinkle with red pepper flakes',
        ],
        calories: 380,
        protein: 16,
        carbs: 36,
        fats: 20,
        tags: ['vegetarian', 'quick', 'high-protein'],
      ),
      RecipeModel(
        id: 'recipe_3',
        name: 'Grilled Chicken Salad',
        category: 'lunch',
        prepTimeMinutes: 15,
        cookTimeMinutes: 10,
        servings: 2,
        ingredients: [
          '2 chicken breasts',
          '4 cups mixed greens',
          '1 cucumber, sliced',
          '1 cup cherry tomatoes',
          '1/4 cup feta cheese',
          '2 tbsp olive oil',
          '1 tbsp balsamic vinegar',
        ],
        instructions: [
          'Season and grill chicken breasts',
          'Slice grilled chicken',
          'Combine greens, cucumber, and tomatoes in bowl',
          'Top with chicken and feta',
          'Drizzle with oil and vinegar',
        ],
        calories: 420,
        protein: 38,
        carbs: 12,
        fats: 24,
        tags: ['high-protein', 'gluten-free'],
      ),
      RecipeModel(
        id: 'recipe_4',
        name: 'Quinoa Buddha Bowl',
        category: 'lunch',
        prepTimeMinutes: 10,
        cookTimeMinutes: 20,
        servings: 2,
        ingredients: [
          '1 cup quinoa',
          '1 can chickpeas, drained',
          '2 cups kale, chopped',
          '1 sweet potato, cubed',
          '1 avocado, sliced',
          '2 tbsp tahini',
          '1 lemon, juiced',
        ],
        instructions: [
          'Cook quinoa according to package',
          'Roast sweet potato at 400F for 20 minutes',
          'Massage kale with lemon juice',
          'Arrange quinoa, chickpeas, kale, and sweet potato in bowl',
          'Top with avocado and drizzle with tahini',
        ],
        calories: 480,
        protein: 18,
        carbs: 64,
        fats: 18,
        tags: ['vegan', 'gluten-free', 'high-fiber'],
      ),
      RecipeModel(
        id: 'recipe_5',
        name: 'Salmon with Vegetables',
        category: 'dinner',
        prepTimeMinutes: 10,
        cookTimeMinutes: 20,
        servings: 2,
        ingredients: [
          '2 salmon fillets',
          '2 cups broccoli florets',
          '1 cup carrots, sliced',
          '2 tbsp olive oil',
          '2 cloves garlic, minced',
          'Lemon wedges',
        ],
        instructions: [
          'Preheat oven to 400F',
          'Season salmon with salt, pepper, and garlic',
          'Toss vegetables with olive oil',
          'Arrange salmon and vegetables on baking sheet',
          'Bake for 15-20 minutes',
          'Serve with lemon wedges',
        ],
        calories: 450,
        protein: 36,
        carbs: 18,
        fats: 26,
        tags: ['high-protein', 'gluten-free', 'omega-3'],
      ),
      RecipeModel(
        id: 'recipe_6',
        name: 'Vegetable Stir Fry',
        category: 'dinner',
        prepTimeMinutes: 15,
        cookTimeMinutes: 10,
        servings: 3,
        ingredients: [
          '2 cups mixed vegetables',
          '1 block tofu, cubed',
          '2 tbsp soy sauce',
          '1 tbsp sesame oil',
          '2 cloves garlic, minced',
          '1 tsp ginger, grated',
          '2 cups cooked rice',
        ],
        instructions: [
          'Press and cube tofu',
          'Heat sesame oil in wok',
          'Stir fry tofu until golden',
          'Add vegetables, garlic, and ginger',
          'Add soy sauce and cook until tender',
          'Serve over rice',
        ],
        calories: 380,
        protein: 16,
        carbs: 52,
        fats: 12,
        tags: ['vegan', 'quick'],
      ),
      RecipeModel(
        id: 'recipe_7',
        name: 'Greek Yogurt Parfait',
        category: 'snack',
        prepTimeMinutes: 5,
        cookTimeMinutes: 0,
        servings: 1,
        ingredients: [
          '1 cup Greek yogurt',
          '1/2 cup granola',
          '1/2 cup mixed berries',
          '1 tbsp honey',
        ],
        instructions: [
          'Layer yogurt in glass',
          'Add granola layer',
          'Top with berries',
          'Drizzle with honey',
        ],
        calories: 280,
        protein: 20,
        carbs: 38,
        fats: 6,
        tags: ['vegetarian', 'quick', 'high-protein'],
      ),
      RecipeModel(
        id: 'recipe_8',
        name: 'Protein Smoothie Bowl',
        category: 'breakfast',
        prepTimeMinutes: 5,
        cookTimeMinutes: 0,
        servings: 1,
        ingredients: [
          '1 frozen banana',
          '1 scoop protein powder',
          '1/2 cup milk',
          '1 tbsp peanut butter',
          'Toppings: granola, berries, coconut',
        ],
        instructions: [
          'Blend banana, protein powder, milk, and peanut butter',
          'Pour into bowl',
          'Top with granola, berries, and coconut',
        ],
        calories: 420,
        protein: 32,
        carbs: 48,
        fats: 12,
        tags: ['vegetarian', 'high-protein', 'quick'],
      ),
      RecipeModel(
        id: 'recipe_9',
        name: 'Hummus & Veggie Wrap',
        category: 'lunch',
        prepTimeMinutes: 10,
        cookTimeMinutes: 0,
        servings: 1,
        ingredients: [
          '1 whole wheat tortilla',
          '1/4 cup hummus',
          '1/2 cup mixed greens',
          '1/4 cucumber, sliced',
          '1/4 bell pepper, sliced',
          '2 tbsp feta cheese',
        ],
        instructions: [
          'Spread hummus on tortilla',
          'Layer greens, cucumber, and bell pepper',
          'Sprinkle with feta',
          'Roll tightly and slice in half',
        ],
        calories: 320,
        protein: 12,
        carbs: 42,
        fats: 12,
        tags: ['vegetarian', 'quick', 'portable'],
      ),
      RecipeModel(
        id: 'recipe_10',
        name: 'Turkey Meatballs with Pasta',
        category: 'dinner',
        prepTimeMinutes: 15,
        cookTimeMinutes: 25,
        servings: 4,
        ingredients: [
          '1 lb ground turkey',
          '1/4 cup breadcrumbs',
          '1 egg',
          '2 cups marinara sauce',
          '8 oz whole wheat pasta',
          '2 tbsp parmesan cheese',
        ],
        instructions: [
          'Mix turkey, breadcrumbs, and egg',
          'Form into meatballs',
          'Bake at 375F for 20 minutes',
          'Cook pasta according to package',
          'Heat marinara and add meatballs',
          'Serve over pasta with parmesan',
        ],
        calories: 480,
        protein: 32,
        carbs: 52,
        fats: 14,
        tags: ['high-protein'],
      ),
    ];
  }
}
