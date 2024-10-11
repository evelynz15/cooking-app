import 'dart:io';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookingapp/models/recipe.dart';
import 'package:cookingapp/models/ingredient.dart';
import 'package:cookingapp/models/step.dart';
import 'dart:developer';
import 'package:path/path.dart' as path;

enum ImageSourceType { gallery, camera }

class EditRecipePage extends StatefulWidget {
  final int recipeId;
  final int catagoryId;

  const EditRecipePage(
      {super.key, required this.recipeId, required this.catagoryId});

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

  File? _image;
  var imagePicker;
  var type;
  String? _imageName;

  List<TextEditingController> listOfNameControllerIngredients = [];
  List<TextEditingController> listOfNameControllerSteps = [];
  List<TextEditingController> listOfNameControllerUnits = [];

  final List<String> units = ["Tsp", "Tbsp", "Cup", "n/a"];
  Map<int, String> selectedUnit = {};

  final List<String> timeUnits = ["Hour(s)", "Minutes"];
  String? selectedTime;

  List<Ingredient>? selectedIngredientList;
  List<recipeStep>? selectedStepList;

  late Future<Recipe>? recipeData;

  bool isImageChanged = false;

  @override
  void initState() {
    super.initState();
    recipeData = getRecipe();
  }

  void addNewIngredient() {
    setState(() {
      listOfNameControllerIngredients.add(TextEditingController());
      listOfNameControllerUnits.add(TextEditingController());
      selectedIngredientList!.add(Ingredient());
    });
  }

  void addNewStep() {
    setState(() {
      listOfNameControllerSteps.add(TextEditingController());
      selectedStepList!.add(recipeStep());
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
              selectedStepList = recipeSnap.data!.stepList;
              File recipeImg = File(path.join(documentDirectory!.path, 'image',
                      recipeSnap.data!.id.toString()) +
                  recipeSnap.data!.imageName.toString());
              recipeSnap.data!.imageName != null ? _image = recipeImg : _image;
              _imageName = recipeSnap.data!.imageName;
            }

            return SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                  child: Center(
                      child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildFormField("Title of Recipe", _recipeController!),
                        const SizedBox(height: 50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  height: 160,
                                  width: 160,
                                  child: _image != null
                                      ? Image.file(
                                          _image!,
                                          key: UniqueKey(),
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
                                      var source =
                                          item == ImageSourceType.camera
                                              ? ImageSource.camera
                                              : ImageSource.gallery;
                                      XFile image = await imagePicker.pickImage(
                                          source: source,
                                          imageQuality: 50,
                                          preferredCameraDevice:
                                              CameraDevice.front);
                                      setState(() {
                                        selectedImageSource = item;
                                        _imageName = path.basename(image.path);
                                        _image = File(image.path);
                                        isImageChanged = true;
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
                            SizedBox(
                              width: 150,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                        hint: const Text('Unit'),
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
                                  const SizedBox(height: 30),
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
                                                title: const Text('Notes'),
                                                content: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Form(
                                                    child: Column(
                                                      children: <Widget>[
                                                        SizedBox(
                                                          height: 200,
                                                          child: TextFormField(
                                                            maxLines:
                                                                null, // Set this
                                                            expands:
                                                                true, // and this
                                                            keyboardType:
                                                                TextInputType
                                                                    .multiline,
                                                            decoration:
                                                                const InputDecoration(
                                                              hintText:
                                                                  'Enter your notes',
                                                              border:
                                                                  OutlineInputBorder(),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                      child: const Text("Done"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      })
                                                ],
                                              );
                                            });
                                      },
                                      child: const Text("Add Notes"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        Container(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                const Text("Ingredients List:"),
                                const SizedBox(width: 25),
                                SizedBox(
                                  width: 70,
                                  height: 30,
                                  child: FloatingActionButton(
                                    onPressed: addNewIngredient,
                                    child: const Icon(Icons.add),
                                  ),
                                ),
                              ],
                            )),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: listOfNameControllerIngredients.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          value: selectedIngredientList![index]
                                              .unit,
                                          hint: const Text('Unit'),
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
                        const SizedBox(height: 50),
                        Container(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                const Text("Procedure:"),
                                const SizedBox(width: 25),
                                SizedBox(
                                  width: 70,
                                  height: 30,
                                  child: FloatingActionButton(
                                    onPressed: addNewStep,
                                    child: const Icon(Icons.add),
                                  ),
                                ),
                              ],
                            )),
                        SizedBox(
                          //width: 200,
                          height: 100,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: listOfNameControllerSteps.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _buildFormField("${index + 1}",
                                  listOfNameControllerSteps[index]);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 40,
                          width: 100,
                          child: FloatingActionButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                List<Ingredient> ingredientItems = [];
                                for (int i = 0;
                                    i < listOfNameControllerIngredients.length;
                                    i++) {
                                  Ingredient ingredient = Ingredient(
                                      id: selectedIngredientList![i].id != null
                                          ? recipeSnap
                                              .data!.ingredientList![i].id
                                          : null,
                                      recipeId: widget.recipeId,
                                      ingredientName:
                                          listOfNameControllerIngredients[i]
                                              .text,
                                      amount: double.parse(
                                          listOfNameControllerUnits[i].text),
                                      unit: selectedIngredientList![i].unit,
                                      sequence: i + 1);
                                  ingredientItems.add(ingredient);
                                }

                                List<recipeStep> stepItems = [];
                                for (int i = 0;
                                    i < listOfNameControllerSteps.length;
                                    i++) {
                                  recipeStep step = recipeStep(
                                    id: selectedStepList![i].id != null
                                        ? recipeSnap.data!.stepList![i].id
                                        : null,
                                    recipeId: widget.recipeId,
                                    sequence: i + 1,
                                    description:
                                        listOfNameControllerSteps[i].text,
                                  );
                                  stepItems.add(step);
                                }

                                Recipe recipe = Recipe(
                                  id: widget.recipeId,
                                  name: _recipeController!.text,
                                  yieldValue: _yieldController1!.text,
                                  time: double.parse(_timeController2!.text),
                                  timeUnit: selectedTime!,
                                  catagoryId: recipeSnap.data!.catagoryId,
                                  imageName: _imageName != null
                                      ? path.extension(_imageName!)
                                      : null,
                                  ingredientList: ingredientItems,
                                  stepList: stepItems,
                                );
                                await recipe.updateRecipeInfo(recipe);

                                int recipeId = widget.recipeId;
                                log("recipe $recipeId updated");

                                if (_image != null) {
                                  Directory documentDirectory =
                                      await getApplicationDocumentsDirectory();
                                  String imgPath = path.join(
                                      documentDirectory.path, 'image');
                                  if (!await Directory(imgPath).exists()) {
                                    Directory imgDir = Directory(imgPath);
                                    await imgDir.create(recursive: true);
                                  }

                                  String newImgName = recipeId.toString() +
                                      path.extension(_imageName!);

                                  imgPath = path.join(imgPath, newImgName);
                                  File imgFile = File(imgPath);
                                  try {
                                    if (await imgFile.exists() &&
                                        isImageChanged == true) {
                                      // If the file exists, delete it before writing the new data
                                      await imgFile.delete();
                                      Image img = Image.file(imgFile);
                                      await img.image.evict();
                                    }
                                    await _image!.copy(imgPath);
                                    //await imgFile.writeAsBytes(bytes, flush: true);
                                    log('Image saved to: $imgPath');
                                  } catch (e) {
                                    log('Error saving image: $e');
                                  }
                                } else {}

                                setState(() {
                                  Navigator.pushNamed(
                                      context, 'catagory', arguments: {
                                    "catagoryId": recipeSnap.data!.catagoryId
                                  });
                                });
                              }
                            },
                            child: const Text("Save"),
                          ),
                        ),
                      ],
                    ),
                  ))),
            );
          }
        },
        future: recipeData);
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
