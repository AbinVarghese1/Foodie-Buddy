import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:foodiebuddyapp/Screens/Home/recipe_detail.dart';


class RecipePopular {
  final String id;
  final String title;
  final String imageName;
  final String cuisines;
  final String cookTime;

  RecipePopular({
    required this.id,
    required this.title,
    required this.imageName,
    required this.cuisines,
    required this.cookTime,
  });

  // Factory constructor with null checks
  factory RecipePopular.fromMap(Map<String, dynamic> data) {
    assert(data['RecipeID'] != null, "RecipeID is required");
    assert(data['Title'] != null, "Title is required");
    assert(data['Image_Name'] != null, "Image_Name is required");
    assert(data['Cuisine'] != null, "Cuisine is required");
    assert(data['CookTime'] != null, "CookTime is required");

    return RecipePopular(
      id: data['RecipeID'] ?? '', // Use default values or empty strings if needed
      title: data['Title'] ?? 'Unknown Recipe',
      imageName: data['Image_Name'] ?? '',
      cuisines: data['Cuisine'] ?? 'Unknown Cuisine',
      cookTime: data['CookTime'] ?? 'Unknown Time',
    );
  }

  factory RecipePopular.fromDocument(DocumentSnapshot doc) {
    return RecipePopular.fromMap(doc.data() as Map<String, dynamic>);
  }
}



class PopularWidget extends StatefulWidget {
  final RecipePopular recipe;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  PopularWidget({
    required this.recipe,
    required this.firestore,
    required this.storage,
    required this.auth,
  });

  @override
  _PopularWidgetState createState() => _PopularWidgetState();
}

class _PopularWidgetState extends State<PopularWidget> {
  @override
  Widget build(BuildContext context) {
    final user = widget.auth.currentUser;

    if (user == null) {
      return Container(); // No-op if there's no user logged in
    }

    return FutureBuilder<QuerySnapshot>(
      future: widget.firestore
          .collection("favorites")
          .where("UserId", isEqualTo: user.uid)
          .where("RecipeID", isEqualTo: widget.recipe.id)
          .get(),
      builder: (context, favSnapshot) {
        bool isFavorite = favSnapshot.hasData && favSnapshot.data!.docs.isNotEmpty;

        return FutureBuilder<String>(
          future: widget.storage
              .ref('images/${widget.recipe.imageName}.jpg')
              .getDownloadURL(),
          builder: (context, imageSnapshot) {
            if (imageSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (imageSnapshot.hasError || !imageSnapshot.hasData) {
              return Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey,
                ),
                child: const Center(child: Icon(Icons.broken_image)),
              );
            }

            String imageUrl = imageSnapshot.data!;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RecipeDetailPage(recipeId: widget.recipe.id),
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
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 160,
                          width: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.recipe.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(widget.recipe.cuisines),
                                Text("Cooking Time: ${widget.recipe.cookTime}"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.black,
                        ),
                        onPressed: () {
                          if (isFavorite) {
                            // Remove from favorites
                             widget.firestore
                                .collection("favorites")
                                .doc(favSnapshot.data!.docs.first.id)
                                .delete();
                          } else {
                            // Add to favorites
                            widget.firestore
                                .collection("favorites")
                                .add({
                                  "UserId": user.uid,
                                  "RecipeID": widget.recipe.id,
                                });
                          }
                          setState(() {}); // Refresh the widget to reflect the change
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
