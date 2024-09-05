import 'package:cookingapp/models/step.dart';
import 'package:cookingapp/ui/views/add_recipe_view.dart';
import 'package:cookingapp/ui/views/edit_recipe_view.dart';
import 'package:cookingapp/ui/views/image_hero.dart';
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
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_email_sender/flutter_email_sender.dart';

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
  late String catagoryName;

  @override
  void initState() {
    super.initState();
    switch (widget.catagoryId) {
      case 0:
        catagoryImage = "assets/images/appetizers-icon.PNG";
        catagoryName = "APPETIZERS";
      case 1:
        catagoryImage = "assets/images/entrees-icon.PNG";
        catagoryName = "ENTREES";
      case 2:
        catagoryImage = "assets/images/dessert-icon.PNG";
        catagoryName = "DESSERTS";
      case 3:
        catagoryImage = "assets/images/breakfast-icon.PNG";
        catagoryName = "LUNCH";
      case 4:
        catagoryImage = "assets/images/lunch-icon.PNG";
        catagoryName = "BREAKFAST";
      case 5:
        catagoryImage = "assets/images/others-icon.PNG";
        catagoryName = "OTHERS";
    }
  }

  void sendRecipeViaEmail(
      String recipeName,
      String yieldAmount,
      String time,
      List<String> ingredients,
      List<String> steps,
      String? notes,
      String? imgPath) async {
    String ingredientsListed = """""";
    for (String ingredient in ingredients) {
      ingredientsListed = ingredientsListed + "${ingredient}\n";
    }

    String stepsListed = """""";
    for (String step in steps) {
      stepsListed = stepsListed + "${step}\n";
    }

    final Email email = Email(
      body: """ $recipeName 

      Yield: $yieldAmount
      Time: $time

      Notes: ${notes != null ? notes : "no notes"}

      Ingredients:
      $ingredientsListed
      Procedure: 
      $stepsListed
      """,
      subject: "$recipeName - What's Cooking?",
      recipients: [''],
      attachmentPaths: [imgPath != null ? imgPath : ""],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      log('Error sending email: $error');
    }

    if (context.mounted) {
      Navigator.of(context).pop();
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
        timeDilation = 1.5;

        if (recipeSnap.data == null ||
            recipeSnap.connectionState == ConnectionState.none &&
                !recipeSnap.hasData) {
          //print('project snapshot data is: ${projectSnap.data}');
          return const Center(child: CircularProgressIndicator());
        } else {
          File recipeImg = File(path.join(
                  documentDirectory!.path, 'image', recipeData!.id.toString()) +
              recipeData!.imageName.toString());

          String getTimeUnit() {
            if (recipeData!.timeUnit == "Hour(s)") {
              if (recipeData!.time <= 1) {
                return "Hour";
              } else {
                return "Hours";
              }
            } else {
              return recipeData!.timeUnit;
            }
          }

          String getIngredientUnit(int index) {
            if (recipeData!.ingredientList![index].unit == "n/a") {
              return "";
            } else {
              return recipeData!.ingredientList![index].unit;
            }
          }

          dynamic getCleanNumber(double amount) {
            if (amount == (amount).floor()) {
              return amount.toInt();
            } else {
              return amount;
            }
          }

          return Builder(builder: (context) {
            final orientation = MediaQuery.of(context).orientation;
            return Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Center(
                    child: SafeArea(
                        child: orientation == Orientation.portrait
                            ? Column(
                                children: [
                                  Text(recipeData!.name.capitalize(),
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ImageHero(
                                          height: screenHeight * 0.17,
                                          width: screenHeight * 0.17,
                                          image: recipeData!.imageName != null
                                              ? Image.file(recipeImg,
                                                  key: UniqueKey())
                                              : Container(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inversePrimary,
                                                  child: Image.asset(coverIcon),
                                                ),
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute<void>(
                                                    builder: (context) {
                                              return Scaffold(
                                                appBar: AppBar(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .inversePrimary,
                                                  title: Text("Recipe Image"),
                                                ),
                                                body: Center(
                                                  child: Container(
                                                    // Set background to blue to emphasize that it's a new route.
                                                    //color: Colors.lightBlueAccent,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    child: ImageHero(
                                                      image: recipeData!
                                                                  .imageName !=
                                                              null
                                                          ? Image.file(
                                                              recipeImg,
                                                              key: UniqueKey())
                                                          : Container(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .inversePrimary,
                                                              child: Image.asset(
                                                                  coverIcon),
                                                            ),
                                                      width: screenWidth * 0.9,
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }));
                                          }),
                                      Container(
                                        width: screenWidth * 0.4,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Yield: ${recipeData!.yieldValue}",
                                                style: TextStyle(fontSize: 14)),
                                            Text(
                                                "Time: ${getCleanNumber(recipeData!.time).toString()} ${getTimeUnit()}",
                                                style: TextStyle(fontSize: 14)),
                                            SizedBox(height: 30),
                                            SizedBox(
                                              width: 120,
                                              height: 40,
                                              child: OutlinedButton(
                                                onPressed: () async {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          scrollable: true,
                                                          title: Text('Notes'),
                                                          content: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                                    border: Border
                                                                        .all()),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      12.0),
                                                              child: Form(
                                                                child: Column(
                                                                  children: <Widget>[
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .topLeft,
                                                                      child: Container(
                                                                          width: screenWidth *
                                                                              0.7,
                                                                          child: Text(
                                                                              recipeData!.notes != null ? recipeData!.notes!.capitalize() : "No notes",
                                                                              style: TextStyle(fontSize: 14))),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          actions: [
                                                            ElevatedButton(
                                                                child: Text(
                                                                    "Done"),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
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
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold))),
                                  SizedBox(
                                    height: screenHeight * 0.15,
                                    child: ListView.builder(
                                      padding: EdgeInsets.all(16.0),
                                      itemCount:
                                          recipeData!.ingredientList!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              //width: 200,
                                              child: Text(
                                                  recipeData!
                                                      .ingredientList![index]
                                                      .ingredientName
                                                      .capitalize(),
                                                  style:
                                                      TextStyle(fontSize: 14)),
                                            ),
                                            Flexible(
                                              child: FractionallySizedBox(
                                                widthFactor: 0.5,
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      //width: 50,
                                                      child: Text(
                                                          getCleanNumber(recipeData!
                                                                      .ingredientList![
                                                                          index]
                                                                      .amount)
                                                                  .toString() +
                                                              " " +
                                                              getIngredientUnit(
                                                                  index),
                                                          style: TextStyle(
                                                              fontSize: 14)),
                                                    ),
                                                    /*SizedBox(
                                                        width: 70,
                                                        child: Text(
                                                            recipeData!
                                                                .ingredientList![
                                                                    index]
                                                                .unit,
                                                            style: TextStyle(
                                                                fontSize: 14))),*/
                                                  ],
                                                ),
                                              ),
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
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold))),
                                  SizedBox(
                                    //width: 200,
                                    height: screenHeight * 0.15,
                                    child: ListView.builder(
                                      padding: EdgeInsets.all(16.0),
                                      itemCount: recipeData!.stepList!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ListTile(
                                            leading: Text(
                                                recipeData!
                                                    .stepList![index].sequence
                                                    .toString(),
                                                style: TextStyle(fontSize: 14)),
                                            title: Text(
                                                recipeData!.stepList![index]
                                                    .description
                                                    .capitalize(),
                                                style:
                                                    TextStyle(fontSize: 14)));
                                      },
                                    ),
                                  ),
                                  Spacer(),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          width: 100,
                                          child: FloatingActionButton(
                                            onPressed: () {
                                              setState(() {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            EditFormPage(
                                                                recipeId: widget
                                                                    .recipeId,
                                                                catagoryId: widget
                                                                    .catagoryId)));
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
                                                recipeData!.deleteRecipeInfo(
                                                    recipeData!.id);
                                                if (recipeData!.imageName !=
                                                    null) {
                                                  recipeImg.delete();
                                                } else {}
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CatagoryPage(
                                                                catagoryId: widget
                                                                    .catagoryId)));
                                              });
                                            },
                                            child: Text("Delete"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Text(recipeData!.name.capitalize(),
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ImageHero(
                                          height: screenHeight * 0.3,
                                          width: screenHeight * 0.3,
                                          image: recipeData!.imageName != null
                                              ? Image.file(recipeImg,
                                                  key: UniqueKey())
                                              : Container(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inversePrimary,
                                                  child: Image.asset(coverIcon),
                                                ),
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute<void>(
                                                    builder: (context) {
                                              return Scaffold(
                                                appBar: AppBar(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .inversePrimary,
                                                  title: Text("Recipe Image"),
                                                ),
                                                body: Center(
                                                  child: Container(
                                                    // Set background to blue to emphasize that it's a new route.
                                                    //color: Colors.lightBlueAccent,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    child: ImageHero(
                                                      image: recipeData!
                                                                  .imageName !=
                                                              null
                                                          ? Image.file(
                                                              recipeImg,
                                                              key: UniqueKey())
                                                          : Container(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .inversePrimary,
                                                              child: Image.asset(
                                                                  coverIcon),
                                                            ),
                                                      width: screenWidth * 0.9,
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }));
                                          }),
                                      SizedBox(width: 20),
                                      Container(
                                        width: screenWidth * 0.2,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Yield: ${recipeData!.yieldValue}",
                                                style: TextStyle(fontSize: 14)),
                                            SizedBox(
                                                //width: 80,
                                                child: Text(
                                                    "Time: ${recipeData!.time.toString()} ${getTimeUnit()}",
                                                    style: TextStyle(
                                                        fontSize: 14))),
                                            SizedBox(height: 20),
                                            SizedBox(
                                              width: 120,
                                              height: 40,
                                              child: OutlinedButton(
                                                onPressed: () async {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          scrollable: true,
                                                          title: Text('Notes'),
                                                          content: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                                    border: Border
                                                                        .all()),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      12.0),
                                                              child: Form(
                                                                child: Column(
                                                                  children: <Widget>[
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .topLeft,
                                                                      child: Container(
                                                                          width: screenWidth *
                                                                              0.7,
                                                                          child: Text(
                                                                              recipeData!.notes != null ? recipeData!.notes!.capitalize() : "No notes",
                                                                              style: TextStyle(fontSize: 14))),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          actions: [
                                                            ElevatedButton(
                                                                child: Text(
                                                                    "Done"),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
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
                                      //Spacer(),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Container(
                                                alignment: Alignment.centerLeft,
                                                child: Text("Ingredients List:",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            SizedBox(
                                              height: screenHeight * 0.2,
                                              child: ListView.builder(
                                                padding: EdgeInsets.all(16.0),
                                                itemCount: recipeData!
                                                    .ingredientList!.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        width: 200,
                                                        child: Text(
                                                            recipeData!
                                                                .ingredientList![
                                                                    index]
                                                                .ingredientName
                                                                .capitalize(),
                                                            style: TextStyle(
                                                                fontSize: 14)),
                                                      ),
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 50,
                                                            child: Text(
                                                                recipeData!
                                                                    .ingredientList![
                                                                        index]
                                                                    .amount
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14)),
                                                          ),
                                                          SizedBox(
                                                              width: 70,
                                                              child: Text(
                                                                  recipeData!
                                                                      .ingredientList![
                                                                          index]
                                                                      .unit,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14))),
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                },
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
                                      child: Text("Procedure:",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold))),
                                  SizedBox(
                                    //width: 200,
                                    height: screenHeight * 0.15,
                                    child: ListView.builder(
                                      padding: EdgeInsets.all(16.0),
                                      itemCount: recipeData!.stepList!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ListTile(
                                            leading: Text(
                                                recipeData!
                                                    .stepList![index].sequence
                                                    .toString(),
                                                style: TextStyle(fontSize: 14)),
                                            title: Text(
                                                recipeData!.stepList![index]
                                                    .description
                                                    .capitalize(),
                                                style:
                                                    TextStyle(fontSize: 14)));
                                      },
                                    ),
                                  ),
                                  Spacer(),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          width: 100,
                                          child: FloatingActionButton(
                                            onPressed: () {
                                              setState(() {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            EditFormPage(
                                                                recipeId: widget
                                                                    .recipeId,
                                                                catagoryId: widget
                                                                    .catagoryId)));
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
                                                recipeData!.deleteRecipeInfo(
                                                    recipeData!.id);
                                                if (recipeData!.imageName !=
                                                    null) {
                                                  recipeImg.delete();
                                                } else {}
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CatagoryPage(
                                                                catagoryId: widget
                                                                    .catagoryId)));
                                              });
                                            },
                                            child: Text("Delete"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                ],
                              ))));
          });
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

    List<String> ingredientEmailList = [];
    List<String> stepsEmailList = [];

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
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          scrollable: true,
                          title: Text('Send Recipe'),
                          content: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Form(
                                child: Column(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                          height: 100,
                                          child: Text(
                                            'All data in this recipe will be emailed to the recipient of your choice. Press "Send" to continue.',
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                    child: Text("Cancel"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    }),
                                ElevatedButton(
                                    child: Text("Send"),
                                    onPressed: () async {
                                      Recipe recipeInfo = await getRecipe();
                                      for (Ingredient ingredient
                                          in recipeInfo.ingredientList!) {
                                        ingredientEmailList.add(
                                            "${ingredient.amount} ${ingredient.unit} ${ingredient.ingredientName}");
                                      }
                                      for (recipeStep step
                                          in recipeInfo.stepList!) {
                                        stepsEmailList.add(step.description);
                                      }
                                      File recipeImg = File(path.join(
                                              documentDirectory!.path,
                                              'image',
                                              recipeInfo.id.toString()) +
                                          recipeInfo.imageName.toString());
                                      setState(() {
                                        sendRecipeViaEmail(
                                            recipeInfo.name,
                                            recipeInfo.yieldValue,
                                            recipeInfo.time.toString() +
                                                " " +
                                                recipeData!.timeUnit,
                                            ingredientEmailList,
                                            stepsEmailList,
                                            recipeInfo.notes,
                                            recipeImg.path);
                                      });
                                    }),
                              ],
                            )
                          ],
                        );
                      });
                })
          ],
        ),
        body: recipeWidget());
  }
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
