import 'package:cookingapp/services/db_helper.dart'; 

class recipeStep {
  int? id;
  final int recipeId;
  final int sequence;
  final String description;

  recipeStep ({
    required this.recipeId,
    required this.sequence,
    required this.description,
  });

  factory recipeStep.fromMap(Map<String, dynamic> dataMap) {
    
    return recipeStep(
      recipeId: dataMap['recipe_id'],
      sequence: dataMap['sequence'],
      description: dataMap['description'],
    );
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
}