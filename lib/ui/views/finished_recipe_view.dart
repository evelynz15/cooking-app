import 'package:cookingapp/ui/views/add_recipe_view.dart';
import 'package:cookingapp/ui/views/edit_recipe_view.dart';
import 'package:flutter/material.dart';
import 'package:cookingapp/ui/views/home_view.dart';
import 'package:cookingapp/ui/views/catagory_view.dart';
import 'package:cookingapp/models/recipe.dart';
import 'package:cookingapp/models/ingredient.dart';
import 'dart:developer';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';


class FinishedRecipe extends StatefulWidget {
  final int recipeId;

  const FinishedRecipe({super.key, required this.recipeId});

  @override
  State<FinishedRecipe> createState() => _FinishedRecipeState();
}

class _FinishedRecipeState extends State<FinishedRecipe> {
  Directory? documentDirectory;
  Recipe? recipeData;
  Future<Recipe> getRecipe() async {
    documentDirectory = await getApplicationDocumentsDirectory();
    recipeData = await Recipe.getRecipeById(widget.recipeId);
    log('test -' + recipeData!.stepList![0].description);
    return recipeData!;
  }

  Widget recipeWidget() {
    return FutureBuilder(
      builder: (context, recipeSnap) {
        if (recipeSnap.data == null ||
            recipeSnap.connectionState == ConnectionState.none &&
                !recipeSnap.hasData) {
          //print('project snapshot data is: ${projectSnap.data}');
          return const Center(child: CircularProgressIndicator());
        } else {
          File recipeImg = File(path.join(documentDirectory!.path, 'image', recipeData!.id.toString()) +
                  recipeData!.imageName.toString());
          return Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 30),
              child: Center(
                  child: Column(
                children: [
                  Text(
                    recipeData!.name.capitalize(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 160,
                        width: 160,
                        color: Theme.of(context).colorScheme.inversePrimary,
                        child: recipeData!.imageName != null
                        ? Image.file(recipeImg)
                        : Image.network('https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg')
                      ),
                      Container(
                        width: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("Yield: ${recipeData!.yieldValue}", style:TextStyle(fontSize: 18) ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text("Time: ${recipeData!.time.toString()}", style:TextStyle(fontSize: 18))
                                  ),
                                Text(recipeData!.timeUnit, style:TextStyle(fontSize: 18)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  Container(
                      alignment: Alignment.centerLeft,
                      child: Text("Ingredients List:", style:TextStyle(fontSize: 18))),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.0),
                      itemCount: recipeData!.ingredientList!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 200,
                              child: Text(recipeData!.ingredientList![index].ingredientName.capitalize(), style:TextStyle(fontSize: 17)),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: Text(recipeData!.ingredientList![index].amount.toString(), style:TextStyle(fontSize: 17)),
                                ),
                                SizedBox(width: 70, child: Text(recipeData!.ingredientList![index].unit, style:TextStyle(fontSize: 17))),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 50),
                  Container(
                      alignment: Alignment.centerLeft,
                      child: Text("Procedure:", style:TextStyle(fontSize: 18))),
                  SizedBox(
                    //width: 200,
                    height: 200,
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.0),
                      itemCount: recipeData!.stepList!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: Text(recipeData!.stepList![index].sequence.toString(), style:TextStyle(fontSize: 17)),
                          title: Text(recipeData!.stepList![index].description.capitalize(), style:TextStyle(fontSize: 17))
                          );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 40,
                    width: 100,
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditRecipePage(recipeId: widget.recipeId)));
                      });
                      },
                      child: Text("Edit"),
                    ),
                  ),
                ],
              )));
        }
      },
      future: getRecipe(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("DESSERT"),
      ),
      body: recipeWidget(),
    );
  }
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
