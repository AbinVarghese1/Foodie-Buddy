import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:foodiebuddyapp/Screens/Home/popular_widget.dart';
import 'package:foodiebuddyapp/theme.dart';

class DishesPage extends StatelessWidget {
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
              backgroundColor: Color(0xFFC9EFC6),
              pinned: true,
              floating: true,
              expandedHeight: 100,
              leading: BackButton(),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsetsDirectional.only(start: 64, bottom: 12),
                title: Text('Dishes', style: AppTheme.textTheme.displayMedium?.copyWith(color: Colors.black)),
                centerTitle: false,
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildDishItem(context, 'Cake', 'assets/dishesimage/Cake.jpg', CakePage()),
                    _buildDishItem(context, 'Cookie', 'assets/dishesimage/Cookie.jpg', CookiePage()),
                    _buildDishItem(context, 'Pie', 'assets/dishesimage/Pie.jpg', PiePage()),
                    _buildDishItem(context, 'Sandwich', 'assets/dishesimage/Sandwich.jpg', SandwichPage()),
                    _buildDishItem(context, 'Cupcake', 'assets/dishesimage/Cupcake.jpg', CupcakePage()),
                    _buildDishItem(context, 'Pizza', 'assets/dishesimage/Pizza.jpg', PizzaPage()),
                    _buildDishItem(context, 'Burger', 'assets/dishesimage/Burger.jpg', BurgerPage()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishItem(BuildContext context, String title, String imagePath, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
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
            backgroundImage: AssetImage(imagePath),
            radius: 30,
          ),
        ),
      ),
    );
  }
}

class CakePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Cake', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: _buildRecipeList(context, 'Cake'),
      ),
    );
  }

  Widget _buildRecipeList(BuildContext context, String dishType) {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore.collection("recipe").where("Dishes", isEqualTo: dishType).get(),
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
          return Center(child: Text("No $dishType available", style: AppTheme.textTheme.bodyLarge));
        }
      },
    );
  }
}

// Repeat the same pattern for other dish pages (Cookie, Pie, Sandwich, etc.)
class CookiePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Cookie', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: CakePage()._buildRecipeList(context, 'Cookie'),
      ),
    );
  }
}

class PiePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Pie', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: CakePage()._buildRecipeList(context, 'Pie'),
      ),
    );
  }
}

class SandwichPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Sandwich', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: CakePage()._buildRecipeList(context, 'Sandwich'),
      ),
    );
  }
}

class CupcakePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Cupcake', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: CakePage()._buildRecipeList(context, 'Cupcake'),
      ),
    );
  }
}

class PizzaPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Pizza', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: CakePage()._buildRecipeList(context, 'Pizza'),
      ),
    );
  }
}

class BurgerPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          title: Text('Burger', style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black)),
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: CakePage()._buildRecipeList(context, 'Burger'),
      ),
    );
  }
}