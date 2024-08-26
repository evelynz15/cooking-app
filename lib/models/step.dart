import 'package:cookingapp/services/db_helper.dart'; 

class recipeStep {
  int? id;
  final int recipeId;
  final int sequence;
  final String description;

  recipeStep ({
    this.id,
    this.recipeId = 0,
    this.sequence = 0,
    this.description = '',
  });

  factory recipeStep.fromMap(Map<String, dynamic> dataMap) {
    
    return recipeStep(
      id: dataMap['id'],
      recipeId: dataMap['recipe_id'],
      sequence: dataMap['sequence'],
      description: dataMap['description'],
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'sequence': sequence,
      'description': description,
    };
  }

  Future<int> insertStep() async {
    DbHelper db = DbHelper();
    return await db.insertStep(recipeId, sequence, description);
  }

   static Future<List<recipeStep>> getStepsById(id) async {
    DbHelper db = DbHelper();
    List<recipeStep> steps = [];
    for(var stepInfo in await db.getStepsById(id)){
    steps.add(recipeStep.fromMap(stepInfo));
    }
    return steps;
  }

  Future<int> deleteStepsById (id) async {
    DbHelper db = DbHelper();
    return await db.deleteSteps(id);
  }

  static Future<int> deleteStepsByRecipeId (id) async {
    DbHelper db = DbHelper();
    return await db.deleteStepsByRecipeId(id);
  }

  Future<void> updateSteps (recipeStep step) async {
    DbHelper db = DbHelper();
    await db.updateSteps(step);
  }
}