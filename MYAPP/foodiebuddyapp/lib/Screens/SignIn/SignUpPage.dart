import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:foodiebuddyapp/Screens/AuthProvider/authprovider.dart';
import 'package:foodiebuddyapp/Screens/Components/rootpage.dart';
import 'package:foodiebuddyapp/Screens/Login/loginpage.dart';
import 'package:foodiebuddyapp/Screens/SignIn/signupdetails.dart';
import 'package:foodiebuddyapp/theme.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFC9EFC6),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double horizontalPadding = screenWidth * 0.1;
          double verticalPadding = 16;
          double imageHeight = screenWidth * 0.5;

          return Container(
            color: const Color(0xFFC9EFC6),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'You will get personalised experience',
                        textAlign: TextAlign.center,
                        style: AppTheme.textTheme.bodyLarge?.copyWith(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: verticalPadding),
                      Text(
                        'Sign up and start\n cooking',
                        textAlign: TextAlign.center,
                        style: AppTheme.textTheme.displayLarge?.copyWith(
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: verticalPadding),
                      Image.asset(
                        'assets/cookingimage.png',
                        height: imageHeight,
                      ),
                      SizedBox(height: verticalPadding * 2),
                      ElevatedButton(
                        onPressed: () => googleSignIn(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: verticalPadding),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.g_mobiledata, color: Colors.black, size: screenWidth * 0.08),
                            SizedBox(width: 16),
                            Text(
                              'Sign up with Google',
                              style: AppTheme.textTheme.bodyLarge?.copyWith(
                                fontSize: screenWidth * 0.05,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: verticalPadding),
                      ElevatedButton(
                        onPressed: () => appleSignIn(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: verticalPadding),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.apple, color: Colors.black, size: screenWidth * 0.08),
                            SizedBox(width: 16),
                            Text(
                              'Sign up with Apple',
                              style: AppTheme.textTheme.bodyLarge?.copyWith(
                                fontSize: screenWidth * 0.05,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: verticalPadding),
                      Text(
                        '------------------ or ------------------',
                        style: AppTheme.textTheme.bodyMedium?.copyWith(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: verticalPadding),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpForm()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4AA469),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.1,
                            vertical: verticalPadding,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Create new account',
                          style: AppTheme.textTheme.bodyLarge?.copyWith(
                            fontSize: screenWidth * 0.05,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: verticalPadding),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyLoginPage()),
                          );
                        },
                        child: Text(
                          'Already have an account? Sign in',
                          style: AppTheme.textTheme.bodyMedium?.copyWith(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> googleSignIn(BuildContext context) async {
    try {
      print('Starting Google Sign-In process');
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Google Sign-In was canceled by the user');
        return;
      }

      print('Google Sign-In successful. Getting auth details...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('Creating credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in with credential...');
      await _signInWithCredential(context, credential, googleUser: googleUser);
    } catch (e) {
      print('Detailed Google Sign-In error: $e');
      if (e is PlatformException) {
        print('Error code: ${e.code}');
        print('Error message: ${e.message}');
        print('Error details: ${e.details}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in with Google: $e')),
      );
    }
  }

  Future<void> appleSignIn(BuildContext context) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final appleUserInfo = AppleUserInfo(
        email: credential.email,
        givenName: credential.givenName,
        familyName: credential.familyName,
      );

      await _signInWithCredential(context, oauthCredential, appleUserInfo: appleUserInfo);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in with Apple: $e')),
      );
    }
  }

  Future<void> _signInWithCredential(
    BuildContext context,
    OAuthCredential credential, {
    GoogleSignInAccount? googleUser,
    AppleUserInfo? appleUserInfo,
  }) async {
    try {
      print('Attempting to sign in with Firebase...');
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        print('Firebase sign-in successful. Storing user data...');
        await _storeUserData(user, googleUser: googleUser, appleUserInfo: appleUserInfo);

        print('Checking if additional info is needed...');
        if (await _needsAdditionalInfo(user.uid)) {
          print('Additional info needed. Navigating to ProfileCompletionPage...');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfileCompletionPage(user: user)),
          );
        } else {
          print('No additional info needed. Logging in and navigating to RootPage...');
          Provider.of<CustomAuthProvider>(context, listen: false).login();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RootPage()),
          );
        }
      } else {
        throw Exception('Sign-in failed: user is null');
      }
    } catch (e) {
      print('Error in _signInWithCredential: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _storeUserData(
    User firebaseUser, {
    GoogleSignInAccount? googleUser,
    AppleUserInfo? appleUserInfo,
  }) async {
    final userRef = FirebaseFirestore.instance.collection('userdata').doc(firebaseUser.uid);

    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      String? name;
      if (googleUser != null) {
        name = googleUser.displayName;
    
      } else if (appleUserInfo != null) {
        name = '${appleUserInfo.givenName} ${appleUserInfo.familyName}';
      }

      await userRef.set({
        'email': firebaseUser.email,
        'name': name,
        'uid': firebaseUser.uid,
      });
    }
  }

  Future<bool> _needsAdditionalInfo(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('userdata').doc(uid);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      final data = userDoc.data();
      return !(data != null && data.containsKey('additionalInfo') && data['additionalInfo'] != null);
    }

    return true;
  }
}

class AppleUserInfo {
  final String? email;
  final String? givenName;
  final String? familyName;

  AppleUserInfo({this.email, this.givenName, this.familyName});
}

Future<bool> _needsAdditionalInfo(String uid) async {
  final userDoc = await FirebaseFirestore.instance.collection('userdata').doc(uid).get();
  final userData = userDoc.data() as Map<String, dynamic>?;

  return userData == null ||
      userData['date_of_birth'] == '' ||
      userData['gender'] == '' ||
      userData['profession'] == '';
}

class ProfileCompletionPage extends StatefulWidget {
  final User user;

  ProfileCompletionPage({required this.user});

  @override
  _ProfileCompletionPageState createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends State<ProfileCompletionPage> {
  final _formKey = GlobalKey<FormState>();
  String? _dateOfBirth;
  String? _gender;
  String? _profession;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC9EFC6),
      appBar: AppBar(
        title: Text('Complete Your Profile'),
        backgroundColor: const Color(0xFFC9EFC6),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                filled: true,
                fillColor: Colors.white,
              ),
              onSaved: (value) => _dateOfBirth = value,
              validator: (value) => value!.isEmpty ? 'Please enter your date of birth' : null,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Gender',
                filled: true,
                fillColor: Colors.white,
              ),
              items: ['Male', 'Female', 'Other'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) => setState(() => _gender = value),
              validator: (value) => value == null ? 'Please select your gender' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Profession',
                filled: true,
                fillColor: Colors.white,
              ),
              onSaved: (value) => _profession = value,
              validator: (value) => value!.isEmpty ? 'Please enter your profession' : null,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4AA469),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await FirebaseFirestore.instance.collection('userdata').doc(widget.user.uid).update({
        'date_of_birth': _dateOfBirth,
        'gender': _gender,
        'profession': _profession,
      });

      Provider.of<CustomAuthProvider>(context, listen: false).login();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RootPage()),
      );
    }
  }
}