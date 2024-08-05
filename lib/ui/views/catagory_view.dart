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

class CatagoryPage extends StatefulWidget {
  const CatagoryPage({super.key});

  @override
  State<CatagoryPage> createState() => _CatagoryPageState();
}

class _CatagoryPageState extends State<CatagoryPage> {
  int _selectedIndex = 1;
  Directory? documentDirectory;

  Future<List<Recipe>> getAllRecipes() async {
    documentDirectory = await getApplicationDocumentsDirectory();

    DbHelper db = DbHelper();
    List<Map<String, Object?>> listOfRecipes = await db.getAllRecipes();
    return [
      for (final {
            'id': id as int,
            'name': name as String,
            'yield': yieldValue as String,
            'time': time as int,
            'time_unit': timeUnit as String,
            'image': imageName as String?
          } in listOfRecipes)
        Recipe(
            id: id,
            name: name,
            yieldValue: yieldValue,
            time: time,
            timeUnit: timeUnit,
            imageName: imageName),
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
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FinishedRecipe(
                                          recipeId: recipe.id!)));
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

                        /*ListTile(
                              title: Text(recipe.name),
                              trailing: IconButton(
                                onPressed: () {
                                  log('test');
                                },
                                tooltip: "Delete recipe",
                                icon: Icon(Icons.delete, size: 20),
                                color: Colors.white,
                              )),*/
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text("What's Cooking?"),
            ),
            ListTile(
              title: const Text('Home'),
              selected: _selectedIndex == 0,
              onTap: () {
                //_onItemTapped(0);
                Navigator.pop(context);
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MyHomePage(title: "What's Cooking?")));
                });
              },
            ),
            ListTile(
              title: const Text('Desserts'),
              selected: _selectedIndex == 1,
              onTap: () {
                //_onItemTapped(1);
                Navigator.pop(context);
                setState(() {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CatagoryPage()));
                });
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Row(
          children: [
            VerticalNavBar(),
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

class VerticalNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.inversePrimary,
      height: double.infinity,
      alignment: Alignment.center,
      child: Column(
        children: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          RotatedBox(
            quarterTurns: 3,
            child: Text(
              'DESSERTS',
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewRecipePage()));
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
