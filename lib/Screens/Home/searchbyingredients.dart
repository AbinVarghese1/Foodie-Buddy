import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodiebuddyapp/Screens/Home/popular_widget.dart';
import 'package:foodiebuddyapp/theme.dart';

class SearchWithIngredientsPage extends StatefulWidget {
  @override
  _SearchWithIngredientsPageState createState() => _SearchWithIngredientsPageState();
}

class _SearchWithIngredientsPageState extends State<SearchWithIngredientsPage> {
  TextEditingController _ingredientsController = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Search with Ingredients', style: AppTheme.textTheme.displayMedium),
          backgroundColor: const Color(0xFFC9EFC6),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _ingredientsController,
                style: AppTheme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Enter ingredients (comma-separated)',
                  hintStyle: AppTheme.textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  String ingredients = _ingredientsController.text;
                  _searchRecipes(ingredients);
                },
                child: Text('Search',style: AppTheme.textTheme.bodyLarge?.copyWith(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C985A),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return PopularWidget(
                      recipe: RecipePopular.fromMap(_searchResults[index]),
                      firestore: _firestore,
                      storage: FirebaseStorage.instance,
                      auth: FirebaseAuth.instance,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _searchRecipes(String ingredients) async {
    List<String> ingredientList = ingredients.toLowerCase().split(',').map((e) => e.trim()).toList();

    QuerySnapshot querySnapshot = await _firestore.collection('recipe').get();

    List<Map<String, dynamic>> results = [];

    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String recipeIngredients = data['Ingredients'] as String;
      
      List<String> recipeIngredientList = recipeIngredients
          .split('\n')
          .map((line) => line.split('|')[0].trim().toLowerCase())
          .toList();
      
      bool containsIngredients = ingredientList.every((ingredient) => 
          recipeIngredientList.any((recipeIngredient) => 
              recipeIngredient.contains(ingredient)));

      if (containsIngredients) {
        results.add({
          'RecipeID': data['RecipeID'],
          'Title': data['Title'],
          'Image_Name': data['Image_Name'],
          'Cuisine': data['Cuisine'],
          'CookTime': data['CookTime'],
        });
      }
    });

    setState(() {
      _searchResults = results;
    });
  }
}