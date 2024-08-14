//import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'dart:developer';
import 'dart:async';
import 'package:cookingapp/models/recipe.dart';
import 'package:cookingapp/models/ingredient.dart';
import 'package:cookingapp/models/step.dart';

class DbHelper {
  static const _databaseName = "cookingapp.db";
  static const _databaseVersion = 1;
  static String dbPath = "";
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _openDatabase();
    return _database!;
  }

  _openDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    DbHelper.dbPath = p.join(documentDirectory.path, DbHelper._databaseName);
    log('sqlite db: ${DbHelper.dbPath}');
    return await openDatabase(DbHelper.dbPath,
        version: DbHelper._databaseVersion,
        onCreate: _onCreateDb,
        onUpgrade: _onUpgradeDb);
  }

  Future<void> _onCreateDb(Database db, int newVersion) async {
    Batch batch = db.batch();
    batch.execute('''
  CREATE TABLE "recipe" ( 
  "id" INTEGER, 
  "name" TEXT NOT NULL, 
  "yield" TEXT, 
  "time" INTEGER,
  "time_unit"	TEXT,
  "image"	TEXT,
  "catagory_id"	INTEGER NOT NULL,
  "notes"	TEXT,
  PRIMARY KEY("id" AUTOINCREMENT) 
  )
  ''');
    batch.execute('''
  CREATE TABLE "recipe_step" (
	"id"	INTEGER,
  "recipe_id"	INTEGER NOT NULL,
	"sequence"	INTEGER NOT NULL DEFAULT 0,
	"description"	TEXT NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
  )
  ''');
    batch.execute('''
  CREATE TABLE "recipe_ingredient" (
	"id"	INTEGER,
	"recipe_id"	INTEGER NOT NULL,
  "ingredient_name"	TEXT NOT NULL,
	"amount"	REAL,
	"unit"	TEXT NOT NULL DEFAULT 'n/a',
  "sequence"	INTEGER NOT NULL DEFAULT 1,
	PRIMARY KEY("id" AUTOINCREMENT)
  )
  ''');

    await batch.commit();
  }

  Future<void> _onUpgradeDb(
      Database db, int oldVersion, int newVersion) async {}

  Future<int> insertRecipe(String name, String yieldValue, int time,
      String timeUnit, String? imageName, int catagoryId, String? notes) async {
    Map<String, Object?> recipeMap = {
      'name': name,
      'yield': yieldValue,
      'time': time,
      'time_unit': timeUnit,
      'image': imageName,
      'catagory_id': catagoryId,
      'notes': notes,
    };

    try {
      int insertID = await _database!.insert('recipe', recipeMap);
      return insertID;
    } catch (e) {
      log('Error: $e');
      return 0;
    }
  }

  Future<int> insertIngredient(int recipeId, String ingredientName,
      double amount, String unit, int sequence) async {
    Map<String, Object?> ingredientMap = {
      'recipe_id': recipeId,
      'ingredient_name': ingredientName,
      'amount': amount,
      'unit': unit,
      'sequence': sequence,
    };

    try {
      int insertID =
          await _database!.insert('recipe_ingredient', ingredientMap);
      return insertID;
    } catch (e) {
      log('Error: $e');
      return 0;
    }
  }

  Future<int> insertStep(int recipeId, int sequence, String description) async {
    Map<String, Object?> stepMap = {
      'recipe_id': recipeId,
      'sequence': sequence,
      'description': description,
    };

    try {
      int insertID = await _database!.insert('recipe_step', stepMap);
      return insertID;
    } catch (e) {
      log('Error: $e');
      return 0;
    }
  }

  Future<List<Map<String, Object?>>> getAllRecipes() async {
    return await _database!.query('recipe');
  }

  Future<Map<String, Object?>> getRecipeById(int id) async {
    String query = "SELECT * FROM recipe WHERE id = ?";

    try {
      List<Map<String, Object?>> result =
          await _database!.rawQuery(query, [id]);
      var res = result.toList();
      if (res.length > 1) {
        throw Exception("Wrong data");
      } else if (res.length == 1) {
        return res[0];
      } else {
        throw Exception("No data");
      }
    } catch (e) {
      log('getRecipeById - Error: $e');
      return {};
    }
  }

  Future<List<Map<String, Object?>>> getRecipesByCatagoryId (int id) async {
    String query = "SELECT * FROM recipe WHERE catagory_id = ?";
    try {
      List<Map<String, Object?>> result =
          await _database!.rawQuery(query, [id]);
      var res = result.toList();
      if (res.isNotEmpty) {
        return res;
      } else {
        throw Exception("No data");
      }
    } catch (e) {
      log('getRecipesByCatagoryId - Error: $e');
      return [];
    }
  }

  Future<List<Map<String, Object?>>> getIngredientsByRecipeId(int id) async {
    String query = "SELECT * FROM recipe_ingredient WHERE recipe_id = ?";

    try {
      List<Map<String, Object?>> result =
          await _database!.rawQuery(query, [id]);
      var res = result.toList();
      if (res.isNotEmpty) {
        return res;
      } else {
        throw Exception("No data");
      }
    } catch (e) {
      log('getIngredientsById - Error: $e');
      return [];
    }
  }

  Future<List<Map<String, Object?>>> getStepsById(int id) async {
    String query = "SELECT * FROM recipe_step WHERE recipe_id = ?";

    try {
      List<Map<String, Object?>> result =
          await _database!.rawQuery(query, [id]);
      var res = result.toList();
      if (res.isNotEmpty) {
        return res;
      } else {
        throw Exception("No data");
      }
    } catch (e) {
      log('getStepsById - Error: $e');
      return [];
    }
  }

  Future<int> deleteRecipe(int id) async {
    try {
      return await _database!.delete(
        'recipe',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      log('deleteRecipe - Error: $e');
      return 0;
    }
  }

  Future<int> deleteIngredients(int id) async {
    try {
      return await _database!.delete(
        'recipe_ingredient',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      log('deleteIngredients - Error: $e');
      return 0;
    }
  }

  Future<int> deleteSteps(int id) async {
    try {
      return await _database!.delete(
        'recipe_step',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      log('deleteSteps - Error: $e');
      return 0;
    }
  }

  Future<int> deleteRecipeInfo(int id) async {
    try {
      await _database!.transaction((action) async {
        await action.delete('recipe_ingredient',
            where: 'recipe_id = ?', whereArgs: [id]);
        await action.delete(
          'recipe_step',
          where: 'recipe_id = ?',
          whereArgs: [id],
        );
        await action.delete(
          'recipe',
          where: 'id = ?',
          whereArgs: [id],
        );
      });
      return 1;
    } catch (e) {
      log('deleteRecipeInfo - Error: $e');
      return 0;
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await _database!.update(
        'recipe',
        recipe.toMap(),
        where: 'id = ?',
        whereArgs: [recipe.id],
      );
    } catch (e) {
      log('updateRecipe - Error: $e');
    }
  }

  Future<void> updateIngredients(Ingredient ingredient) async {
    try {
      await _database!.update(
        'recipe_ingredient',
        ingredient.toMap(),
        where: 'id = ?',
        whereArgs: [ingredient.id],
      );
    } catch (e) {
      log('updateIngredients - Error: $e');
    }
  }

  Future<void> updateSteps(recipeStep step) async {
    try {
      await _database!.update(
        'recipe_step',
        step.toMap(),
        where: 'id = ?',
        whereArgs: [step.id],
      );
    } catch (e) {
      log('updateSteps - Error: $e');
    }
  }

  Future<void> updateRecipeInfo(Recipe recipe) async {
    try {
      await _database!.transaction((action) async {
        await action.update(
          'recipe',
          recipe.toMap(),
          where: 'id = ?',
          whereArgs: [recipe.id],
        );
        for (Ingredient ingredient in recipe.ingredientList!) {
          ingredient.id != null
              ? await action.update(
                  'recipe_ingredient',
                  ingredient.toMap(),
                  where: 'id = ?',
                  whereArgs: [ingredient.id],
                )
              : await action.insert(
                  'recipe_ingredient',
                  ingredient.toMap(),
                );
        }
        for (recipeStep step in recipe.stepList!) {
          step.id != null
              ? await action.update(
                  'recipe_step',
                  step.toMap(),
                  where: 'id = ?',
                  whereArgs: [step.id],
                )
              : await action.insert(
                  'recipe_step',
                  step.toMap(),
                );
        }
      });
    } catch (e) {
      log('updateRecipeInfo - Error: $e');
    }
  }
}
