import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:foodiebuddyapp/Screens/Home/popular_widget.dart';
import 'package:foodiebuddyapp/theme.dart';

class CuisinePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              title: Text('Cuisines', style: AppTheme.textTheme.displayMedium?.copyWith(color: Colors.black)),
              centerTitle: false,
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildCuisineItem(context, 'American', 'assets/cuisinesimage/American.jpg', AmericanPage()),
                  _buildCuisineItem(context, 'Barbecue', 'assets/cuisinesimage/Barbecue.jpg', BarbecuePage()),
                  _buildCuisineItem(context, 'Asian', 'assets/cuisinesimage/Asian.jpg', AsianPage()),
                  _buildCuisineItem(context, 'Italian', 'assets/cuisinesimage/Italian.jpg', ItalianPage()),
                  _buildCuisineItem(context, 'Mexican', 'assets/cuisinesimage/Mexican.jpg', MexicanPage()),
                  _buildCuisineItem(context, 'French', 'assets/cuisinesimage/French.jpg', FrenchPage()),
                  _buildCuisineItem(context, 'Indian', 'assets/cuisinesimage/Indian.jpg', IndianPage()),
                  _buildCuisineItem(context, 'Chinese', 'assets/cuisinesimage/Chinese.jpg', ChinesePage()),
                  _buildCuisineItem(context, 'Spanish', 'assets/cuisinesimage/Spanish.jpg', SpanishPage()),
                  _buildCuisineItem(context, 'German', 'assets/cuisinesimage/German.jpg', GermanPage()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuisineItem(BuildContext context, String title, String imagePath, Widget page) {
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

class AmericanPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC9EFC6),
      appBar: AppBar(
        title: Text('American', style: AppTheme.textTheme.displayMedium?.copyWith(color: Colors.black)),
        backgroundColor: Color(0xFFC9EFC6),
        leading: BackButton(color: Colors.black),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _firestore
            .collection("recipe")
            .where("Cuisine", isEqualTo: "American")
            .get(),
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
            return Center(child: Text("No American recipes available", style: AppTheme.textTheme.bodyLarge));
          }
        },
      ),
    );
  }
}

class BarbecuePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC9EFC6),
      appBar: AppBar(
        title: Text('Barbecue', style: AppTheme.textTheme.displayMedium?.copyWith(color: Colors.black)),
        backgroundColor: Color(0xFFC9EFC6),
        leading: BackButton(color: Colors.black),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _firestore
            .collection("recipe")
            .where("Cuisine", isEqualTo: "Barbecue")
            .get(),
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
            return Center(child: Text("No Barbecue recipes available", style: AppTheme.textTheme.bodyLarge));
          }
        },
      ),
    );
  }
}

 
class AsianPage extends StatelessWidget {
 final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: const Color(0xFFC9EFC6), // Background color
      body:FutureBuilder<QuerySnapshot>(
  future: _firestore
      .collection("recipe") // Check if this is the correct collection name
      .where("Cuisine", isEqualTo: "Asian") // Correct spelling if needed
      .get(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
            return Center(child: Text("Error fetching data", style: AppTheme.textTheme.bodyLarge));
    }

    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
      // Correctly map documents to List<RecipePopular> with explicit type casting
      List<RecipePopular> recipes = snapshot.data!.docs
          .map((doc) => RecipePopular.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return CustomScrollView(
        slivers: [
          const SliverAppBar(
            elevation: 4.0,
            backgroundColor: Color(0xFFC9EFC6),
            pinned: true,
            floating: true,
            expandedHeight: 100,
            leading: BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Asian', style: TextStyle(fontSize: 20, color: Colors.black)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return PopularWidget(
                  recipe: recipes[index], // Correctly assigned as RecipePopular
                  firestore: _firestore,
                  storage: FirebaseStorage.instance,
                  auth: FirebaseAuth.instance,
                );
              },
              childCount: recipes.length,
            ),
          ),
        ],
      );
    } else {
      return Center(child: Text("No Asian recipes available", style: AppTheme.textTheme.bodyLarge));

    }
  },
),
      );
  }
}

class ItalianPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: const Color(0xFFC9EFC6), // Background color
      body:FutureBuilder<QuerySnapshot>(
  future: _firestore
      .collection("recipe") // Check if this is the correct collection name
      .where("Cuisine", isEqualTo: "Italian") // Correct spelling if needed
      .get(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
            return Center(child: Text("Error fetching data", style: AppTheme.textTheme.bodyLarge));
    }

    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
      // Correctly map documents to List<RecipePopular> with explicit type casting
      List<RecipePopular> recipes = snapshot.data!.docs
          .map((doc) => RecipePopular.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return CustomScrollView(
        slivers: [
          const SliverAppBar(
            elevation: 4.0,
            backgroundColor: Color(0xFFC9EFC6),
            pinned: true,
            floating: true,
            expandedHeight: 100,
            leading: BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Italian', style: TextStyle(fontSize: 20, color: Colors.black)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return PopularWidget(
                  recipe: recipes[index], // Correctly assigned as RecipePopular
                  firestore: _firestore,
                  storage: FirebaseStorage.instance,
                  auth: FirebaseAuth.instance,
                );
              },
              childCount: recipes.length,
            ),
          ),
        ],
      );
    } else {
      return Center(child: Text("No Italian recipes available", style: AppTheme.textTheme.bodyLarge));

    }
  },
),
      );
  }
}

class MexicanPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: const Color(0xFFC9EFC6), // Background color
      body:FutureBuilder<QuerySnapshot>(
  future: _firestore
      .collection("recipe") // Check if this is the correct collection name
      .where("Cuisine", isEqualTo: "Mexican") // Correct spelling if needed
      .get(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
            return Center(child: Text("Error fetching data", style: AppTheme.textTheme.bodyLarge));
    }

    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
      // Correctly map documents to List<RecipePopular> with explicit type casting
      List<RecipePopular> recipes = snapshot.data!.docs
          .map((doc) => RecipePopular.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return CustomScrollView(
        slivers: [
          const SliverAppBar(
            elevation: 4.0,
            backgroundColor: Color(0xFFC9EFC6),
            pinned: true,
            floating: true,
            expandedHeight: 100,
            leading: BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Mexican', style: TextStyle(fontSize: 20, color: Colors.black)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return PopularWidget(
                  recipe: recipes[index], // Correctly assigned as RecipePopular
                  firestore: _firestore,
                  storage: FirebaseStorage.instance,
                  auth: FirebaseAuth.instance,
                );
              },
              childCount: recipes.length,
            ),
          ),
        ],
      );
    } else {
      return Center(child: Text("No Mexican recipes available", style: AppTheme.textTheme.bodyLarge));

    }
  },
),
      );
  }
}

class FrenchPage extends StatelessWidget {
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: const Color(0xFFC9EFC6), // Background color
      body:FutureBuilder<QuerySnapshot>(
  future: _firestore
      .collection("recipe") // Check if this is the correct collection name
      .where("Cuisine", isEqualTo: "French") // Correct spelling if needed
      .get(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
            return Center(child: Text("Error fetching data", style: AppTheme.textTheme.bodyLarge));
    }

    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
      // Correctly map documents to List<RecipePopular> with explicit type casting
      List<RecipePopular> recipes = snapshot.data!.docs
          .map((doc) => RecipePopular.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return CustomScrollView(
        slivers: [
          const SliverAppBar(
            elevation: 4.0,
            backgroundColor: Color(0xFFC9EFC6),
            pinned: true,
            floating: true,
            expandedHeight: 100,
            leading: BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('French', style: TextStyle(fontSize: 20, color: Colors.black)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return PopularWidget(
                  recipe: recipes[index], // Correctly assigned as RecipePopular
                  firestore: _firestore,
                  storage: FirebaseStorage.instance,
                  auth: FirebaseAuth.instance,
                );
              },
              childCount: recipes.length,
            ),
          ),
        ],
      );
    } else {
            return Center(child: Text("No French recipes available", style: AppTheme.textTheme.bodyLarge));

    }
  },
),
      );
  }
}

class IndianPage extends StatelessWidget {
 final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: const Color(0xFFC9EFC6), // Background color
      body:FutureBuilder<QuerySnapshot>(
  future: _firestore
      .collection("recipe") // Check if this is the correct collection name
      .where("Cuisine", isEqualTo: "Indian") // Correct spelling if needed
      .get(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
            return Center(child: Text("Error fetching data", style: AppTheme.textTheme.bodyLarge));
    }

    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
      // Correctly map documents to List<RecipePopular> with explicit type casting
      List<RecipePopular> recipes = snapshot.data!.docs
          .map((doc) => RecipePopular.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return CustomScrollView(
        slivers: [
          const SliverAppBar(
            elevation: 4.0,
            backgroundColor: Color(0xFFC9EFC6),
            pinned: true,
            floating: true,
            expandedHeight: 100,
            leading: BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Indian', style: TextStyle(fontSize: 20, color: Colors.black)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return PopularWidget(
                  recipe: recipes[index], // Correctly assigned as RecipePopular
                  firestore: _firestore,
                  storage: FirebaseStorage.instance,
                  auth: FirebaseAuth.instance,
                );
              },
              childCount: recipes.length,
            ),
          ),
        ],
      );
    } else {
            return Center(child: Text("No Indian recipes available", style: AppTheme.textTheme.bodyLarge));

    }
  },
),
      );
  }
}

class ChinesePage extends StatelessWidget {
 final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: const Color(0xFFC9EFC6), // Background color
      body:FutureBuilder<QuerySnapshot>(
  future: _firestore
      .collection("recipe") // Check if this is the correct collection name
      .where("Cuisine", isEqualTo: "Chinese") // Correct spelling if needed
      .get(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
            return Center(child: Text("Error fetching data", style: AppTheme.textTheme.bodyLarge));
    }

    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
      // Correctly map documents to List<RecipePopular> with explicit type casting
      List<RecipePopular> recipes = snapshot.data!.docs
          .map((doc) => RecipePopular.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return CustomScrollView(
        slivers: [
          const SliverAppBar(
            elevation: 4.0,
            backgroundColor: Color(0xFFC9EFC6),
            pinned: true,
            floating: true,
            expandedHeight: 100,
            leading: BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Chinese', style: TextStyle(fontSize: 20, color: Colors.black)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return PopularWidget(
                  recipe: recipes[index], // Correctly assigned as RecipePopular
                  firestore: _firestore,
                  storage: FirebaseStorage.instance,
                  auth: FirebaseAuth.instance,
                );
              },
              childCount: recipes.length,
            ),
          ),
        ],
      );
    } else {
            return Center(child: Text("No Chinese recipes available", style: AppTheme.textTheme.bodyLarge));

    }
  },
),
      );
  }
}

class SpanishPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: const Color(0xFFC9EFC6), // Background color
      body:FutureBuilder<QuerySnapshot>(
  future: _firestore
      .collection("recipe") // Check if this is the correct collection name
      .where("Cuisine", isEqualTo: "Spanish") // Correct spelling if needed
      .get(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
            return Center(child: Text("Error fetching data", style: AppTheme.textTheme.bodyLarge));
    }

    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
      // Correctly map documents to List<RecipePopular> with explicit type casting
      List<RecipePopular> recipes = snapshot.data!.docs
          .map((doc) => RecipePopular.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return CustomScrollView(
        slivers: [
          const SliverAppBar(
            elevation: 4.0,
            backgroundColor: Color(0xFFC9EFC6),
            pinned: true,
            floating: true,
            expandedHeight: 100,
            leading: BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Spanish', style: TextStyle(fontSize: 20, color: Colors.black)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return PopularWidget(
                  recipe: recipes[index], // Correctly assigned as RecipePopular
                  firestore: _firestore,
                  storage: FirebaseStorage.instance,
                  auth: FirebaseAuth.instance,
                );
              },
              childCount: recipes.length,
            ),
          ),
        ],
      );
    } else {
            return Center(child: Text("No Spanish recipes available", style: AppTheme.textTheme.bodyLarge));

    }
  },
),
      );
  }
}

class GermanPage extends StatelessWidget {
 final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: const Color(0xFFC9EFC6), // Background color
      body:FutureBuilder<QuerySnapshot>(
  future: _firestore
      .collection("recipe") // Check if this is the correct collection name
      .where("Cuisine", isEqualTo: "German") // Correct spelling if needed
      .get(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
            return Center(child: Text("Error fetching data", style: AppTheme.textTheme.bodyLarge));
    }

    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
      // Correctly map documents to List<RecipePopular> with explicit type casting
      List<RecipePopular> recipes = snapshot.data!.docs
          .map((doc) => RecipePopular.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return CustomScrollView(
        slivers: [
          const SliverAppBar(
            elevation: 4.0,
            backgroundColor: Color(0xFFC9EFC6),
            pinned: true,
            floating: true,
            expandedHeight: 100,
            leading: BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('German', style: TextStyle(fontSize: 20, color: Colors.black)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return PopularWidget(
                  recipe: recipes[index], // Correctly assigned as RecipePopular
                  firestore: _firestore,
                  storage: FirebaseStorage.instance,
                  auth: FirebaseAuth.instance,
                );
              },
              childCount: recipes.length,
            ),
          ),
        ],
      );
    } else {
            return Center(child: Text("No German recipes available", style: AppTheme.textTheme.bodyLarge));

    }
  },
),
      );
  }
}

