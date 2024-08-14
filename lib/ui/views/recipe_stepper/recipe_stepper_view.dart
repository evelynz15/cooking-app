import 'package:cookingapp/ui/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:cookingapp/ui/views/recipe_stepper/custom_input.dart';
import 'package:cookingapp/ui/views/recipe_stepper/custom_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'dart:developer';
import 'package:cookingapp/models/recipe.dart';
import 'package:cookingapp/models/ingredient.dart';
import 'package:cookingapp/models/step.dart';
import 'package:image_cropper/image_cropper.dart';

enum ImageSourceType { gallery, camera }

class FormPage extends StatefulWidget {
  final int? catagoryId;
  const FormPage({super.key, required this.catagoryId});

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  File? _image;
  var imagePicker;
  var type;
  String? _imageName;
  ImageSourceType? selectedImageSource;

  final TextEditingController _recipeController = TextEditingController();

  final TextEditingController _yieldController = TextEditingController();

  final TextEditingController _timeController = TextEditingController();

  final TextEditingController _notesController = TextEditingController();

  final List _ingredients = [1];
  final List _steps = [1];

  int i = 1;
  int q = 1;

  final List<TextEditingController> listOfIngredientControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> listOfStepControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> listOfUnitControllers = [
    TextEditingController(),
  ];

  final List<String> units = ["Tsp", "Tbsp", "Cup", "n/a"];
  Map<int, String> selectedUnit = {};

  final List<String> timeUnits = ["Hour(s)", "Minutes"];
  String? selectedTime;

  int currentStep = 0;

  void addNewIngredient() {
    setState(() {
      i++;
      _ingredients.add(i);
      listOfIngredientControllers.add(TextEditingController());
      listOfUnitControllers.add(TextEditingController());
    });
  }

  void addNewStep() {
    setState(() {
      q++;
      _steps.add(q);
      listOfStepControllers.add(TextEditingController());
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add New Recipe",
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
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
                  onStepContinue: () {
                    bool isLastStep = (currentStep == getSteps().length - 1);
                    if (isLastStep) {
                      //Do something with this information
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
                CustomBtn(
                  title: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                  callback: () async {
                    //if (_formKey.currentState!.validate()) {
                    Recipe recipe = Recipe(
                      name: _recipeController.text,
                      yieldValue: _yieldController.text,
                      time: int.parse(_timeController.text),
                      timeUnit: selectedTime!,
                      imageName: _imageName != null
                          ? path.extension(_imageName!)
                          : null,
                      notes: _notesController.text.isNotEmpty
                          ? _notesController.text
                          : null,
                      catagoryId: widget.catagoryId!,
                    );

                    int recipeId = await recipe.insertRecipe();
                    log("test recipe id: $recipeId");

                    List<int> ingredientIds = [];
                    for (int i = 0;
                        i < listOfIngredientControllers.length;
                        i++) {
                      Ingredient ingredient = Ingredient(
                          recipeId: recipeId,
                          ingredientName: listOfIngredientControllers[i].text,
                          amount: double.parse(listOfUnitControllers[i].text),
                          unit: selectedUnit[i]!,
                          sequence: i + 1);
                      ingredientIds.add(await ingredient.insertIngredient());
                    }

                    List<int> stepIds = [];
                    for (int i = 0; i < listOfStepControllers.length; i++) {
                      recipeStep step = recipeStep(
                        recipeId: recipeId,
                        sequence: i + 1,
                        description: listOfStepControllers[i].text,
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

                      String newImgName =
                          recipeId.toString() + path.extension(_imageName!);

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
                      Navigator.pushNamed(context, 'finalRecipe', arguments: {
                        'recipeId': recipeId,
                        "catagoryId": widget.catagoryId
                      });
                    });
                    //}
                  },
                )
              ],
            )),
      ),
    );
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

  List<Step> getSteps() {
    return <Step>[
      Step(
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 0,
        title: const Text("About"),
        content: Form(
          key: _formKeys[0],
          child: Column(
            children: [
              CustomInput(
                hint: "Title of Recipe",
                inputBorder: UnderlineInputBorder(),
                controller: _recipeController,
              ),
              CustomInput(
                hint: "Yield",
                inputBorder: UnderlineInputBorder(),
                controller: _yieldController,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: CustomInput(
                      hint: "Time",
                      inputBorder: UnderlineInputBorder(),
                      controller: _timeController,
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
                    items:
                        timeUnits.map<DropdownMenuItem<String>>((String value) {
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
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 1,
        title: const Text("Image"),
        content: Column(
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
                          color: Theme.of(context).colorScheme.inversePrimary),
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
        state: currentStep > 2 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 2,
        title: Text("Ingredients"),
        content: Form(
          key: _formKeys[2],
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: _ingredients.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150,
                          child: CustomInput(
                            hint: "${index + 1}",
                            inputBorder: UnderlineInputBorder(),
                            controller: listOfIngredientControllers[index],
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 50,
                              child: CustomInput(
                                hint: "Amount",
                                inputBorder: UnderlineInputBorder(),
                                controller: listOfUnitControllers[index],
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
        state: currentStep > 3 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 3,
        title: const Text("Procedure"),
        content: Form(
          key: _formKeys[3],
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: _steps.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CustomInput(
                      hint: "${index + 1}",
                      inputBorder: UnderlineInputBorder(),
                      controller: listOfStepControllers[index],
                    );
                  },
                ),
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
        state: currentStep > 4 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 4,
        title: const Text("Additional Notes"),
        content: Column(
          children: [
            CustomInput(
              hint: "Notes",
              inputBorder: OutlineInputBorder(),
              controller: _notesController,
            ),
          ],
        ),
      ),
    ];
  }
}
