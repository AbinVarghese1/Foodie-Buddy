import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:foodiebuddyapp/theme.dart';

class PostRecipePage extends StatefulWidget {
  @override
  _PostRecipePageState createState() => _PostRecipePageState();
}

class _PostRecipePageState extends State<PostRecipePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCourse;
  String? _selectedCuisine;
  String? _selectedDish;
  XFile? _imageFile;

  final uuid = const Uuid();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _cookTimeController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _directionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
    });
  }

  Future<String?> _uploadImage() async {
    if (_imageFile != null) {
      final imageName = _imageFile!.name;
      final storageRef = FirebaseStorage.instance.ref().child('images/$imageName');

      final Uint8List? imageBytes = await _imageFile!.readAsBytes();
      if (imageBytes != null) {
        await storageRef.putData(imageBytes);
        return await storageRef.getDownloadURL();
      }
    }
    return null;
  }

  Future<void> _submitRecipe() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Recipe title is required")));
      return;
    }

    if (_cookTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cook time is required")));
      return;
    }

    if (_ingredientsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ingredients are required")));
      return;
    }

    if (_directionsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Instructions are required")));
      return;
    }

    if (_selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a course")));
      return;
    }

    if (_selectedCuisine == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a cuisine")));
      return;
    }

    final imageURL = await _uploadImage();

    if (imageURL == null && _imageFile != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image upload failed")));
      return;
    }

    final recipeID = uuid.v4();

    final recipeData = {
      'RecipeID': recipeID,
      'Title': _titleController.text,
      'CookTime': _cookTimeController.text,
      'Courses': _selectedCourse,
      'Cuisine': _selectedCuisine,
      'Dishes': _selectedDish ?? '',
      'Ingredients': _ingredientsController.text,
      'Instructions': _directionsController.text,
      if (_imageFile != null) 'Image_Name': _imageFile!.name.split('.').first,
      if (imageURL != null) 'Image_URL': imageURL,
    };

    await FirebaseFirestore.instance.collection('newrecipe').add(recipeData);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recipe Submitted')));

    setState(() {
      _titleController.clear();
      _cookTimeController.clear();
      _ingredientsController.clear();
      _directionsController.clear();
      _selectedCourse = null;
      _selectedCuisine = null;
      _selectedDish = null;
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xFFC9EFC6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: _submitRecipe,
              child: Text('Submit', style: AppTheme.textTheme.bodyMedium),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4AA469),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              elevation: 4.0,
              backgroundColor: const Color(0xFFC9EFC6),
              pinned: true,
              floating: true,
              expandedHeight: 100,
              leading: BackButton(),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Create Personal Recipe',
                  style: AppTheme.textTheme.displayMedium?.copyWith(color: Colors.black),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Ingredients'),
                  Tab(text: 'Directions'),
                ],
                labelStyle: AppTheme.textTheme.bodyLarge,
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: true,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildIngredientsTab(),
                  _buildDirectionsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 24),
                    _buildTextField(_titleController, 'Recipe Title'),
                    const SizedBox(height: 16),
                    _buildTextField(_cookTimeController, 'Cook Time'),
                    const SizedBox(height: 16),
                    _buildDropdown('Courses', _selectedCourse, (value) {
                      setState(() {
                        _selectedCourse = value;
                      });
                    }, ['Appetizer', 'Soups', 'Breakfast', 'Lunch', 'Desserts', 'Salads', 'SideDishes', 'Beverages', 'Snacks', 'Sauces', 'Breads']),
                    const SizedBox(height: 16),
                    _buildDropdown('Cuisine', _selectedCuisine, (value) {
                      setState(() {
                        _selectedCuisine = value;
                      });
                    }, ['American', 'Barbecue', 'Asian', 'Italian', 'Mexican', 'French', 'Indian', 'Chinese', 'Spanish', 'German']),
                    const SizedBox(height: 16),
                    _buildDropdown('Dishes', _selectedDish, (value) {
                      setState(() {
                        _selectedDish = value;
                      });
                    }, ['Cake', 'Cookie', 'Pie', 'Sandwich', 'Cupcake', 'Pizza', 'Burger', 'None']),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _buildTextField(_ingredientsController, 'Ingredients of the Recipe', maxLines: null, minLines: 8),
    );
  }

  Widget _buildDirectionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _buildTextField(_directionsController, 'Steps to Make the Recipe', maxLines: null, minLines: 8),
    );
  }

  Widget _buildImagePicker() {
    return Align(
      alignment: Alignment.center,
      child: Stack(
        children: [
          Container(
            width: 350,
            height: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: 2,
                style: BorderStyle.solid,
                color: Colors.white,
              ),
            ),
            child: Center(
              child: _imageFile != null
                  ? Image.file(
                      File(_imageFile!.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : IconButton(
                      icon: const Icon(Icons.upload),
                      onPressed: _pickImage,
                    ),
            ),
          ),
          if (_imageFile != null)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _removeImage,
                child: const Icon(
                  Icons.cancel_outlined,
                  color: Color.fromARGB(255, 0, 0, 0),
                  size: 30,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int? maxLines, int? minLines}) {
    return TextFormField(
      controller: controller,
      style: AppTheme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.textTheme.bodyMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: maxLines,
      minLines: minLines,
    );
  }

 Widget _buildDropdown(String label, String? value, Function(String?) onChanged, List<String> items) {
  return DropdownButtonFormField<String>(
    decoration: InputDecoration(
      labelText: label,
      labelStyle: AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.black), // Ensure label text is visible
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
    value: value,
    onChanged: onChanged,
    style: AppTheme.textTheme.bodyLarge?.copyWith(color: Colors.black), // Ensure dropdown text is visible
    dropdownColor: Colors.white, // Ensure dropdown menu background is visible
    items: items.map((item) => DropdownMenuItem(
      value: item,
      child: Text(item),
    )).toList(),
  );
}

}