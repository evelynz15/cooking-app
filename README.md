# What's Cooking?

This app allows you to input, store, and manage your favorite recipes using a user-friendly interface built with Flutter. The app stores the recipes locally using SQLite, making it easy to save and retrieve your delicious creations anytime.

# Features

- Add Recipes: Input recipe name, time, yield, ingredients, instructions, and any other notes.
- Store Recipes: All recipes are saved locally in an SQLite database, so you can access them offline.
- View Recipes: Browse and view all your saved recipes, conveniently separated by catagory.
- Delete Recipes: Easily remove any recipe from your collection.
- Search Recipes: Quickly search for recipes by name.
- Share Recipes: Effortlessly share recipes via email and input recipes of others into your collection. 

# App Structure

```
lib/
|- main.dart             # Entry point of the app
|- models/               # Data models (Recipe, etc.)
|- services/            # Service calls for accessing SQLite database
|- ui/                  # Screens (Home page, Add recipe view, etc.)```
