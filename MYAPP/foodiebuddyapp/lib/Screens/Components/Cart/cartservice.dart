import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addToCart(String recipeId, String ingredient, int quantity) async {
    final user = _auth.currentUser;
    if (user != null) {
      // Check if the ingredient already exists in the cart
      final existingItem = await _firestore
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .where('RecipeID', isEqualTo: recipeId)
          .where('ingredient', isEqualTo: ingredient)
          .get();

      if (existingItem.docs.isNotEmpty) {
        // If the ingredient exists, update the quantity
        await _firestore
            .collection('carts')
            .doc(user.uid)
            .collection('items')
            .doc(existingItem.docs.first.id)
            .update({'quantity': FieldValue.increment(quantity)});
      } else {
        // If the ingredient doesn't exist, add it to the cart
        await _firestore.collection('carts').doc(user.uid).collection('items').add({
          'RecipeID': recipeId,
          'ingredient': ingredient,
          'quantity': quantity,
          'isChecked': false,
        });
      }
    }
  }
  
  Future<void> removeFromCart(String recipeId, String ingredient) async {
    final user = _auth.currentUser;
    if (user != null) {
      final itemToRemove = await _firestore
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .where('RecipeID', isEqualTo: recipeId)
          .where('ingredient', isEqualTo: ingredient)
          .get();

      if (itemToRemove.docs.isNotEmpty) {
        await _firestore
            .collection('carts')
            .doc(user.uid)
            .collection('items')
            .doc(itemToRemove.docs.first.id)
            .delete();
      }
    }
  }

  Future<void> updateCartItem(String itemId, Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('carts').doc(user.uid).collection('items').doc(itemId).update(data);
    }
  }

  Stream<QuerySnapshot> getCartItems() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('carts').doc(user.uid).collection('items').snapshots();
    }
    return Stream.empty();
  }

  Future<void> clearCart() async {
    final user = _auth.currentUser;
    if (user != null) {
      final cartRef = _firestore.collection('carts').doc(user.uid);
      final itemsSnapshot = await cartRef.collection('items').get();
      final batch = _firestore.batch();
      for (var doc in itemsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<void> uncheckAllItems() async {
    final user = _auth.currentUser;
    if (user != null) {
      final cartRef = _firestore.collection('carts').doc(user.uid);
      final itemsSnapshot = await cartRef.collection('items').get();
      final batch = _firestore.batch();
      for (var doc in itemsSnapshot.docs) {
        batch.update(doc.reference, {'isChecked': false});
      }
      await batch.commit();
    }
  }

  Future<bool> isIngredientInCart(String recipeId, String ingredient) async {
    final user = _auth.currentUser;
    if (user != null) {
      final existingItem = await _firestore
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .where('RecipeID', isEqualTo: recipeId)
          .where('ingredient', isEqualTo: ingredient)
          .get();

      return existingItem.docs.isNotEmpty;
    }
    return false;
  }

  Future<void> addAllIngredientsToCart(String recipeId, List<String> ingredients) async {
    final user = _auth.currentUser;
    if (user != null) {
      final batch = _firestore.batch();
      for (var ingredient in ingredients) {
        final docRef = _firestore.collection('carts').doc(user.uid).collection('items').doc();
        batch.set(docRef, {
          'RecipeID': recipeId,
          'ingredient': ingredient,
          'quantity': 1,
          'isChecked': false,
        });
      }
      await batch.commit();
    }
  }

  Future<void> removeAllIngredientsFromCart(String recipeId) async {
  final user = _auth.currentUser;
  if (user != null) {
    final itemsToRemove = await _firestore
        .collection('carts')
        .doc(user.uid)
        .collection('items')
        .where('RecipeID', isEqualTo: recipeId)
        .get();

    final batch = _firestore.batch();
    for (var doc in itemsToRemove.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
}