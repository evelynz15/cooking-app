import 'package:flutter/material.dart';
import 'package:cookingapp/ui/views/home_view.dart';
import 'package:cookingapp/ui/views/catagory_view.dart';
import 'package:cookingapp/services/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DbHelper db = DbHelper();
  await db.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "What's Cooking?",
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromRGBO(103, 58, 183, 1)),
        useMaterial3: true,
      ),
      initialRoute: "home",
      routes: {
        "home": (context) => const MyHomePage(title: "What's Cooking?"),
        "catagory": (context) => const CatagoryPage(),
      }
    );
  }
}

