import 'package:cookingapp/services/db_helper.dart'; 

class Ingredient {
  int? id;
  int recipeId;
  String ingredientName;
  double amount;
  String unit;
  int sequence;

  Ingredient ({
    this.recipeId = 0,
    this.ingredientName = '',
    this.amount = 0,
    this.unit = 'n/a',
    this.sequence = 0,
  });

  factory Ingredient.fromMap(Map<String, dynamic> dataMap) {
    
    return Ingredient(
      recipeId: dataMap['recipe_id'],
      ingredientName: dataMap['ingredient_name'],
      amount: dataMap['amount'],
      unit: dataMap['unit'],
      sequence: dataMap['sequence'],
    );
  }


  Future<int> insertIngredient() async {
    DbHelper db = DbHelper();
    return await db.insertIngredient(recipeId, ingredientName, amount, unit, sequence);
  }

  static Future<List<Ingredient>> getIngredientsById(id) async {
    DbHelper db = DbHelper();
    List<Ingredient> ingredients = [];
    for(var ingredientInfo in await db.getIngredientsById(id)){
    ingredients.add(Ingredient.fromMap(ingredientInfo));
    }
    return ingredients;
  }

  Future<int> deleteIngredientsById (id) async {
    DbHelper db = DbHelper();
    return await db.deleteIngredients(id);
  }
} 