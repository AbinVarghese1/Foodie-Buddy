import 'package:flutter/material.dart';
import 'package:foodiebuddyapp/Screens/AuthProvider/authprovider.dart';
import 'package:foodiebuddyapp/Screens/Components/rootpage.dart';
import 'package:foodiebuddyapp/Screens/SignIn/SignUpPage.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAuthState();
  }

  Future<void> checkAuthState() async {
  await Future.delayed(const Duration(seconds: 3));
  final authProvider = Provider.of<CustomAuthProvider>(context, listen: false);
  
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      authProvider.login();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RootPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignUpPage()),
      );
    }
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC9EFC6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Main-icon.png',
              height: 350,
            ),
            const SizedBox(height: 20),
          
          ],
        ),
      ),
    );
  }
}