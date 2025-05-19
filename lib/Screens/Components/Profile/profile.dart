import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:foodiebuddyapp/Screens/Components/Profile/aboutpage.dart';
import 'package:foodiebuddyapp/Screens/Components/Profile/changepasswordpage.dart';
import 'package:foodiebuddyapp/Screens/Components/Profile/feedbacksupportpage.dart';
import 'package:foodiebuddyapp/Screens/Components/Profile/myprofile.dart';
import 'package:foodiebuddyapp/Screens/SignIn/SignUpPage.dart';
import 'package:foodiebuddyapp/theme.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  String? profileImageUrl;
  String username = "";
  String email = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('userdata')
            .doc(user!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc['username'] ?? "";
            email = userDoc['email'] ?? "";
            profileImageUrl = userDoc['profileImageUrl'];
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _changeProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      if (user != null) {
        try {
          setState(() {
            isLoading = true;
          });

          // Upload image to Firebase Storage
          String fileName = 'profile_${user!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          TaskSnapshot snapshot = await FirebaseStorage.instance
              .ref('profile_images/$fileName')
              .putFile(imageFile);

          // Get image URL from Firebase Storage
          String imageUrl = await snapshot.ref.getDownloadURL();

          // Update profile image URL in Firestore
          await FirebaseFirestore.instance
              .collection('userdata')
              .doc(user!.uid)
              .update({'profileImageUrl': imageUrl});

          // Update local profile image URL
          setState(() {
            profileImageUrl = imageUrl;
          });
        } catch (e) {
          print("Error uploading image: $e");
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFC9EFC6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _changeProfileImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: screenWidth * 0.18,
                            backgroundColor: Colors.white,
                            backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                                ? NetworkImage(profileImageUrl!)
                                : AssetImage('assets/images/profile.png') as ImageProvider,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.withOpacity(0.7),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: screenWidth * 0.07,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      username,
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                    const SizedBox(height: 25),
                    _buildOptionButton('My Profile', Icons.person, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyProfilePage()));
                    }),
                    const SizedBox(height: 8),
                    _buildOptionButton('Change Password', Icons.lock, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordPage()));
                    }),
                    const SizedBox(height: 8),
                    _buildOptionButton('Feedback and Support', Icons.support_agent, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackSupportPage()));
                    }),
                    const SizedBox(height: 8),
                    _buildOptionButton('About Foodie Buddy', Icons.info, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage()));
                    }),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut().then((_) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                        });
                      },
                      child: const Text('Log Out'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.2,
                          vertical: screenHeight * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOptionButton(String title, IconData icon, VoidCallback onPressed) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.1,
        vertical: screenHeight * 0.01,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.75, // Adjust the width as per your requirement
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: screenWidth * 0.05),
                Icon(icon, color: Colors.black, size: screenWidth * 0.07),
                SizedBox(width: screenWidth * 0.05),
                Text(
                  title,
                  style: AppTheme.textTheme.bodyLarge?.copyWith(fontSize: screenWidth * 0.05),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
