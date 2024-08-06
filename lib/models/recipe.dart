import 'package:cookingapp/services/db_helper.dart';
import 'package:cookingapp/models/ingredient.dart';
import 'package:cookingapp/models/step.dart';

class Recipe {
  int? id;
  final String name;
  final String yieldValue;
  final int time;
  final String timeUnit;
  String? imageName;
  List<Ingredient>? ingredientList = [];
  List<recipeStep>? stepList = [];  

  Recipe({
    this.id,
    required this.name,
    required this.yieldValue,
    required this.time,
    required this.timeUnit,
    this.imageName,
    this.ingredientList,
    this.stepList,
  });

  factory Recipe.fromMap(Map<String, dynamic> dataMap) {
    return Recipe(
      id: dataMap['id'],
      name: dataMap['name'],
      yieldValue: dataMap['yield'],
      time: dataMap['time'],
      timeUnit: dataMap['time_unit'],
      imageName: dataMap['image'],
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'yield': yieldValue,
      'time': time,
      'time_unit': timeUnit,
      'image': imageName
    };
  }

  Future<int> insertRecipe() async {
    DbHelper db = DbHelper();
    return await db.insertRecipe(name, yieldValue, time, timeUnit, imageName);
  }

  static Future<Recipe> getRecipeById(id) async {
    DbHelper db = DbHelper();
    Recipe recipeInfo = Recipe.fromMap(await db.getRecipeById(id));
    recipeInfo.ingredientList = await Ingredient.getIngredientsByRecipeId(id);
    recipeInfo.stepList = await recipeStep.getStepsById(id);

    return recipeInfo;
  }

  Future<int> deleteRecipeById (id) async {
    DbHelper db = DbHelper();
    return await db.deleteRecipe(id);
  }

  Future<int> deleteRecipeInfo (id) async {
    DbHelper db = DbHelper();
    return await db.deleteRecipeInfo(id);
  }

  Future<void> updateRecipe (Recipe recipe) async {
    DbHelper db = DbHelper();
    await db.updateRecipe(recipe);
  }

  Future<void> updateRecipeInfo (Recipe recipe) async {
    DbHelper db = DbHelper();
    await db.updateRecipeInfo(recipe);
  }
}