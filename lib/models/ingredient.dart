import 'package:cookingapp/services/db_helper.dart'; 

class Ingredient {
  int? id;
  int recipeId;
  String ingredientName;
  double amount;
  String unit;
  int sequence;

  Ingredient ({
    this.id,
    this.recipeId = 0,
    this.ingredientName = '',
    this.amount = 0,
    this.unit = 'n/a',
    this.sequence = 0,
  });

  factory Ingredient.fromMap(Map<String, dynamic> dataMap) {
    
    return Ingredient(
      id: dataMap['id'],
      recipeId: dataMap['recipe_id'],
      ingredientName: dataMap['ingredient_name'],
      amount: dataMap['amount'],
      unit: dataMap['unit'],
      sequence: dataMap['sequence'],
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'ingredient_name': ingredientName,
      'amount': amount,
      'unit': unit,
      'sequence': sequence,
    };
  }


  Future<int> insertIngredient() async {
    DbHelper db = DbHelper();
    return await db.insertIngredient(recipeId, ingredientName, amount, unit, sequence);
  }

  static Future<List<Ingredient>> getIngredientsByRecipeId(id) async {
    DbHelper db = DbHelper();
    List<Ingredient> ingredients = [];
    for(var ingredientInfo in await db.getIngredientsByRecipeId(id)){
    ingredients.add(Ingredient.fromMap(ingredientInfo));
    }
    return ingredients;
  }

  Future<int> deleteIngredientsById (id) async {
    DbHelper db = DbHelper();
    return await db.deleteIngredients(id);
  }

  Future<void> updateIngredients (Ingredient ingredient) async {
    DbHelper db = DbHelper();
    await db.updateIngredients(ingredient);
  }
} 