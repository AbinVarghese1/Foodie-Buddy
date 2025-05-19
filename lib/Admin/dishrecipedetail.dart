import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';


class DishDetailPage extends StatefulWidget {
  final String recipeId; // Use DishID instead of RecipeID

  DishDetailPage({required this.recipeId});

  @override
  _DishDetailPageState createState() => _DishDetailPageState();
}


class _DishDetailPageState extends State<DishDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<DocumentSnapshot> _recipeData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _recipeData = FirebaseFirestore.instance
        .collection("newrecipe")
        .where("RecipeID", isEqualTo: widget.recipeId)
        .limit(1)
        .get()
        .then((snapshot) => snapshot.docs.first);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: _recipeData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text("An error occurred while fetching the dish details."));
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text("Dish not found."));
              }

              var recipeData = snapshot.data!.data() as Map<String, dynamic>;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width - 20,
                    child: Stack(
                      children: [
                        FutureBuilder<String>(
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
                                height: MediaQuery.of(context).size.width - 20,
                              );
                            }

                            return const Center(child: Text("Image not available"));
                          },
                        ),
                        Positioned(
                          top: 40,
                          left: 10,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(CupertinoIcons.chevron_back),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width - 90,
                                  child: Text(
                                    recipeData["Title"],
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              labelStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontSize: 16,
                              ),
                              indicatorColor: Colors.blue,
                              tabs: [
                                const Tab(text: "Overview"),
                                const Tab(text: "Ingredients"),
                                const Tab(text: "Instructions"),
                                const Tab(text: "Reviews"),
                              ],
                            ),
                            Container(
                              height: 350,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Cook Time: ${recipeData["CookTime"]}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Cuisine: ${recipeData["Cuisine"]}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight .bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Ingredients:",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        ...(recipeData["Ingredients"])
                                            .split(',')
                                            .map((ingredient) => Text(
                                                  ingredient.trim(),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                )),
                                      ],
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Instructions:",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight .bold,
                                          ),
                                        ),
                                        ...(recipeData["Instructions"].split('\n'))
                                            .map((instruction) => Padding(
                                                  padding: const EdgeInsets.only(bottom: 8),
                                                  child: Text(
                                                    instruction.trim(),
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                )),
                                      ],
                                    ),
                                  ),
                                  const Center(child: Text("No reviews yet")),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          _buildPersistentButtons(), // Persistent buttons at the bottom
        ],
      ),
    );
  }

 Widget _buildPersistentButtons() {
  return Positioned(
    bottom: 20,
    left: 40, // Increase padding to move the buttons towards the center
    right: 40, // Increase padding to move the buttons towards the center
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space the buttons evenly
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.green, // White text color
            minimumSize: const Size(120, 50), // Increase the button size
            textStyle: const TextStyle(fontSize: 18), // Larger font size
          ),
          onPressed: _onAcceptPressed,
          child: const Text("Accept"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.red, // White text color
            minimumSize: const Size(120, 50), // Increase the button size
            textStyle: const TextStyle(fontSize: 18), // Larger font size
          ),
          onPressed: _onRejectPressed,
          child: const Text("Reject"),
        ),
      ],
    ),
  );
}


  void _onAcceptPressed() {
    _recipeData.then((doc) async {
      if (doc.exists) {
        // Step 1: Copy to new collection
        await FirebaseFirestore.instance
            .collection("recipe") // New collection to move to
            .doc(doc.id) // Same document ID
            .set(doc.data() as Map<String, dynamic>); // Set data from the original document

        // Step 2: Delete from current collection
        await FirebaseFirestore.instance
            .collection("newrecipe")
            .doc(doc.id)
            .delete();

        // Step 3: Navigate to the desired page (e.g., ContentModerationPage)
       Navigator.pushReplacementNamed(
          // ignore: use_build_context_synchronously
          context,
          '/contentModeration', // Corrected syntax for navigation
        ); // Adjust this route to your app's structure
      }
    });
  }

void _onRejectPressed() {
    _recipeData.then((doc) async {
      if (doc.exists) {
        // Delete the document from the current collection
        await FirebaseFirestore.instance
            .collection("newrecipe") // The current collection
            .doc(doc.id) // Delete by document ID
            .delete(); // Delete the document

        // Navigate to ContentModerationPage
        Navigator.pushReplacementNamed(context, '/contentModeration'); // Navigate to ContentModerationPage
      }
    });
  }

  Future<String> _getImageUrl(String imageName) async {
    final ref = FirebaseStorage.instance.ref().child('images/$imageName.jpg');
    return ref.getDownloadURL(); // Fetch the image URL from Firebase Storage
  }
}

