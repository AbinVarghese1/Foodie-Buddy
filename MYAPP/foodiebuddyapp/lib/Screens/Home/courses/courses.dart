import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:foodiebuddyapp/Screens/Home/popular_widget.dart';
import 'package:foodiebuddyapp/theme.dart';

class CoursesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
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
                titlePadding: EdgeInsetsDirectional.only(start: 64, bottom: 12),
                title: Text('Courses', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
                centerTitle: false,
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildCourseItem(context, 'Appetizers', 'Appetizer.png', () => Navigator.push(context, MaterialPageRoute(builder: (context) => AppetizersPage()))),
                    _buildCourseItem(context, 'Soups', 'Soup.png', () => Navigator.push(context, MaterialPageRoute(builder: (context) => SoupsPage()))),
                    _buildCourseItem(context, 'Breakfast And Brunch', 'MainDish.png', () => Navigator.push(context, MaterialPageRoute(builder: (context) => BreakfastPage()))),
                    _buildCourseItem(context, 'Lunch', 'Lunch.jpg', () => Navigator.push(context, MaterialPageRoute(builder: (context) => LunchPage()))),
                    _buildCourseItem(context, 'Desserts', 'Dessert.jpg', () => Navigator.push(context, MaterialPageRoute(builder: (context) => DessertsPage()))),
                    _buildCourseItem(context, 'Salads', 'Salad.jpg', () => Navigator.push(context, MaterialPageRoute(builder: (context) => SaladsPage()))),
                    _buildCourseItem(context, 'Side Dishes', 'SideDish.png', () => Navigator.push(context, MaterialPageRoute(builder: (context) => SideDishesPage()))),
                    _buildCourseItem(context, 'Beverages', 'Beverages.jpg', () => Navigator.push(context, MaterialPageRoute(builder: (context) => BeveragesPage()))),
                    _buildCourseItem(context, 'Snacks', 'Snacks.png', () => Navigator.push(context, MaterialPageRoute(builder: (context) => SnacksPage()))),
                    _buildCourseItem(context, 'Sauces', 'Sauce.jpg', () => Navigator.push(context, MaterialPageRoute(builder: (context) => SaucesPage()))),
                    _buildCourseItem(context, 'Breads', 'Bread.jpg', () => Navigator.push(context, MaterialPageRoute(builder: (context) => BreadsPage()))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseItem(BuildContext context, String title, String imageName, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: ListTile(
          title: Text(title, style: AppTheme.textTheme.bodyLarge),
          trailing: CircleAvatar(
            backgroundImage: AssetImage('assets/coursesimage/$imageName'),
            radius: 30,
          ),
        ),
      ),
    );
  }
}

class AppetizersPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Appetizers', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: _buildRecipeList(context, 'Appetizers'),
      ),
    );
  }

  Widget _buildRecipeList(BuildContext context, String courseType) {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore.collection("recipe").where("Courses", isEqualTo: courseType).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error fetching data", style: AppTheme.textTheme.bodyLarge));
        }
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          List<RecipePopular> recipes = snapshot.data!.docs
              .map((doc) => RecipePopular.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              return PopularWidget(
                recipe: recipes[index],
                firestore: _firestore,
                storage: FirebaseStorage.instance,
                auth: FirebaseAuth.instance,
              );
            },
          );
        } else {
          return Center(child: Text("No $courseType available", style: AppTheme.textTheme.bodyLarge));
        }
      },
    );
  }
}

// Repeat the same pattern for other course pages (Soups, Breakfast, Lunch, etc.)
class SoupsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Soups', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: AppetizersPage()._buildRecipeList(context, 'Soups'),
      ),
    );
  }
}

class BreakfastPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Breakfast', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: AppetizersPage()._buildRecipeList(context, 'Breakfast'),
      ),
    );
  }
}

class LunchPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Lunch', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: AppetizersPage()._buildRecipeList(context, 'Lunch'),
      ),
    );
  }
}

class DessertsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Desserts', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: AppetizersPage()._buildRecipeList(context, 'Desserts'),
      ),
    );
  }
}

class SaladsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Salads', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: AppetizersPage()._buildRecipeList(context, 'Salads'),
      ),
    );
  }
}

class SideDishesPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Side Dishes', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: AppetizersPage()._buildRecipeList(context, 'Side Dishes'),
      ),
    );
  }
}

class BeveragesPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Beverages', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: AppetizersPage()._buildRecipeList(context, 'Beverages'),
      ),
    );
  }
}

class SnacksPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Snacks', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: AppetizersPage()._buildRecipeList(context, 'Snacks'),
      ),
    );
  }
}

class SaucesPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Sauces', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: AppetizersPage()._buildRecipeList(context, 'Sauces'),
      ),
    );
  }
}

class BreadsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Breads', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: AppetizersPage()._buildRecipeList(context, 'Breads'),
      ),
    );
  }
}