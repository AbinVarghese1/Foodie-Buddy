import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:foodiebuddyapp/Admin/trending.dart';


class ContentModerationPage extends StatefulWidget {
  @override
  _ContentModerationPageState createState() => _ContentModerationPageState();
}

class _ContentModerationPageState extends State<ContentModerationPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC9EFC6), // Consistent background color
      body: FutureBuilder<QuerySnapshot>(
        future: _firestore.collection("newrecipe").get(), // Fetching recipes
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Display loading indicator
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching data")); // Handle errors
          }

          return CustomScrollView(
            slivers: [
              const SliverAppBar(
                backgroundColor: const Color(0xFFC9EFC6),
                pinned: true,
                floating: true,
                expandedHeight: 100,
                leading: BackButton(), // Navigation back
                flexibleSpace: FlexibleSpaceBar(
                  title: Text('Content Moderation', style: TextStyle(fontSize: 20, color: Colors.black)),
                  centerTitle: false,
                ),
              ),
              snapshot.hasData && snapshot.data!.docs.isNotEmpty
               ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return TrendingDishWidget(
                          recipe: TrendingDish.fromMap(snapshot.data!.docs[index].data() as Map<String, dynamic>),
                          firestore: _firestore,
                          storage: storage,
                          auth: auth,
                        );
                      },
                      childCount: snapshot.data!.docs.length,
                    ),
                  )
                : const SliverToBoxAdapter(
                    child: Center(child: Text("No recipes found")), // Handle no data
                  ),
            ],
          );
        },
      ),
    );
  }
}


