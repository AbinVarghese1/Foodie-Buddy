import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewService {
  final CollectionReference reviewsCollection = FirebaseFirestore.instance.collection('reviews');
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  Future<void> addReview(String recipeId, String userId, String reviewText, double rating) async {
    await reviewsCollection.add({
      'RecipeID': recipeId,
      'userId': userId,
      'reviewText': reviewText,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getReviewsForRecipe(String recipeId) {
    return reviewsCollection
        .where('RecipeID', isEqualTo: recipeId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<String> getUsernameById(String userId) async {
    try {
      DocumentSnapshot userDoc = await usersCollection.doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData['username'] ?? 'Anonymous';
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
    return 'Anonymous';
  }
}