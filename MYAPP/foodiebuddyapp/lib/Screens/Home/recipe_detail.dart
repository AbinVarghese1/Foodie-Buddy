import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodiebuddyapp/Screens/Components/Cart/cartservice.dart';
import 'package:foodiebuddyapp/Screens/Home/Review/review_service.dart';
import 'package:foodiebuddyapp/Screens/Home/Review/reviewpage.dart';
import 'package:foodiebuddyapp/theme.dart';

class RecipeDetailPage extends StatefulWidget {
  final String recipeId;

  RecipeDetailPage({required this.recipeId});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<DocumentSnapshot> _recipeData;
  bool isFavorite = false;
  final CartService _cartService = CartService();
  final ReviewService _reviewService = ReviewService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _recipeData = FirebaseFirestore.instance
        .collection("recipe")
        .where("RecipeID", isEqualTo: widget.recipeId)
        .limit(1)
        .get()
        .then((snapshot) => snapshot.docs.first);
    _checkIfFavorite();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final favCollection = FirebaseFirestore.instance.collection('favorites');

    final existingFavorite = await favCollection
        .where('UserId', isEqualTo: user.uid)
        .where('RecipeID', isEqualTo: widget.recipeId)
        .get();

    setState(() => isFavorite = existingFavorite.docs.isNotEmpty);
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final favCollection = FirebaseFirestore.instance.collection('favorites');

    final existingFavorite = await favCollection
        .where('UserId', isEqualTo: user.uid)
        .where('RecipeID', isEqualTo: widget.recipeId)
        .get();

    if (existingFavorite.docs.isNotEmpty) {
      await favCollection.doc(existingFavorite.docs.first.id).delete();
      setState(() => isFavorite = false);
    } else {
      await favCollection.add({
        'UserId': user.uid,
        'RecipeID': widget.recipeId,
      });
      setState(() => isFavorite = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        body: FutureBuilder<DocumentSnapshot>(
          future: _recipeData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("An error occurred while fetching the recipe details."));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("Recipe not found."));
            }
            var recipeData = snapshot.data!.data() as Map<String, dynamic>;
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.width - 20,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: FutureBuilder<String>(
                      future: _getImageUrl(recipeData["Image_Name"]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return const Center(child: Text("Error loading image."));
                        }

                        if (snapshot.hasData) {
                          return Image.network(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          );
                        }

                        return const Center(child: Text("Image not available"));
                      },
                    ),
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(CupertinoIcons.chevron_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                recipeData["Title"],
                                style: AppTheme.textTheme.displayMedium,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                              child: IconButton(
                                icon: Icon(isFavorite ? Icons.favorite : Icons.add),
                                onPressed: _toggleFavorite,
                                tooltip: isFavorite ? "Remove from favorites" : "Add to favorites",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelStyle: AppTheme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                      unselectedLabelStyle: AppTheme.textTheme.bodySmall,
                      indicatorColor: Colors.blue,
                      tabs: [
                        Tab(text: "Overview"),
                        Tab(text: "Ingredients"),
                        Tab(text: "Directions"),
                        Tab(text: "Reviews"),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(recipeData),
                      _buildIngredientsTab(recipeData),
                      _buildDirectionsTab(recipeData),
                      _buildReviewsTab(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> recipeData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                recipeData["Rating"] != null ? "${recipeData["Rating"].toStringAsFixed(1)}" : "No rating",
                style: AppTheme.textTheme.displaySmall,
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.timer, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                "Cook Time: ${recipeData["CookTime"]}",
                style: AppTheme.textTheme.bodyMedium,
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.restaurant_menu, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                "Cuisine: ${recipeData["Cuisine"]}",
                style: AppTheme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab(Map<String, dynamic> recipeData) {
  // Parse ingredients from the new format
  List<String> ingredients = (recipeData["Ingredients"] as String).split('|').map((e) => e.trim()).toList();

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<bool>(
          future: _areAllIngredientsInCart(recipeData),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            bool allInCart = snapshot.data ?? false;
            return Row(
              children: [
                Icon(allInCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart, color: Colors.teal),
                SizedBox(width: 8),
                InkWell(
                  onTap: allInCart 
                    ? () => _removeAllIngredientsFromCart(recipeData)
                    : () => _addAllIngredientsToCart(recipeData),
                  child: Text(
                    allInCart ? 'Remove All' : 'Add All to Shopping List',
                    style: AppTheme.textTheme.bodyLarge?.copyWith(color: Colors.teal),
                  ),
                ),
              ],
            );
          },
        ),
        Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              String ingredient = ingredients[index];
              return FutureBuilder<bool>(
                future: _cartService.isIngredientInCart(widget.recipeId, ingredient),
                builder: (context, snapshot) {
                  bool isInCart = snapshot.data ?? false;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      radius: 15,
                      child: IconButton(
                        icon: Icon(
                          isInCart ? Icons.remove : Icons.add,
                          color: Colors.white,
                          size: 15,
                        ),
                        onPressed: () => _toggleIngredientInCart(ingredient),
                      ),
                    ),
                    title: Text(ingredient, style: AppTheme.textTheme.bodyMedium),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

void _removeAllIngredientsFromCart(Map<String, dynamic> recipeData) async {
  await _cartService.removeAllIngredientsFromCart(widget.recipeId);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('All ingredients removed from cart')),
  );
  setState(() {});
}

void _toggleIngredientInCart(String ingredient) async {
  bool isInCart = await _cartService.isIngredientInCart(widget.recipeId, ingredient);
  if (isInCart) {
    await _cartService.removeFromCart(widget.recipeId, ingredient);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$ingredient removed from cart')),
    );
  } else {
    await _cartService.addToCart(widget.recipeId, ingredient, 1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$ingredient added to cart')),
    );
  }
  setState(() {});
}

  Widget _buildDirectionsTab(Map<String, dynamic> recipeData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Instructions:",
              style: AppTheme.textTheme.bodyLarge,
            ),
            ...(recipeData["Instructions"] as String).split('\n').map((instruction) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  instruction.trim(),
                  style: AppTheme.textTheme.bodyMedium,
                ),
              )
            ),
          ],
        ),
      ),
    );
  }

Widget _buildReviewsTab() {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.star, color: Colors.white),
              label: Text('Leave a Review', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewPage(recipeId: widget.recipeId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: _reviewService.getReviewsForRecipe(widget.recipeId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No reviews yet. Be the first to review!'),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var review = snapshot.data!.docs[index];
                return FutureBuilder<String>(
                  future: _reviewService.getUsernameById(review['userId']),
                  builder: (context, usernameSnapshot) {
                    if (usernameSnapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    String username = usernameSnapshot.data ?? 'Anonymous';
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey[200],
                                  child: Icon(Icons.person, color: Colors.grey[400]),
                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      username,
                                      style: AppTheme.textTheme.bodySmall,
                                    ),
                                    Text(
                                      '${_formatTimestamp(review['createdAt'])}',
                                      style: AppTheme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  index < (review['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              review['reviewText'] ?? '',
                              style: AppTheme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    ],
  );
}
String _formatTimestamp(Timestamp? timestamp) {
  if (timestamp == null) return 'Unknown';
  final now = DateTime.now();
  final difference = now.difference(timestamp.toDate());
  if (difference.inDays > 365) {
    return '${(difference.inDays / 365).floor()} years ago';
  } else if (difference.inDays > 30) {
    return '${(difference.inDays / 30).floor()} months ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} days ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hours ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minutes ago';
  } else {
    return 'Just now';
  }
}

  Future<String> _getImageUrl(String imageName) async {
    final ref = FirebaseStorage.instance.ref().child('images/$imageName.jpg');
    return ref.getDownloadURL();
  }

  void _addAllIngredientsToCart(Map<String, dynamic> recipeData) async {
  List<String> ingredients = (recipeData["Ingredients"] as String).split('|').map((e) => e.trim()).toList();
  for (String ingredient in ingredients) {
    await _cartService.addToCart(widget.recipeId, ingredient, 1);
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('All ingredients added to cart')),
  );
  setState(() {});
}

  void _addIngredientToCart(String ingredient) async {
    bool isInCart = await _cartService.isIngredientInCart(widget.recipeId, ingredient);
    if (isInCart) {
      await _cartService.removeFromCart(widget.recipeId, ingredient);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$ingredient removed from cart')),
      );
    } else {
      await _cartService.addToCart(widget.recipeId, ingredient, 1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$ingredient added to cart')),
      );
    }
    setState(() {});
  }
  Future<bool> _areAllIngredientsInCart(Map<String, dynamic> recipeData) async {
  List<String> ingredients = (recipeData["Ingredients"] as String).split('|').map((e) => e.trim()).toList();
  for (String ingredient in ingredients) {
    if (!await _cartService.isIngredientInCart(widget.recipeId, ingredient)) {
      return false;
    }
  }
  return true;
}

}
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}