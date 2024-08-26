import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodiebuddyapp/Screens/Components/Cart/cartservice.dart';
import 'package:foodiebuddyapp/theme.dart';


class CartPage extends StatelessWidget {
  final CartService _cartService = CartService();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFC9EFC6),
          elevation: 0,
          title: Text('Shopping Cart', style: AppTheme.textTheme.displayMedium),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'deleteAll') {
                  _cartService.clearCart();
                } else if (value == 'uncheckAll') {
                  _cartService.uncheckAllItems();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'deleteAll',
                  child: Text('Delete entire shopping cart'),
                ),
                const PopupMenuItem<String>(
                  value: 'uncheckAll',
                  child: Text('Uncheck all ingredients'),
                ),
              ],
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _cartService.getCartItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: AppTheme.textTheme.bodyLarge));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Your cart is empty', style: AppTheme.textTheme.bodyLarge));
            }

            final Map<String, List<QueryDocumentSnapshot>> groupedItems = {};
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final recipeId = data['RecipeID'];
              if (!groupedItems.containsKey(recipeId)) {
                groupedItems[recipeId] = [];
              }
              groupedItems[recipeId]!.add(doc);
            }

            return ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              children: groupedItems.entries.map((entry) {
                final recipeId = entry.key;
                final items = entry.value;

                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('recipe')
                      .where('RecipeID', isEqualTo: recipeId)
                      .limit(1)
                      .get(),
                  builder: (context, recipeSnapshot) {
                    if (recipeSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (recipeSnapshot.hasError) {
                      return Center(child: Text('Error: ${recipeSnapshot.error}', style: AppTheme.textTheme.bodyLarge));
                    }

                    if (!recipeSnapshot.hasData || recipeSnapshot.data!.docs.isEmpty) {
                      return Center(child: Text('Recipe not found', style: AppTheme.textTheme.bodyLarge));
                    }

                    final recipeData = recipeSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                    final String imageName = recipeData['Image_Name'];

                    return FutureBuilder<String>(
                      future: FirebaseStorage.instance
                          .ref('images/$imageName.jpg')
                          .getDownloadURL(),
                      builder: (context, imageSnapshot) {
                        if (imageSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (imageSnapshot.hasError) {
                          return Center(child: Text('Image error: ${imageSnapshot.error}', style: AppTheme.textTheme.bodyLarge));
                        }

                        String imageUrl = imageSnapshot.data ?? '';

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 4.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12.0),
                                          child: Image.network(
                                            imageUrl,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            recipeData['Title'],
                                            style: AppTheme.textTheme.displayMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: InkWell(
                                        onTap: () {
                                          _cartService.removeAllIngredientsFromCart(recipeId);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.red,
                                          ),
                                          child: Icon(Icons.remove, color: Colors.white, size: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ...items.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return Column(
                                  children: [
                                    ShoppingCartItem(
                                      id: doc.id,
                                      ingredient: data['ingredient'],
                                      isChecked: data['isChecked'] ?? false,
                                      onRemove: () => _cartService.removeFromCart(recipeData['RecipeID'], data['ingredient']),                                      onToggleCheck: (bool? value) {
                                        if (value != null) {
                                          _cartService.updateCartItem(doc.id, {'isChecked': value});
                                        }
                                      },
                                    ),
                                    Divider(height: 1, thickness: 1),
                                    SizedBox(height: 4), // Small space between ingredients
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class ShoppingCartItem extends StatelessWidget {
  final String id;
  final String ingredient;
  final bool isChecked;
  final VoidCallback onRemove;
  final ValueChanged<bool?> onToggleCheck;

  ShoppingCartItem({
    required this.id,
    required this.ingredient,
    required this.isChecked,
    required this.onRemove,
    required this.onToggleCheck,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: isChecked,
        onChanged: onToggleCheck,
        shape: CircleBorder(),
      ),
      title: Text(ingredient, style: AppTheme.textTheme.bodyLarge),
      trailing: InkWell(
        onTap: onRemove,
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF33938F),
          ),
          child: Icon(Icons.remove, color: Colors.white, size: 12),
        ),
      ),
    );
  }
}