import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodiebuddyapp/theme.dart';

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('userdata')
          .doc(user!.uid)
          .get();
      if (doc.exists) {
        setState(() {
          userData = doc.data() as Map<String, dynamic>;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC9EFC6),
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: AppTheme.textTheme.displayMedium!.copyWith(color: Colors.black), // Use displayMedium style from AppTheme
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildInfoBox('Username', userData['username'] ?? '', context),
          _buildInfoBox('Email', userData['email'] ?? '', context),
          _buildInfoBox('Date of Birth', userData['date_of_birth'] ?? '', context),
          _buildInfoBox('Gender', userData['gender'] ?? '', context),
          _buildInfoBox('Profession', userData['profession'] ?? '', context),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
