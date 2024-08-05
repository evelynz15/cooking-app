import 'dart:io';
import 'dart:core';
import 'package:cookingapp/ui/views/finished_recipe_view.dart';
import 'package:flutter/material.dart';
import 'package:cookingapp/ui/views/home_view.dart';
import 'package:cookingapp/ui/views/catagory_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:cookingapp/models/recipe.dart';
import 'package:cookingapp/models/ingredient.dart';
import 'package:cookingapp/models/step.dart';
import 'dart:developer';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

enum ImageSourceType { gallery, camera }

class EditRecipePage extends StatefulWidget {
  final int recipeId;

  const EditRecipePage({super.key, required this.recipeId});

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  Directory? documentDirectory;

  ImageSourceType? selectedImageSource;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController? _recipeController;

  TextEditingController? _yieldController1;

  TextEditingController? _timeController2;

  final List _ingredients = [1];
  final List _steps = [1];

  var _image;
  var imagePicker;
  var type;

  int i = 1;
  int q = 1;

  List<TextEditingController> listOfNameControllerIngredients = [];
  List<TextEditingController> listOfNameControllerSteps = [];
  List<TextEditingController> listOfNameControllerUnits = [];

  final List<String> units = ["Tsp", "Tbsp", "Cup", "n/a"];
  Map<int, String> selectedUnit = {};

  final List<String> timeUnits = ["Hour(s)", "Minutes"];
  String? selectedTime;

  List<Ingredient>? selectedIngredientList;

  late Future<Recipe>? recipeData;

  @override
  void initState() {
    super.initState();
    recipeData = getRecipe();
  }

  void addNewIngredient() {
    setState(() {
      i++;
      _ingredients.add(i);
      listOfNameControllerIngredients.add(TextEditingController());
      listOfNameControllerUnits.add(TextEditingController());
      selectedIngredientList!.add(Ingredient());
    });
  }

  void addNewStep() {
    setState(() {
      q++;
      _steps.add(q);
      listOfNameControllerSteps.add(TextEditingController());
    });
  }

  Future<Recipe> getRecipe() async {
    documentDirectory = await getApplicationDocumentsDirectory();
    return await Recipe.getRecipeById(widget.recipeId);
    //selectedTime = recipeData!.timeUnit;
    //return recipeData!;
  }

  Widget editRecipeWidget() {
    return FutureBuilder(
        builder: (context, recipeSnap) {
          if (recipeSnap.data == null ||
              recipeSnap.connectionState == ConnectionState.none &&
                  !recipeSnap.hasData) {
            //print('project snapshot data is: ${projectSnap.data}');
            return const Center(child: CircularProgressIndicator());
          } else {
            //initialize the textbox text and ingredient list with the data fetched from DB if the page is loaded first time.
            if (_recipeController == null) {
              _recipeController =
                  TextEditingController(text: recipeSnap.data!.name);
              _yieldController1 =
                  TextEditingController(text: recipeSnap.data!.yieldValue);
              _timeController2 =
                  TextEditingController(text: recipeSnap.data!.time.toString());
              for (Ingredient ingredientInfo
                  in recipeSnap.data!.ingredientList!) {
                listOfNameControllerIngredients.add(
                    TextEditingController(text: ingredientInfo.ingredientName));
                listOfNameControllerUnits.add(TextEditingController(
                    text: ingredientInfo.amount.toString()));
              }
              for (recipeStep step in recipeSnap.data!.stepList!) {
                listOfNameControllerSteps
                    .add(TextEditingController(text: step.description));
              }
              selectedTime = recipeSnap.data!.timeUnit;
              selectedIngredientList = recipeSnap.data!.ingredientList;
              File recipeImg = File(path.join(documentDirectory!.path, 'image',
                      recipeSnap.data!.id.toString()) +
                  recipeSnap.data!.imageName.toString());
              recipeSnap.data!.imageName != null ? _image = recipeImg : _image;
            }

            return SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                  child: Center(
                      child: Column(
                    children: [
                      _buildFormField("Title of Recipe", _recipeController!),
                      SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Container(
                                height: 160,
                                width: 160,
                                child: _image != null
                                    ? Image.file(
                                        _image,
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.fitHeight,
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                            color: Colors.red[200]),
                                        width: 200,
                                        height: 200,
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                              ),
                              SizedBox(
                                width: 140,
                                child: PopupMenuButton<ImageSourceType>(
                                  initialValue: selectedImageSource,
                                  onSelected: (ImageSourceType item) async {
                                    imagePicker = ImagePicker();
                                    var source = item == ImageSourceType.camera
                                        ? ImageSource.camera
                                        : ImageSource.gallery;
                                    XFile image = await imagePicker.pickImage(
                                        source: source,
                                        imageQuality: 50,
                                        preferredCameraDevice:
                                            CameraDevice.front);
                                    setState(() {
                                      selectedImageSource = item;
                                      _image = File(image.path);
                                    });
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<ImageSourceType>>[
                                    const PopupMenuItem<ImageSourceType>(
                                      value: ImageSourceType.gallery,
                                      child: Text('Pick image from gallery'),
                                    ),
                                    const PopupMenuItem<ImageSourceType>(
                                      value: ImageSourceType.camera,
                                      child: Text('Pick image from camera'),
                                    ),
                                  ],
                                  icon: Icon(
                                    Icons.add,
                                    color: Colors.grey[800],
                                  ),
                                  tooltip: "Add new image",
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildFormField("Yield", _yieldController1!),
                                Row(
                                  children: [
                                    SizedBox(
                                        width: 50,
                                        child: _buildFormField(
                                          "Time",
                                          _timeController2!,
                                        )),
                                    DropdownButton<String>(
                                      value: selectedTime,
                                      hint: Text('Unit'),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedTime = newValue ?? '';
                                        });
                                      },
                                      items: timeUnits
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
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
                          child: Row(
                            children: [
                              Text("Ingredients List:"),
                              SizedBox(width: 25),
                              Container(
                                width: 70,
                                height: 30,
                                child: FloatingActionButton(
                                  onPressed: addNewIngredient,
                                  child: Icon(Icons.add),
                                ),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16.0),
                          itemCount: _ingredients.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: _buildFormField("${index + 1}",
                                      listOfNameControllerIngredients[index]),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      child: _buildFormField(
                                        "Amount",
                                        listOfNameControllerUnits[index],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 70,
                                      child: DropdownButton<String>(
                                        value:
                                            selectedIngredientList![index].unit,
                                        hint: Text('Unit'),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedIngredientList![index]
                                                .unit = newValue ?? '';
                                          });
                                        },
                                        items: units
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
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
                          child: Row(
                            children: [
                              Text("Procedure:"),
                              SizedBox(width: 25),
                              Container(
                                width: 70,
                                height: 30,
                                child: FloatingActionButton(
                                  onPressed: addNewStep,
                                  child: Icon(Icons.add),
                                ),
                              ),
                            ],
                          )),
                      SizedBox(
                        //width: 200,
                        height: 100,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16.0),
                          itemCount: _steps.length,
                          itemBuilder: (BuildContext context, int index) {
                            return _buildFormField("${index + 1}",
                                listOfNameControllerSteps[index]);
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        height: 40,
                        width: 100,
                        child: FloatingActionButton(
                          onPressed: () async {
                            Recipe recipe = Recipe(
                              name: _recipeController!.text,
                              yieldValue: _yieldController1!.text,
                              time: int.parse(_timeController2!.text),
                              timeUnit: selectedTime!,
                            );

                            int recipeId = await recipe.insertRecipe();
                            log("test recipe id: $recipeId");

                            List<int> ingredientIds = [];
                            for (int i = 0;
                                i < listOfNameControllerIngredients.length;
                                i++) {
                              Ingredient ingredient = Ingredient(
                                  recipeId: recipeId,
                                  ingredientName:
                                      listOfNameControllerIngredients[i].text,
                                  amount: double.parse(
                                      listOfNameControllerUnits[i].text),
                                  unit: selectedUnit[i]!,
                                  sequence: i + 1);
                              ingredientIds
                                  .add(await ingredient.insertIngredient());
                            }

                            List<int> stepIds = [];
                            for (int i = 0;
                                i < listOfNameControllerSteps.length;
                                i++) {
                              recipeStep step = recipeStep(
                                recipeId: recipeId,
                                sequence: i + 1,
                                description: listOfNameControllerSteps[i].text,
                              );
                              stepIds.add(await step.insertStep());
                            }

                            setState(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FinishedRecipe(
                                            recipeId: recipeId,
                                          )));
                            });
                          },
                          child: Text("Save"),
                        ),
                      ),
                    ],
                  ))),
            );
          }
        },
        future: recipeData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("DESSERT"),
      ),
      body: editRecipeWidget(),
    );
  }

  Widget _buildFormField(String labelText, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }
}
