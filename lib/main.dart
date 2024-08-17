import 'package:cookingapp/ui/router.dart';
import 'package:cookingapp/ui/views/add_recipe_view.dart';
import 'package:cookingapp/ui/views/edit_recipe_view.dart';
import 'package:cookingapp/ui/views/finished_recipe_view.dart';
import 'package:flutter/material.dart';
import 'package:cookingapp/ui/views/home_view.dart';
import 'package:cookingapp/ui/views/catagory_view.dart';
import 'package:cookingapp/services/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  String onLaunchNavigation = "onBoard";

  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isOnboardingComplete = prefs.getBool('isOnboardingComplete') ?? false;

  DbHelper db = DbHelper();
  await db.database;

  if (isOnboardingComplete == false){
      final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isOnboardingComplete', true);
      onLaunchNavigation = "onBoard";
    } else {
      onLaunchNavigation = "home";
    }

  runApp(MyApp(defaultRoute: onLaunchNavigation,));
}

class MyApp extends StatelessWidget {

  final String defaultRoute;

  MyApp({super.key, required this.defaultRoute});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: "What's Cooking?",
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromRGBO(103, 58, 183, 1)),
        useMaterial3: true,
      ),
      initialRoute: defaultRoute,
      onGenerateRoute: CookingRouter.generateRoute,
    );
  }
}

