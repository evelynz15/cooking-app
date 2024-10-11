import 'package:cookingapp/services/db_helper.dart';
import 'package:cookingapp/models/ingredient.dart';
import 'package:cookingapp/models/step.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';

class Recipe {
  int? id;
  final String name;
  final String yieldValue;
  final double time;
  final String timeUnit;
  final int catagoryId;
  String? imageName;
  String? notes;
  List<Ingredient>? ingredientList = [];
  List<recipeStep>? stepList = [];  

  Recipe({
    this.id,
    required this.name,
    required this.yieldValue,
    required this.time,
    required this.timeUnit,
    required this.catagoryId,
    this.imageName,
    this.notes,
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
      catagoryId: dataMap['catagory_id'],
      notes: dataMap['notes'],
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'yield': yieldValue,
      'time': time,
      'time_unit': timeUnit,
      'image': imageName,
      'catagory_id': catagoryId,
      'notes': notes,
    };
  }

  static Recipe fromJson(String jsonString) {
    
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    log("json map - $json");
      //final id = json['id'] as int;
      final name = json['name'] as String;
      final yieldValue = json['yield'] as String;
      final time = json['time'] as double;
      final timeUnit = json['time_unit'] as String;
      final catagoryId = json['catagory_id'] as int;
      final notes = json['notes'] as String?;
      //final imageName = json['image'] as String?;
      final ingredientList = json['ingredient_list'];// as List<Map<String, dynamic>>;
      final stepList = json['step_list'];// as List<Map<String, dynamic>>;
      
      return Recipe(
        //id: id,
        name: name,
        yieldValue: yieldValue,
        time: time,
        timeUnit: timeUnit,
        catagoryId: catagoryId,
        notes: notes,
        //imageName: imageName,
        ingredientList: ingredientList!
              // map each review to a Review object
              .map((ingredient) =>
                  Ingredient.fromMap(ingredient as Map<String, dynamic>))
              .toList().cast<Ingredient>(), // map() returns an Iterable so we convert it to a List,
        stepList: stepList!
              // map each review to a Review object
              .map((step) =>
                  recipeStep.fromMap(step as Map<String, dynamic>))
              .toList().cast<recipeStep>(),
      );
  }

  Map<String, dynamic> toJsonMap() => {
        'id': id,
        'name': name,
        'yield': yieldValue,
        'time': time,
        'time_unit': timeUnit,
        'catagory_id': catagoryId,
        if (notes != null) 'notes': notes,
        //if (imageName != null) 'image': imageName,
        'ingredient_list': ingredientList!.map((ingredient) => ingredient.toMap()).toList(),
        'step_list': stepList!.map((step) => step.toMap()).toList(),
    };

  Future<File> toJson() async {
    String jsonData = json.encode(toJsonMap());
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath = '$tempPath/whatscookingsharedrecipe.json';
    File jsonFile = File(filePath);
    log('Temporary recipe file: $filePath');
    if (jsonFile.existsSync()) {
      jsonFile.deleteSync();
      log('Previous json file deleted.');
    }
    return jsonFile.writeAsString(jsonData);
  }

  Future<int> insertRecipe() async {
    DbHelper db = DbHelper();
    return await db.insertRecipe(name, yieldValue, time, timeUnit, imageName, catagoryId, notes);
  }

  static Future<Recipe> getRecipeById(id) async {
    DbHelper db = DbHelper();
    Recipe recipeInfo = Recipe.fromMap(await db.getRecipeById(id));
    recipeInfo.ingredientList = await Ingredient.getIngredientsByRecipeId(id);
    recipeInfo.stepList = await recipeStep.getStepsById(id);

    return recipeInfo;
  }

  static Future<List<Recipe>> getRecipesByCatagoryId(id) async {
    DbHelper db = DbHelper();
    List<Recipe> recipesInCatagory = []; 
    for(var recipeInfo in await db.getRecipesByCatagoryId(id)){
    recipesInCatagory.add(Recipe.fromMap(recipeInfo));
    }
    return recipesInCatagory;
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