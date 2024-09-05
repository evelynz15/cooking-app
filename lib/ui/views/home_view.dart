import 'package:cookingapp/ui/views/onboard_screen.dart';
import 'package:cookingapp/ui/views/setting_view.dart';
import 'package:flutter/material.dart';
import 'package:cookingapp/ui/views/catagory_view.dart';
import 'package:cookingapp/ui/router.dart';
import 'package:cookingapp/services/db_helper.dart';
import 'package:cookingapp/models/recipe.dart';
import 'package:cookingapp/ui/views/recipe_stepper/recipe_stepper_view.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  Map<int, String> catagoryNames = {
    0: "APPETIZERS",
    1: "ENTREES",
    2: "DESSERT",
    3: "LUNCH",
    4: "BREAKFAST",
    5: "OTHERS"
  };

  /*List<String> backgroundImages = [
    "assets/images/appetizer-background.png",
    "assets/images/entree-background.png",
    "assets/images/dessert-background.png",
    "assets/images/lunch-background.png",
    "assets/images/breakfast-background.png",
    "assets/images/others-background.png"
  ];*/

  List<String> backgroundImages = [
    "assets/images/appetizers-icon.PNG",
    "assets/images/entrees-icon.PNG",
    "assets/images/dessert-icon.PNG",
    "assets/images/lunch-icon.PNG",
    "assets/images/breakfast-icon.PNG",
    "assets/images/others-icon.PNG"
  ];

  String query = '';
  List<Recipe> searchResults = [];

  void navigateToCatagory(catagoryId) {
    setState(() {
      Navigator.pushNamed(context, 'catagory',
          arguments: {"catagoryId": catagoryId});
    });
  }

  Future<List<Recipe>> getAllRecipes() async {
    DbHelper db = DbHelper();
    List<Map<String, Object?>> listOfRecipes = await db.getAllRecipes();
    return [
      for (final {
            'id': id as int,
            'name': name as String,
            'yield': yieldValue as String,
            'time': time as double,
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

  Widget searchBarWidget() {
    return FutureBuilder(
        future: getAllRecipes(),
        builder: (context, recipeSnap) {
          if (recipeSnap.data == null ||
              recipeSnap.connectionState == ConnectionState.none &&
                  !recipeSnap.hasData) {
            //print('project snapshot data is: ${projectSnap.data}');
            return const Center(child: CircularProgressIndicator());
          } else {
            return SearchAnchor(
                builder: (BuildContext context, SearchController controller) {
              return SearchBar(
                controller: controller,
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0)),
                onTap: () {
                  controller.openView();
                },
                onChanged: (value) {
                  /*setState(() {
                    query = value;
                    for (Recipe recipe in recipeSnap.data!) {
                      searchResults.add(recipe.name);
                    }
                    searchResults
                        .where((item) =>
                            item.toLowerCase().contains(query.toLowerCase()))
                        .toList();
                  });
                  controller.openView();*/
                },
                leading: const Icon(Icons.search),
              );
            }, suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
              query = controller.text;
              searchResults.clear();
              if (query.isNotEmpty) {
                for (Recipe recipe in recipeSnap.data!) {
                  if (recipe.name.toLowerCase().contains(query.toLowerCase())) {
                    searchResults.add(recipe);
                  }
                }
              }
              return List<ListTile>.generate(searchResults.length, (int index) {
                return ListTile(
                  title: Text(searchResults[index].name),
                  onTap: () {
                    setState(() {
                      //controller.closeView(searchResults[index]);
                      Navigator.pushNamed(context, "finalRecipe", arguments: {
                        "catagoryId": searchResults[index].catagoryId,
                        "recipeId": searchResults[index].id
                      });
                    });
                  },
                );
              });
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
      
        //learned from post at
        //https://stackoverflow.com/questions/57888097/flutter-how-to-set-drawer-header-width-to-the-max
        drawer: SafeArea(
          child: Drawer(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // padding: EdgeInsets.zero,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        DrawerHeader(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text("What's Cooking?")),
                        ),
                        ListTile(
                          title: const Text('Home'),
                          selected: _selectedIndex == 0,
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              Navigator.pushNamed(context, 'home');
                            });
                          },
                        ),
                        ListTile(
                          title: const Text('Appetizers'),
                          onTap: () {
                            Navigator.pop(context);
                            navigateToCatagory(0);
                          },
                        ),
                        ListTile(
                          title: const Text('Entrees'),
                          onTap: () {
                            Navigator.pop(context);
                            navigateToCatagory(1);
                          },
                        ),
                        ListTile(
                          title: const Text('Desserts'),
                          onTap: () {
                            Navigator.pop(context);
                            navigateToCatagory(2);
                          },
                        ),
                        ListTile(
                          title: const Text('Lunch'),
                          onTap: () {
                            Navigator.pop(context);
                            navigateToCatagory(3);
                          },
                        ),
                        ListTile(
                          title: const Text('Breakfast'),
                          onTap: () {
                            Navigator.pop(context);
                            navigateToCatagory(4);
                          },
                        ),
                        ListTile(
                          title: const Text('Others'),
                          onTap: () {
                            Navigator.pop(context);
                            navigateToCatagory(5);
                          },
                        ),
                        ListTile(
                      title: const Text('Onboarding'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => OnboardScreen()));
                      },
                    ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: const Text('Settings'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingView()));
                      },
                    ),
                  ),
                ]),
          ),
        ),
      
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                searchBarWidget(),
                SizedBox(height: 50),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: catagoryNames.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildCatagoryCard(
                          catagoryNames[index]!, index, backgroundImages[index]);
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCatagoryCard(
      String catagoryName, int catagoryId, String backgroundImage) {
    return InkWell(
      splashColor: Colors.blue.withAlpha(30),
      onTap: () {
        navigateToCatagory(catagoryId);
      },
      child: Container(
        width: 400,
        height: 150,
        child: Card(
          color: Theme.of(context).colorScheme.inversePrimary,
          child: 
              /*Positioned.fill(
                child: Opacity(
                  opacity: 0.5,
                  child: Image.asset(
                    backgroundImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),*/
              Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Image.asset(backgroundImage, width: 75),
                    //Spacer(),
                    //Expanded(
                      //child: 
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          catagoryName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22, // Adjust size as needed
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    //),
                    ]
                  )),
          
          ),
        ),
      );
  }
}
