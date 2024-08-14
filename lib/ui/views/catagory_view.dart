import 'package:cookingapp/models/recipe.dart';
import 'package:cookingapp/ui/views/add_recipe_view.dart';
import 'package:flutter/material.dart';
import 'package:cookingapp/ui/views/home_view.dart';
import 'package:cookingapp/ui/views/finished_recipe_view.dart';
import 'package:cookingapp/services/db_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'dart:developer';
import 'package:cookingapp/ui/router.dart'; 
import 'package:cookingapp/ui/views/recipe_stepper/recipe_stepper_view.dart';

class CatagoryPage extends StatefulWidget {
  final int? catagoryId;
  const CatagoryPage({super.key, required this.catagoryId});

  @override
  State<CatagoryPage> createState() => _CatagoryPageState();
}

class _CatagoryPageState extends State<CatagoryPage> {
  int _selectedIndex = 1;
  Directory? documentDirectory;

  Future<List<Recipe>> getAllRecipes() async {
    documentDirectory = await getApplicationDocumentsDirectory();

    String? catagoryName;
    switch (widget.catagoryId) {
      case 0: catagoryName = "APPETIZERS";
      case 1: catagoryName = "ENTREES";
      case 2: catagoryName = "DESSERTS";
      case 3: catagoryName = "LUNCH";
      case 4: catagoryName = "BREAKFAST";
      case 5: catagoryName = "OTHER";
    }

    DbHelper db = DbHelper();
    List<Map<String, Object?>> listOfRecipes = await db.getRecipesByCatagoryId(widget.catagoryId!);
    return [
      for (final {
            'id': id as int,
            'name': name as String,
            'yield': yieldValue as String,
            'time': time as int,
            'time_unit': timeUnit as String,
            'image': imageName as String?,
            'catagory_id': catagoryId as int,
            'notes': notes as String?
          } in listOfRecipes)
        Recipe(
            id: id,
            name: name,
            yieldValue: yieldValue,
            time: time,
            timeUnit: timeUnit,
            imageName: imageName,
            catagoryId: catagoryId,
            notes: notes,
            ),
    ];
  }

  Widget recipeListWidget() {
    return FutureBuilder(
      builder: (context, recipeSnap) {
        if (recipeSnap.data == null ||
            recipeSnap.connectionState == ConnectionState.none &&
                !recipeSnap.hasData) {
          //print('project snapshot data is: ${projectSnap.data}');
          return const Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: recipeSnap.data!.length,
            itemBuilder: (context, index) {
              Recipe recipe = recipeSnap.data![index];
              File recipeImg = File(path.join(documentDirectory!.path, 'image', recipe.id.toString()) +
                  recipe.imageName.toString());
                  log('image location - ' + recipeImg.path);
                
                  
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 50),
                height: 190,
                width: 180,
                child: Card(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 2),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              Navigator.pushNamed(context, 'finalRecipe', arguments: {'recipeId': recipe.id, 'catagoryId': widget.catagoryId});
                            });
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    recipe.imageName != null
                                        ? Image.file(
                                            recipeImg,
                                            height: 90,
                                            key: UniqueKey(),
                                          )
                                        : SizedBox(
                                            child: Image.network(
                                                'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
                                            height: 80,
                                          ),
                                    Text(recipe.name.capitalize(),
                                        style: TextStyle(fontSize: 20)),
                                  ],
                                )),
                              ]),
                        ),
                        Expanded(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete, size: 25),
                              onPressed: () {
                                setState(() {
                                  recipe.deleteRecipeInfo(recipe.id);
                                  if (recipe.imageName != null){
                                  recipeImg.delete();
                                  } else {}
                                });
                              },
                              tooltip: "Delete recipe",
                              color: Colors.white,
                            )
                          ],
                        ))
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
      future: getAllRecipes(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            VerticalNavBar(catagoryId: widget.catagoryId),
            Expanded(
              child: Center(
                child: recipeListWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VerticalNavBar extends StatefulWidget {
  final int? catagoryId;
  const VerticalNavBar({super.key, required this.catagoryId});

  @override
  State<VerticalNavBar> createState() => _VerticalNavBarState();
}

class _VerticalNavBarState extends State<VerticalNavBar> {
  @override
  Widget build(BuildContext context) {
    String? catagoryName;
    switch (widget.catagoryId) {
      case 0: catagoryName = "APPETIZERS";
      case 1: catagoryName = "ENTREES";
      case 2: catagoryName = "DESSERTS";
      case 3: catagoryName = "LUNCH";
      case 4: catagoryName = "BREAKFAST";
      case 5: catagoryName = "OTHER";
    }

    return Container(
      color: Theme.of(context).colorScheme.inversePrimary,
      height: double.infinity,
      alignment: Alignment.center,
      child: Column(
        children: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(
                  Icons.home,
                  size: 50,
                  color: Colors.white,
                  ),
                onPressed: () {
                  Navigator.pushNamed(context, 'home');
                },
              );
            },
          ),
          SizedBox(height: 10),
          RotatedBox(
            quarterTurns: 3,
            child: Text(
              catagoryName!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 50, // Adjust size as needed
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 10.0,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: RawMaterialButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'addRecipe', arguments: {"catagoryId": widget.catagoryId});
                  },
                  elevation: 0,
                  fillColor: Colors.white,
                  shape: CircleBorder(),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
