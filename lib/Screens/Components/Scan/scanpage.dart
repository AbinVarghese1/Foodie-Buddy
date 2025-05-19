import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodiebuddyapp/Screens/Components/Scan/model.dart';
import 'package:foodiebuddyapp/Screens/Home/recipe_detail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Recipe {
  final String recipeId;
  final String title;
  final String imageName;
  final String cookTime;

  Recipe({
    required this.recipeId,
    required this.title,
    required this.imageName,
    required this.cookTime,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      recipeId: map['RecipeID'] ?? '',
      title: map['Title'] ?? '',
      imageName: map['Image_Name'] ?? '',
      cookTime: map['CookTime'] ?? '',
    );
  }
}

extension StringExtension on String {
  String singularize() {
    if (this.endsWith('ies')) {
      return this.substring(0, this.length - 3) + 'y';
    } else if (this.endsWith('es')) {
      return this.substring(0, this.length - 2);
    } else if (this.endsWith('s') && !this.endsWith('ss')) {
      return this.substring(0, this.length - 1);
    }
    return this;
  }

  String pluralize() {
    if (this.endsWith('y')) {
      return this.substring(0, this.length - 1) + 'ies';
    } else if (this.endsWith('s') || this.endsWith('x') || this.endsWith('z') || this.endsWith('ch') || this.endsWith('sh')) {
      return this + 'es';
    }
    return this + 's';
  }
}

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _image;
  String? _label;
  List<Recipe> _similarRecipes = [];
  bool _isLoading = false;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      await MLService.loadModel();
    } catch (e) {
      print('Error loading model: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading ML model')),
      );
    }
  }

  Future<void> getAndAnalyzeImage() async {
    setState(() {
      _isLoading = true;
    });

    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      try {
        List<double> output = await MLService.runInference(_image!);
        String label = MLService.interpretOutput(output);

        setState(() {
          _label = label;
        });

        await findSimilarRecipes(label);
      } catch (e) {
        print('Error analyzing image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing image')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> findSimilarRecipes(String label) async {
    try {
      print('Searching for recipes similar to: $label');
      String lowercaseLabel = label.toLowerCase();
      
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('recipe')
          .get();
      
      print('Found ${querySnapshot.docs.length} total recipes');

      // Generate variations of the label
      List<String> labelVariations = [
        lowercaseLabel,
        lowercaseLabel.singularize(),
        lowercaseLabel.pluralize(),
      ].toSet().toList(); // Convert to Set and back to List to remove duplicates

      setState(() {
        _similarRecipes = querySnapshot.docs
            .map((doc) => Recipe.fromMap(doc.data() as Map<String, dynamic>))
            .where((recipe) {
              String lowercaseTitle = recipe.title.toLowerCase();
              // Check if any variation of the label is in the title
              return labelVariations.any((variation) => lowercaseTitle.contains(variation));
            })
            .toList();
        
        if (_similarRecipes.length > 10) {
          _similarRecipes = _similarRecipes.sublist(0, 10);
        }
      });

      print('Filtered to ${_similarRecipes.length} similar recipes');
    } catch (e) {
      print('Error finding similar recipes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error finding similar recipes')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Recipe'),
        backgroundColor: const Color(0xFFC9EFC6),
      ),
      backgroundColor: const Color(0xFFC9EFC6),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: getAndAnalyzeImage,
                child: Text('Select Image'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xFF5C985A),
                  backgroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              if (_image != null)
                Column(
                  children: [
                    Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _label ?? '',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              SizedBox(height: 20),
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else if (_similarRecipes.isNotEmpty)
                Column(
                  children: [
                    Text('Similar Recipes:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    ..._similarRecipes.map((recipe) => _buildRecipeWidget(recipe)).toList(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeWidget(Recipe recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailPage(recipeId: recipe.recipeId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            FutureBuilder<String>(
              future: _storage.ref("images/${recipe.imageName}.jpg").getDownloadURL(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 160,
                    width: 160,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const SizedBox(
                    height: 160,
                    width: 160,
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return Container(
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(snapshot.data!),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Cooking Time: ${recipe.cookTime}",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}