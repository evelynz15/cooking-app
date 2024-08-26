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
import 'package:cookingapp/ui/router.dart';
import 'package:cookingapp/ui/views/recipe_stepper_edit_view.dart';

class FinishedRecipe extends StatefulWidget {
  final int recipeId;
  final int catagoryId;

  const FinishedRecipe(
      {super.key, required this.recipeId, required this.catagoryId});

  @override
  State<FinishedRecipe> createState() => _FinishedRecipeState();
}

class _FinishedRecipeState extends State<FinishedRecipe> {
  Directory? documentDirectory;
  Recipe? recipeData;
  late String catagoryImage;
  String coverIcon = "assets/images/cover-icon.PNG";

  @override
  void initState() {
    super.initState();
    switch (widget.catagoryId) {
      case 0:
        catagoryImage = "assets/images/appetizers-icon.PNG";
      case 1:
        catagoryImage = "assets/images/entrees-icon.PNG";
      case 2:
        catagoryImage = "assets/images/dessert-icon.PNG";
      case 3:
        catagoryImage = "assets/images/breakfast-icon.PNG";
      case 4:
        catagoryImage = "assets/images/lunch-icon.PNG";
      case 5:
        catagoryImage = "assets/images/others-icon.PNG";
    }
  }

  Future<Recipe> getRecipe() async {
    documentDirectory = await getApplicationDocumentsDirectory();
    recipeData = await Recipe.getRecipeById(widget.recipeId);
    log('test -' + recipeData!.stepList![0].description);
    return recipeData!;
  }

  Widget recipeWidget() {
    return FutureBuilder(
      builder: (context, recipeSnap) {
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;

        if (recipeSnap.data == null ||
            recipeSnap.connectionState == ConnectionState.none &&
                !recipeSnap.hasData) {
          //print('project snapshot data is: ${projectSnap.data}');
          return const Center(child: CircularProgressIndicator());
        } else {
          File recipeImg = File(path.join(
                  documentDirectory!.path, 'image', recipeData!.id.toString()) +
              recipeData!.imageName.toString());

          return Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
              child: Center(
                  child: SafeArea(
                child: Column(
                  children: [
                    Text(recipeData!.name.capitalize(),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            height: screenHeight * 0.17,
                            width: 160,
                            child: recipeData!.imageName != null
                                ? Image.file(recipeImg, key: UniqueKey())
                                : Container(
                                    /*color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,*/
                                    child: Image.asset(coverIcon),
                                  )),
                        Container(
                          width: 150,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Yield: ${recipeData!.yieldValue}",
                                  style: TextStyle(fontSize: 16)),
                              Row(
                                children: [
                                  SizedBox(
                                      width: 80,
                                      child: Text(
                                          "Time: ${recipeData!.time.toString()}",
                                          style: TextStyle(fontSize: 16))),
                                  Text(recipeData!.timeUnit,
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              SizedBox(height: 30),
                              SizedBox(
                                width: 120,
                                height: 40,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            scrollable: true,
                                            title: Text('Notes'),
                                            content: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all()),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Form(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Container(
                                                            width: screenWidth *
                                                                0.7,
                                                            child: Text(
                                                                recipeData!.notes !=
                                                                        null
                                                                    ? recipeData!
                                                                        .notes!
                                                                        .capitalize()
                                                                    : "No notes",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16))),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                  child: Text("Done"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  })
                                            ],
                                          );
                                        });
                                  },
                                  child: Text("Notes"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Container(
                        alignment: Alignment.centerLeft,
                        child: Text("Ingredients List:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                    SizedBox(
                      height: screenHeight * 0.15,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16.0),
                        itemCount: recipeData!.ingredientList!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 200,
                                child: Text(
                                    recipeData!
                                        .ingredientList![index].ingredientName
                                        .capitalize(),
                                    style: TextStyle(fontSize: 16)),
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: Text(
                                        recipeData!
                                            .ingredientList![index].amount
                                            .toString(),
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                  SizedBox(
                                      width: 70,
                                      child: Text(
                                          recipeData!
                                              .ingredientList![index].unit,
                                          style: TextStyle(fontSize: 16))),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Spacer(),
                    Container(
                        alignment: Alignment.centerLeft,
                        child: Text("Procedure:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                    SizedBox(
                      //width: 200,
                      height: screenHeight * 0.15,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16.0),
                        itemCount: recipeData!.stepList!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                              leading: Text(
                                  recipeData!.stepList![index].sequence
                                      .toString(),
                                  style: TextStyle(fontSize: 16)),
                              title: Text(
                                  recipeData!.stepList![index].description
                                      .capitalize(),
                                  style: TextStyle(fontSize: 16)));
                        },
                      ),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 40,
                            width: 100,
                            child: FloatingActionButton(
                              onPressed: () {
                                setState(() {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => EditFormPage(
                                          recipeId: widget.recipeId,
                                          catagoryId: widget.catagoryId)));
                                });
                              },
                              child: Text("Edit"),
                            ),
                          ),
                          //Spacer(),
                          SizedBox(
                            height: 40,
                            width: 100,
                            child: FloatingActionButton(
                              onPressed: () {
                                setState(() {
                                  recipeData!.deleteRecipeInfo(recipeData!.id);
                                  if (recipeData!.imageName != null) {
                                    recipeImg.delete();
                                  } else {}
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => CatagoryPage(
                                          catagoryId: widget.catagoryId)));
                                });
                              },
                              child: Text("Delete"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )));
        }
      },
      future: getRecipe(),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? catagoryName;
    switch (widget.catagoryId) {
      case 0:
        catagoryName = "APPETIZERS";
      case 1:
        catagoryName = "ENTREES";
      case 2:
        catagoryName = "DESSERTS";
      case 3:
        catagoryName = "LUNCH";
      case 4:
        catagoryName = "BREAKFAST";
      case 5:
        catagoryName = "OTHER";
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(catagoryName!),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                Navigator.pushNamed(context, 'catagory',
                    arguments: {"catagoryId": widget.catagoryId});
              });
            },
          )),
      body: recipeWidget(),
    );
  }
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
