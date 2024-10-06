import 'dart:ui';

import 'package:cookingapp/models/step.dart';
import 'package:cookingapp/ui/views/add_recipe_view.dart';
import 'package:cookingapp/ui/views/edit_recipe_view.dart';
import 'package:cookingapp/ui/views/image_hero.dart';
import 'package:flutter/material.dart';
import 'package:cookingapp/ui/views/home_view.dart';
import 'package:cookingapp/ui/views/catagory_view.dart';
import 'package:cookingapp/models/recipe.dart';
import 'package:cookingapp/models/ingredient.dart';
import 'package:flutter/widgets.dart';
import 'dart:developer';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:cookingapp/ui/router.dart';
import 'package:cookingapp/ui/views/recipe_stepper_edit_view.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';

enum Menu { edit, delete, share }

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
      Recipe recipe) async {
        File recipeImg = File(path.join(documentDirectory!.path,
                        'image', recipe.id.toString()) +
                    recipe.imageName.toString());
      log("email image path - ${recipeImg.path}");

    List<String> ingredientEmailList = [];
    List<String> stepsEmailList = [];
    String ingredientsListed = """""";
    String stepsListed = """""";

    File getJsonFile = await recipe.toJson();

    for (Ingredient ingredient in recipe.ingredientList!) {
      ingredientEmailList.add(
          "${ingredient.amount} ${ingredient.unit} ${ingredient.ingredientName}");
    }
    for (recipeStep step in recipe.stepList!) {
      stepsEmailList.add(step.description);
    }

    for (String ingredient in ingredientEmailList) {
      ingredientsListed = ingredientsListed + "${ingredient}\n";
    }

    for (String step in stepsEmailList) {
      stepsListed = stepsListed + "${step}\n";
    }

    final Email email = Email(
      body: """ 
      Here is your recipe: 

      ${recipe.name} 

      Yield: ${recipe.yieldValue}
      Time: ${recipe.time}

      Notes: ${recipe.notes != null ? recipe.notes : "no notes"}

      Ingredients:
      $ingredientsListed
      Procedure: 
      $stepsListed

      Attached below is the image of the recipe (if one was chosen) and a file that can be imported into the "What's Cooking?" app should you want to directly transfer the recipe into the app.
      """,
      subject: "${recipe.name} - What's Cooking?",
      recipients: [''],
      attachmentPaths: [
        recipe.imageName != null ? recipeImg.path : "",
        getJsonFile.path,
        ],
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

              log("recipe image path - ${recipeImg.path}");

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
            return Center(
                // child: SafeArea(
                child: SingleChildScrollView(
                    child: Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: SizedBox(
                            //padding: const EdgeInsets.symmetric(horizontal: 32),
                            height: screenHeight,
                            child: orientation == Orientation.portrait
                                ? Column(
                                    children: [
                                      Text(recipeData!.name.capitalize(),
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ImageHero(
                                              height: screenHeight * 0.17,
                                              width: screenHeight * 0.17,
                                              image: recipeData!.imageName !=
                                                      null
                                                  ? Image.file(recipeImg,
                                                      key: UniqueKey())
                                                  : Container(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .inversePrimary,
                                                      child: Image.asset(
                                                          coverIcon),
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
                                                      title:
                                                          Text("Recipe Image"),
                                                    ),
                                                    body: Center(
                                                      child: Container(
                                                        // Set background to blue to emphasize that it's a new route.
                                                        //color: Colors.lightBlueAccent,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        child: ImageHero(
                                                          image: recipeData!
                                                                      .imageName !=
                                                                  null
                                                              ? Image.file(
                                                                  recipeImg,
                                                                  key:
                                                                      UniqueKey())
                                                              : Container(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .inversePrimary,
                                                                  child: Image
                                                                      .asset(
                                                                          coverIcon),
                                                                ),
                                                          width:
                                                              screenWidth * 0.9,
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }));
                                              }),
                                          SizedBox(
                                            width: screenWidth * 0.4,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "Yield: ${recipeData!.yieldValue}",
                                                    style: const TextStyle(
                                                        fontSize: 14)),
                                                Text(
                                                    "Time: ${getCleanNumber(recipeData!.time).toString()} ${getTimeUnit()}",
                                                    style: const TextStyle(
                                                        fontSize: 14)),
                                                const SizedBox(height: 30),
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
                                                              title: const Text(
                                                                  'Notes'),
                                                              content:
                                                                  Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                        border:
                                                                            Border.all()),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          12.0),
                                                                  child: Form(
                                                                    child:
                                                                        Column(
                                                                      children: <Widget>[
                                                                        Align(
                                                                          alignment:
                                                                              Alignment.topLeft,
                                                                          child: SizedBox(
                                                                              width: screenWidth * 0.7,
                                                                              child: Text(recipeData!.notes != null ? recipeData!.notes!.capitalize() : "No notes", style: const TextStyle(fontSize: 14))),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              actions: [
                                                                ElevatedButton(
                                                                    child: const Text(
                                                                        "Done"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    })
                                                              ],
                                                            );
                                                          });
                                                    },
                                                    child: const Text("Notes"),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      //SizedBox(height: 30),
                                      Container(
                                          alignment: Alignment.centerLeft,
                                          child: const Text("Ingredients List:",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      SizedBox(
                                        child: ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          // itemExtent: 40.0,
                                          padding: const EdgeInsets.all(16.0),
                                          itemCount: recipeData!
                                              .ingredientList!.length,
                                          prototypeItem: const Row(
                                            children: [Text("")],
                                          ),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  //width: 200,
                                                  child: Text(
                                                      recipeData!
                                                          .ingredientList![
                                                              index]
                                                          .ingredientName
                                                          .capitalize(),
                                                      style: const TextStyle(
                                                          fontSize: 14)),
                                                ),
                                                Column(
                                                    // child: FractionallySizedBox(
                                                    //   widthFactor: 0.5,
                                                    children: [
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            SizedBox(
                                                              //width: 50,
                                                              child: Text(
                                                                  getCleanNumber(recipeData!
                                                                          .ingredientList![
                                                                              index]
                                                                          .amount)
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14)),
                                                            ),
                                                            SizedBox(width: 20),
                                                            SizedBox(
                                                              width: 50,
                                                              child: Text(
                                                                  getIngredientUnit(
                                                                      index),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14)),
                                                            ),
                                                          ]),
                                                    ]),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      //SizedBox(height: 30),
                                      Container(
                                          alignment: Alignment.centerLeft,
                                          child: const Text("Procedure:",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      Flexible(
                                          //width: 200,
                                          //height: screenHeight * 0.15,
                                          // children: [
                                          child: CupertinoScrollbar(
                                        //thumbVisibility: true,
                                        child: ListView(
                                          //shrinkWrap: true,
                                          //physics: NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.all(16.0),
                                          children: List.generate(
                                            recipeData!.stepList!.length,
                                            (int index) {
                                              // physics:
                                              //     NeverScrollableScrollPhysics(),
                                              //    shrinkWrap: true,
                                              //     padding: EdgeInsets.all(16.0),
                                              //      itemCount: recipeData!
                                              //         .stepList!.length,
                                              //      itemBuilder:
                                              //           (BuildContext context,
                                              //              int index) {
                                              return ListTile(
                                                  titleAlignment:
                                                      ListTileTitleAlignment
                                                          .top,
                                                  leading: Text(
                                                      textAlign:
                                                          TextAlign.center,
                                                      recipeData!
                                                          .stepList![index]
                                                          .sequence
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      )),
                                                  title: Text(
                                                      recipeData!
                                                          .stepList![index]
                                                          .description
                                                          .capitalize(),
                                                      style: TextStyle(
                                                          fontSize: 14)));
                                            },
                                          ),
                                        ),
                                      )
                                          //  ]
                                          ),
                                    ],
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Text(recipeData!.name.capitalize(),
                                            style: const TextStyle(
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
                                                image: recipeData!.imageName !=
                                                        null
                                                    ? Image.file(recipeImg,
                                                        key: UniqueKey())
                                                    : Container(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .inversePrimary,
                                                        child: Image.asset(
                                                            coverIcon),
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
                                                        title: Text(
                                                            "Recipe Image"),
                                                      ),
                                                      body: Center(
                                                        child: Container(
                                                          // Set background to blue to emphasize that it's a new route.
                                                          //color: Colors.lightBlueAccent,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16),
                                                          child: ImageHero(
                                                            image: recipeData!
                                                                        .imageName !=
                                                                    null
                                                                ? Image.file(
                                                                    recipeImg,
                                                                    key:
                                                                        UniqueKey())
                                                                : Container(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .inversePrimary,
                                                                    child: Image
                                                                        .asset(
                                                                            coverIcon),
                                                                  ),
                                                            width: screenWidth *
                                                                0.9,
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
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
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      "Yield: ${recipeData!.yieldValue}",
                                                      style: TextStyle(
                                                          fontSize: 14)),
                                                  SizedBox(
                                                      //width: 80,
                                                      child: Text(
                                                          "Time: ${getCleanNumber(recipeData!.time).toString()} ${getTimeUnit()}",
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
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                scrollable:
                                                                    true,
                                                                title: Text(
                                                                    'Notes'),
                                                                content:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          border:
                                                                              Border.all()),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            12.0),
                                                                    child: Form(
                                                                      child:
                                                                          Column(
                                                                        children: <Widget>[
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.topLeft,
                                                                            child:
                                                                                Container(width: screenWidth * 0.7, child: Text(recipeData!.notes != null ? recipeData!.notes!.capitalize() : "No notes", style: TextStyle(fontSize: 14))),
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
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                          "Ingredients List:",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))),
                                                  SizedBox(
                                                    height: screenHeight * 0.2,
                                                    child: ListView.builder(
                                                      /*physics:
                                                  NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,*/
                                                      //padding: EdgeInsets.all(16.0),
                                                      itemCount: recipeData!
                                                          .ingredientList!
                                                          .length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Flexible(
                                                              //width: 200,
                                                              child: Text(
                                                                  recipeData!
                                                                      .ingredientList![
                                                                          index]
                                                                      .ingredientName
                                                                      .capitalize(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14)),
                                                            ),
                                                            Column(children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                      getCleanNumber(recipeData!
                                                                              .ingredientList![
                                                                                  index]
                                                                              .amount)
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14)),
                                                                  SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                  Text(
                                                                      recipeData!
                                                                          .ingredientList![
                                                                              index]
                                                                          .unit,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14))
                                                                ],
                                                              ),
                                                            ]),
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
                                        SizedBox(height: 30),
                                        Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text("Procedure:",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        Flexible(
                                          //width: 200,
                                          //height: screenHeight * 0.15,
                                          child: Scrollbar(
                                            child: ListView.builder(
                                              // physics:
                                              //     NeverScrollableScrollPhysics(),
                                              //  shrinkWrap: true,
                                              padding: EdgeInsets.all(16.0),
                                              itemCount:
                                                  recipeData!.stepList!.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return ListTile(
                                                    titleAlignment:
                                                        ListTileTitleAlignment
                                                            .top,
                                                    leading: Text(
                                                        recipeData!
                                                            .stepList![index]
                                                            .sequence
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 14)),
                                                    title: Text(
                                                        recipeData!
                                                            .stepList![index]
                                                            .description
                                                            .capitalize(),
                                                        style: TextStyle(
                                                            fontSize: 14)));
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    )))))
                //   )
                );
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
            PopupMenuButton<Menu>(
              icon: Icon(Icons.more_horiz),
              onSelected: (Menu item) async {
                Recipe recipeInfo = await getRecipe();
                File recipeImg = File(path.join(documentDirectory!.path,
                        'image', recipeInfo.id.toString()) +
                    recipeInfo.imageName.toString());
                if (item == Menu.edit) {
                  setState(() {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => EditFormPage(
                            recipeId: widget.recipeId,
                            catagoryId: widget.catagoryId)));
                  });
                } else if (item == Menu.delete) {
                  setState(() {
                    recipeData!.deleteRecipeInfo(recipeData!.id);
                    if (recipeData!.imageName != null) {
                      recipeImg.delete();
                    } else {}
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            CatagoryPage(catagoryId: widget.catagoryId)));
                  });
                } else {
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
                                      setState(() {
                                        sendRecipeViaEmail(recipeInfo);
                                      });
                                    }),
                              ],
                            )
                          ],
                        );
                      });
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
                const PopupMenuItem<Menu>(
                  value: Menu.edit,
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                  ),
                ),
                const PopupMenuItem<Menu>(
                  value: Menu.delete,
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                  ),
                ),
                const PopupMenuItem<Menu>(
                  value: Menu.share,
                  child: ListTile(
                    leading: Icon(Icons.send),
                    title: Text('Share'),
                  ),
                ),
              ],
            )
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
