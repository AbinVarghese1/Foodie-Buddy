import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:foodiebuddyapp/Screens/Home/courses/courses.dart';
import 'package:foodiebuddyapp/Screens/Home/cuisines/cuisines.dart';
import 'package:foodiebuddyapp/Screens/Home/diets/Dishes.dart';
import 'package:foodiebuddyapp/Screens/Home/popular_widget.dart';
import 'package:foodiebuddyapp/Screens/Home/postrecipe.dart';
import 'package:foodiebuddyapp/Screens/Home/recipe_detail.dart';
import 'package:foodiebuddyapp/Screens/Home/searchbyingredients.dart';
import 'package:foodiebuddyapp/theme.dart';

class Recipe {
  final String id;
  final String title;
  final String imageName;

  Recipe({
    required this.id,
    required this.title,
    required this.imageName,
  });

  factory Recipe.fromDocument(DocumentSnapshot doc) {
    return Recipe(
      id: doc['RecipeID'] as String,
      title: doc['Title'] as String,
      imageName: doc['Image_Name'] as String,
    );
  }
}

class homepage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<homepage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isOverlayVisible = false;
  List<Recipe> _recipes = [];
  List<RecipePopular> _popularRecipes = [];
  List<Recipe> _filteredRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
    _fetchPopularRecipes();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;

    if (query.isEmpty) {
      setState(() {
        _filteredRecipes = _getRandomRecipes(4);
      });
    } else {
      setState(() {
        _filteredRecipes = _recipes.where((recipe) =>
          recipe.title.toLowerCase().contains(query.toLowerCase())
        ).toList();
      });
    }
  }

  void _onFocusChanged() {
    if (!_searchFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_searchFocusNode.hasFocus) {
          setState(() {
            _isOverlayVisible = false;
          });
        }
      });
    }
  }

  Future<void> _fetchRecipes() async {
    final querySnapshot = await _firestore.collection('recipe').get();
    final recipes = querySnapshot.docs.map((doc) => Recipe.fromDocument(doc)).toList();

    setState(() {
      _recipes = recipes;
      _filteredRecipes = _getRandomRecipes(4);
    });
  }

  Future<void> _fetchPopularRecipes() async {
    final querySnapshot = await _firestore.collection('recipe').get();
    final popularRecipes = querySnapshot.docs.map((doc) => RecipePopular.fromDocument(doc)).toList();

    setState(() {
      _popularRecipes = popularRecipes;
      _isLoading = false;
    });
  }

  List<Recipe> _getRandomRecipes(int count) {
    final List<Recipe> randomRecipes = List.from(_recipes);
    randomRecipes.shuffle();
    return randomRecipes.take(count).toList();
  }

  void _onCarouselTap(int index) {
    if (index == 0) {
      setState(() {
        _isOverlayVisible = true;
      });
      _searchFocusNode.requestFocus();
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PostRecipePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        floating: true,
                        snap: true,
                        pinned: false,
                        expandedHeight: 10,
                        backgroundColor: Colors.transparent,
                        leading: null,
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(right: 16, top: 20),
                          ),
                        ],
                        title: Padding(
                          padding: const EdgeInsets.only(top: 20, left: 16, right: 8),
                          child: _buildSearchBar(),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: 170,
                                  viewportFraction: 1.0,
                                  enlargeCenterPage: false,
                                  autoPlay: true,  // Enable auto-play
                                  autoPlayInterval: Duration(seconds: 3),  // Set interval between slides
                                  autoPlayAnimationDuration: Duration(milliseconds: 600),  // Animation duration
                                  autoPlayCurve: Curves.fastOutSlowIn,  // Animation curve
                                  pauseAutoPlayOnTouch: false,  // Pause auto-play on touch
                                  aspectRatio: 2.0,
                                  onPageChanged: (index, reason) {}
                                ),
                                items: [
                                  GestureDetector(
                                    onTap: () => _onCarouselTap(0),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: const DecorationImage(
                                          fit: BoxFit.fill,
                                          image: AssetImage("assets/images/explore.png"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _onCarouselTap(1),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: const DecorationImage(
                                          fit: BoxFit.fill,
                                          image: AssetImage("assets/images/shareyourrecipe.jpg"),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Categories",
                                style: Theme.of(context).textTheme.displayMedium,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildCategoryButton("Courses", () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => CoursesPage()),
                                    );
                                  }),
                                  _buildCategoryButton("Cuisines", () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => CuisinePage()),
                                    );
                                  }),
                                  _buildCategoryButton("Dishes", () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => DishesPage()),
                                    );
                                  }),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Top Recipes",
                                style: Theme.of(context).textTheme.displayMedium,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 300,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _recipes.length,
                                  itemBuilder: (context, index) {
                                    return _buildRecipeWidget(_recipes[index]);
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Popular Recipes",
                                style: Theme.of(context).textTheme.displayMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final recipe = _popularRecipes[index];
                            return PopularWidget(
                              recipe: recipe,
                              firestore: _firestore,
                              storage: _storage,
                              auth: _auth,
                            );
                          },
                          childCount: _popularRecipes.length,
                        ),
                      ),
                    ],
                  ),
                  if (_isOverlayVisible)
                    Positioned(
                      top: 70,
                      left: 10,
                      right: 10,
                      child: Card(
                        color: Colors.white,
                        elevation: 4,
                        child: ListView.builder(
                          itemCount: _filteredRecipes.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return ListTile(
                                leading: Icon(Icons.search),
                                title: Text(
                                  "Search by Ingredients",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SearchWithIngredientsPage()),
                                  );
                                },
                              );
                            } else {
                              final recipe = _filteredRecipes[index - 1];
                              return ListTile(
                                leading: _buildRecipeImage(recipe.imageName),
                                title: Text(
                                  recipe.title,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => RecipeDetailPage(recipeId: recipe.id)),
                                  );
                                  _searchFocusNode.unfocus();
                                },
                              );
                            }
                          },
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: const InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
        onTap: () {
          setState(() {
            _isOverlayVisible = true;
          });
        },
      ),
    );
  }

  Widget _buildRecipeImage(String imageName) {
    return FutureBuilder<String>(
      future: FirebaseStorage.instance.ref('images/$imageName.jpg').getDownloadURL(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return const Icon(Icons.error);
        }

        String? imageUrl = snapshot.data;

        if (imageUrl == null) {
          return const Icon(Icons.image_not_supported);
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: 45,
            height: 45,
          ),
        );
      },
    );
  }

  Widget _buildCategoryButton(String title, Function onPressed) {
    return Container(
      width: 120,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        onPressed: () {
          onPressed();
        },
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildRecipeWidget(Recipe recipe) {
    return FutureBuilder<String>(
      future: _storage.ref('images/${recipe.imageName}.jpg').getDownloadURL(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('Error loading image for recipe ${recipe.id}: ${snapshot.error}');
          return Center(child: Text('Error loading image'));
        }

        String? imageUrl = snapshot.data;

        if (imageUrl == null) {
          return Center(child: Text('Image URL is null'));
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecipeDetailPage(recipeId: recipe.id)),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            width: 220,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}