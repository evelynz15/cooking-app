import 'package:cookingapp/ui/views/onboard_screen.dart';
import 'package:cookingapp/ui/views/recipe_stepper/recipe_stepper_view.dart';
import 'package:cookingapp/ui/views/setting_view.dart';
import 'package:flutter/material.dart';
import 'package:cookingapp/ui/views/home_view.dart';
import 'package:cookingapp/ui/views/catagory_view.dart';
import 'package:cookingapp/ui/views/finished_recipe_view.dart';
import 'package:cookingapp/ui/views/edit_recipe_view.dart';

const String initialRoute = "recordInit";

class CookingRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case 'home':
        return MaterialPageRoute(builder: (_) => const MyHomePage(title: "What's Cooking?"));
      case 'catagory':
        final Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => CatagoryPage(catagoryId: arguments['catagoryId']));
      case 'finalRecipe':
        final Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => FinishedRecipe(recipeId: arguments['recipeId'], catagoryId: arguments['catagoryId']));
      case 'addRecipe':
        final Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
        //return MaterialPageRoute(builder: (_) => NewRecipePage(catagoryId: arguments['catagoryId']));
        return MaterialPageRoute(builder: (_) => FormPage(catagoryId: arguments['catagoryId']));
      case 'editRecipe':
        final Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => EditRecipePage(recipeId: arguments["recipeId"], catagoryId: arguments['catagoryId'],));
      case 'onBoard':
        return MaterialPageRoute(builder: (_) => const OnboardScreen());
      case 'settings':
        return MaterialPageRoute(builder: (_) => const SettingView());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                child: Text('No route defined for ${settings.name}'),
              ),
            ));
    }
  }
}