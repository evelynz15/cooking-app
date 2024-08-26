import 'dart:io';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:cookingapp/ui/views/home_view.dart';
import 'package:cookingapp/ui/views/catagory_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:cookingapp/models/recipe.dart';
import 'package:cookingapp/models/ingredient.dart';
import 'package:cookingapp/models/step.dart';
import 'dart:developer';
import 'package:cookingapp/ui/router.dart';

enum ImageSourceType { gallery, camera }

class NewRecipePage extends StatefulWidget {
  final int? catagoryId;
  const NewRecipePage({super.key, required this.catagoryId});

  @override
  State<NewRecipePage> createState() => _NewRecipePageState();
}

class _NewRecipePageState extends State<NewRecipePage> {
  ImageSourceType? selectedImageSource;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _recipeController = TextEditingController();

  final TextEditingController _yieldController1 = TextEditingController();

  final TextEditingController _timeController2 = TextEditingController();

  final TextEditingController _notesController = TextEditingController();

  final List _ingredients = [1];
  final List _steps = [1];

  File? _image;
  var imagePicker;
  var type;
  String? _imageName;

  int i = 1;
  int q = 1;

  final List<TextEditingController> listOfNameControllerIngredients = [
    TextEditingController(),
  ];
  final List<TextEditingController> listOfNameControllerSteps = [
    TextEditingController(),
  ];
  final List<TextEditingController> listOfNameControllerUnits = [
    TextEditingController(),
  ];

  final List<String> units = ["Tsp", "Tbsp", "Cup", "n/a"];
  Map<int, String> selectedUnit = {};

  final List<String> timeUnits = ["Hour(s)", "Minutes"];
  String? selectedTime;

  void addNewIngredient() {
    setState(() {
      i++;
      _ingredients.add(i);
      listOfNameControllerIngredients.add(TextEditingController());
      listOfNameControllerUnits.add(TextEditingController());
    });
  }

  void addNewStep() {
    setState(() {
      q++;
      _steps.add(q);
      listOfNameControllerSteps.add(TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("DESSERT"),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
            child: Center(
                child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildFormField("Title of Recipe", _recipeController),
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
                                    _image!,
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.fitHeight,
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary),
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
                                    preferredCameraDevice: CameraDevice.front);
                                setState(() {
                                  selectedImageSource = item;
                                  _imageName = path.basename(image.path);
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
                            _buildFormField("Yield", _yieldController1),
                            Row(
                              children: [
                                SizedBox(
                                    width: 50,
                                    child: _buildFormField(
                                        "Time", _timeController2)),
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
                                          content: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Form(
                                              child: Column(
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: 200,
                                                    child: TextFormField(
                                                      controller: _notesController,
                                                      maxLines: null, // Set this
                                                      expands: true, // and this
                                                      keyboardType:
                                                          TextInputType.multiline,
                                                      decoration: InputDecoration(
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
                                                child: Text("Done"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                })
                                          ],
                                        );
                                      });
                                  /*await showDialog<void>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            content: Stack(
                                              clipBehavior: Clip.none,
                                              children: <Widget>[
                                                Positioned(
                                                  right: -40,
                                                  top: -40,
                                                  child: InkResponse(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const CircleAvatar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      child: Icon(Icons.close),
                                                    ),
                                                  ),
                                                ),
                                                Form(
                                                  key: _formKey,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: TextFormField(),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: TextFormField(),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: ElevatedButton(
                                                          child: const Text(
                                                              'Submit'),
                                                          onPressed: () {
                                                            if (_formKey
                                                                .currentState!
                                                                .validate()) {
                                                              _formKey
                                                                  .currentState!
                                                                  .save();
                                                            }
                                                          },
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ));*/
                                },
                                child: Text("Add Notes"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
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
                                    value: selectedUnit[index],
                                    hint: Text('Unit'),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedUnit[index] = newValue ?? '';
                                      });
                                    },
                                    items: units.map<DropdownMenuItem<String>>(
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
                        return _buildFormField(
                            "${index + 1}", listOfNameControllerSteps[index]);
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 40,
                    width: 100,
                    child: FloatingActionButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          Recipe recipe = Recipe(
                            name: _recipeController.text,
                            yieldValue: _yieldController1.text,
                            time: double.parse(_timeController2.text),
                            timeUnit: selectedTime!,
                            imageName: _imageName != null
                                ? path.extension(_imageName!)
                                : null,
                            catagoryId: widget.catagoryId!,
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

                          //var response = await http.get(Uri.parse(_image));
                          if (_imageName != null) {
                            Directory documentDirectory =
                                await getApplicationDocumentsDirectory();
                            String imgPath =
                                path.join(documentDirectory.path, 'image');
                            if (!await Directory(imgPath).exists()) {
                              Directory imgDir = Directory(imgPath);
                              await imgDir.create(recursive: true);
                            }

                            String newImgName = recipeId.toString() +
                                path.extension(_imageName!);

                            imgPath = path.join(imgPath, newImgName);
                            File imgFile = File(imgPath);
                            try {
                              if (await imgFile.exists()) {
                                // If the file exists, delete it before writing the new data
                                await imgFile.delete();
                              }

                              await _image!.copy(imgPath);

                              //await imgFile.writeAsBytes(bytes, flush: true);
                              log('Image saved to: $imgPath');
                            } catch (e) {
                              log('Error saving image: $e');
                            }
                          } else {}

                          // await _image.writeAsBytes(response.bodyBytes);

                          setState(() {
                            Navigator.pushNamed(context, 'catagory',
                                arguments: {"catagoryId": widget.catagoryId});
                          });
                        }
                      },
                      child: Text("Done"),
                    ),
                  ),
                ],
              ),
            ))),
      ),
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
