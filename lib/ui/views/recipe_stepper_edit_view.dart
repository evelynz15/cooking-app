import 'package:cookingapp/ui/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:cookingapp/ui/views/recipe_stepper/custom_input.dart';
import 'package:cookingapp/ui/views/recipe_stepper/custom_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'dart:core';
import 'dart:developer';
import 'package:cookingapp/models/recipe.dart';
import 'package:cookingapp/models/ingredient.dart';
import 'package:cookingapp/models/step.dart';
import 'package:cookingapp/ui/router.dart';
import 'package:image_cropper/image_cropper.dart';

enum ImageSourceType { gallery, camera }

class EditFormPage extends StatefulWidget {
  final int? catagoryId;
  final int? recipeId;
  const EditFormPage(
      {super.key, required this.recipeId, required this.catagoryId});

  @override
  _EditFormPageState createState() => _EditFormPageState();
}

class _EditFormPageState extends State<EditFormPage> {
  List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  Directory? documentDirectory;
  File? _image;
  var imagePicker;
  var type;
  String? _imageName;
  ImageSourceType? selectedImageSource;

  TextEditingController? _recipeController;

  TextEditingController? _yieldController;

  TextEditingController? _timeController;

  TextEditingController? _notesController;

  List<TextEditingController> listOfIngredientControllers = [];
  List<TextEditingController> listOfStepControllers = [];
  List<TextEditingController> listOfUnitControllers = [];

  final List<String> units = ["Tsp", "Tbsp", "Cup", "n/a"];
  Map<int, String> selectedUnit = {};

  final List<String> timeUnits = ["Hour(s)", "Minutes"];
  String? selectedTime;

  List<Ingredient>? selectedIngredientList;
  List<recipeStep>? selectedStepList;

  late Future<Recipe>? recipeData;

  bool isImageChanged = false;

  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    recipeData = getRecipe();
  }

  void addNewIngredient() {
    setState(() {
      listOfIngredientControllers.add(TextEditingController());
      listOfUnitControllers.add(TextEditingController());
      selectedIngredientList!.add(Ingredient());
    });
  }

  void addNewStep() {
    setState(() {
      listOfStepControllers.add(TextEditingController());
      selectedStepList!.add(recipeStep());
    });
  }

  void deleteIngredient(int index) {
    setState((){
      listOfIngredientControllers.removeAt(index);
      listOfUnitControllers.removeAt(index);
      selectedUnit.remove(index);
      selectedIngredientList!.removeAt(index);
    });
  }

  void deleteStep(int index) {
    setState(() {
      listOfStepControllers.removeAt(index);
      selectedStepList!.removeAt(index);
    });
  }

  Future<Recipe> getRecipe() async {
    documentDirectory = await getApplicationDocumentsDirectory();
    return await Recipe.getRecipeById(widget.recipeId);
  }

  Future<File?> _cropImage({required File imageFile}) async {
    try {
      CroppedFile? croppedImg = await ImageCropper()
          .cropImage(sourcePath: imageFile.path, compressQuality: 100);
      if (croppedImg == null) {
        return null;
      } else {
        return File(croppedImg.path);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Widget editRecipeWidget() {
    return FutureBuilder(
        future: recipeData,
        builder: (context, recipeSnap) {
          if (recipeSnap.data == null ||
              recipeSnap.connectionState == ConnectionState.none &&
                  !recipeSnap.hasData) {
            //print('project snapshot data is: ${projectSnap.data}');
            return const Center(child: CircularProgressIndicator());
          } else {
            if (_recipeController == null) {
              _recipeController =
                  TextEditingController(text: recipeSnap.data!.name);
              _yieldController =
                  TextEditingController(text: recipeSnap.data!.yieldValue);
              _timeController =
                  TextEditingController(text: recipeSnap.data!.time.toString());
              _notesController =
                  TextEditingController(text: recipeSnap.data!.notes);
              for (Ingredient ingredientInfo
                  in recipeSnap.data!.ingredientList!) {
                listOfIngredientControllers.add(
                    TextEditingController(text: ingredientInfo.ingredientName));
                listOfUnitControllers.add(TextEditingController(
                    text: ingredientInfo.amount.toString()));
              }
              for (recipeStep step in recipeSnap.data!.stepList!) {
                listOfStepControllers
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

            List<Step> getSteps() {
              return <Step>[
                Step(
                  state:
                      currentStep > 0 ? StepState.complete : StepState.indexed,
                  isActive: currentStep >= 0,
                  title: const Text("About"),
                  content: Form(
                    key: _formKeys[0],
                    child: Column(
                      children: [
                        CustomInput(
                          hint: "Title of Recipe",
                          inputBorder: UnderlineInputBorder(),
                          controller: _recipeController!,
                          maxLength: 40,
                        ),
                        CustomInput(
                          hint: "Yield",
                          inputBorder: UnderlineInputBorder(),
                          controller: _yieldController!,
                          maxLength: 30,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 70,
                              child: CustomInput(
                                hint: "Time",
                                inputBorder: UnderlineInputBorder(),
                                controller: _timeController!,
                                maxLength: 4,
                                mustBeNumber: true,
                              ),
                            ),
                            DropdownButton<String>(
                              value: selectedTime,
                              hint: Text('Unit'),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedTime = newValue ?? '';
                                });
                              },
                              items: timeUnits.map<DropdownMenuItem<String>>(
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
                ),
                Step(
                  state:
                      currentStep > 1 ? StepState.complete : StepState.indexed,
                  isActive: currentStep >= 1,
                  title: const Text("Image"),
                  content: Column(
                    children: [
                      Container(
                        height: 160,
                        //width: 160,
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
                            File? tempImage;
                            imagePicker = ImagePicker();
                            var source = item == ImageSourceType.camera
                                ? ImageSource.camera
                                : ImageSource.gallery;
                            XFile image = await imagePicker.pickImage(
                                source: source,
                                imageQuality: 50,
                                preferredCameraDevice: CameraDevice.front);
                            tempImage = File(image.path);
                            tempImage = await _cropImage(imageFile: tempImage);
                            setState(() {
                              _image = tempImage;
                              selectedImageSource = item;
                              _imageName = path.basename(image.path);
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
                ),
                Step(
                  state:
                      currentStep > 2 ? StepState.complete : StepState.indexed,
                  isActive: currentStep >= 2,
                  title: Text("Ingredients"),
                  content: Form(
                    key: _formKeys[2],
                    child: Column(
                      children: [
                        SizedBox(
                          child: ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.all(16.0),
                              children: List.generate(
                                listOfIngredientControllers.length,
                                (index) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 150,
                                            child: CustomInput(
                                              hint: "${index + 1}",
                                              inputBorder:
                                                  UnderlineInputBorder(),
                                              controller:
                                                  listOfIngredientControllers[
                                                      index],
                                              maxLength: 40,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 50,
                                                child: CustomInput(
                                                  hint: "Amount",
                                                  inputBorder:
                                                      UnderlineInputBorder(),
                                                  controller:
                                                      listOfUnitControllers[
                                                          index],
                                                  maxLength: 4,
                                                  mustBeNumber: true,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 70,
                                                child: DropdownButton<String>(
                                                  value:
                                                      selectedIngredientList![
                                                              index]
                                                          .unit,
                                                  hint: Text('Unit'),
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      selectedIngredientList![
                                                                  index]
                                                              .unit =
                                                          newValue ?? '';
                                                    });
                                                  },
                                                  items: units.map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height: 30,
                                          width: 85,
                                          child: OutlinedButton(
                                            onPressed: () {
                                              deleteIngredient(index);
                                            },
                                            child: Text("Delete",
                                                style: TextStyle(fontSize: 11)),
                                          ))
                                    ],
                                  );
                                },
                              )),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: 70,
                          height: 30,
                          child: FloatingActionButton(
                            onPressed: addNewIngredient,
                            child: Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Step(
                  state:
                      currentStep > 3 ? StepState.complete : StepState.indexed,
                  isActive: currentStep >= 3,
                  title: const Text("Procedure"),
                  content: Form(
                    key: _formKeys[3],
                    child: Column(
                      children: [
                        SizedBox(
                          child: ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.all(16.0),
                              children: List.generate(
                                listOfStepControllers.length,
                                (int index) {
                                  return Column(
                                    children: [
                                      CustomInput(
                                        hint: "${index + 1}",
                                        inputBorder: UnderlineInputBorder(),
                                        controller: listOfStepControllers[index],
                                        maxLength: 300,
                                      ),
                                      SizedBox(
                                          height: 30,
                                          width: 85,
                                          child: OutlinedButton(
                                            onPressed: () {
                                              deleteStep(index);
                                            },
                                            child: Text("Delete",
                                                style: TextStyle(fontSize: 11)),
                                          ))
                                    ],
                                  );
                                },
                              )),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: 70,
                          height: 30,
                          child: FloatingActionButton(
                            onPressed: addNewStep,
                            child: Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Step(
                  state:
                      currentStep > 4 ? StepState.complete : StepState.indexed,
                  isActive: currentStep >= 4,
                  title: const Text("Additional Notes"),
                  content: Form(
                    key: _formKeys[4],
                    child: Column(
                      children: [
                        CustomInput(
                          hint: "Notes",
                          inputBorder: OutlineInputBorder(),
                          controller: _notesController,
                          maxLength: 400,
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            }

            return Column(children: [
              Stepper(
                type: StepperType.vertical,
                currentStep: currentStep,
                controlsBuilder:
                    (BuildContext context, ControlsDetails details) {
                  return Row(
                    children: <Widget>[
                      FilledButton(
                        onPressed: details.onStepContinue,
                        child: currentStep == 4 ? Text('Save') : Text('Next'),
                      ),
                      SizedBox(width: 50),
                      FilledButton.tonal(
                        onPressed: details.onStepCancel,
                        child: currentStep == 0 ? Text('Cancel') : Text('Back'),
                      ),
                    ],
                  );
                },
                onStepCancel: () => currentStep == 0
                    ? Navigator.pushNamed(context, 'catagory',
                        arguments: {"catagoryId": widget.catagoryId})
                    : setState(() {
                        currentStep -= 1;
                      }),
                onStepContinue: () async {
                  bool isLastStep = (currentStep == getSteps().length - 1);
                  if (isLastStep) {
                    await Ingredient.deleteIngredientsByRecipeId(widget.recipeId);
                    List<Ingredient> ingredientItems = [];
                    for (int i = 0;
                        i < listOfIngredientControllers.length;
                        i++) {
                      Ingredient ingredient = Ingredient(
                          /*id: selectedIngredientList![i].id != null
                              ? recipeSnap.data!.ingredientList![i].id
                              : null,*/
                          recipeId: widget.recipeId!,
                          ingredientName: listOfIngredientControllers[i].text,
                          amount: double.parse(listOfUnitControllers[i].text),
                          unit: selectedIngredientList![i].unit,
                          sequence: i + 1);
                      ingredientItems.add(ingredient);
                    }
                    
                    await recipeStep.deleteStepsByRecipeId(widget.recipeId);
                    List<recipeStep> stepItems = [];
                    for (int i = 0; i < listOfStepControllers.length; i++) {
                      recipeStep step = recipeStep(
                        /*id: selectedStepList![i].id != null
                            ? recipeSnap.data!.stepList![i].id
                            : null,*/
                        recipeId: widget.recipeId!,
                        sequence: i + 1,
                        description: listOfStepControllers[i].text,
                      );
                      stepItems.add(step);
                    }

                    Recipe recipe = Recipe(
                      id: widget.recipeId,
                      name: _recipeController!.text,
                      yieldValue: _yieldController!.text,
                      time: double.parse(_timeController!.text),
                      timeUnit: selectedTime!,
                      imageName: _imageName != null
                          ? path.extension(_imageName!)
                          : null,
                      notes: _notesController != null &&
                              _notesController!.text.isNotEmpty
                          ? _notesController!.text
                          : null,
                      catagoryId: widget.catagoryId!,
                      ingredientList: ingredientItems,
                      stepList: stepItems,
                    );
                    await recipe.updateRecipeInfo(recipe);

                    int recipeId = widget.recipeId!;
                    log("recipe $recipeId updated");

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

                      String newImgName =
                          recipeId.toString() + path.extension(_imageName!);

                      imgPath = path.join(imgPath, newImgName);
                      File imgFile = File(imgPath);
                      try {
                        if (await imgFile.exists() && isImageChanged == true) {
                          // If the file exists, delete it before writing the new data
                          await imgFile.delete();
                          Image img = Image.file(imgFile);
                          await img.image.evict();
                        }
                        await _image!.copy(imgPath);
                        log('Image saved to: $imgPath');
                      } catch (e) {
                        log('Error saving image: $e');
                      }
                    } else {}

                    setState(() {
                      Navigator.pushNamed(context, 'finalRecipe', arguments: {
                        'recipeId': recipeId,
                        "catagoryId": widget.catagoryId
                      });
                    });
                  } else {
                    setState(() {
                      if (currentStep != 1) {
                        if (_formKeys[currentStep].currentState!.validate()) {
                          currentStep++;
                        }
                      } else {
                        currentStep++;
                      }
                    });
                  }
                },
                /*onStepTapped: (step) => setState(() {
                  currentStep = step;
                }),*/
                steps: getSteps(),
              ),
              /*CustomBtn(
                title: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
                callback: () async {
                  //if (_formKey.currentState!.validate()) {
                  //}
                },
              )*/
            ]);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Edit Recipe",
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: editRecipeWidget(),
          ),
        ),
      ),
    );
  }
}
