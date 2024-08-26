import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foodiebuddyapp/Admin/adminpage.dart';
import 'package:foodiebuddyapp/Screens/AuthProvider/authprovider.dart';
import 'package:foodiebuddyapp/Screens/Components/rootpage.dart';
import 'package:foodiebuddyapp/Screens/Login/forgotpassword.dart';
import 'package:foodiebuddyapp/Screens/Login/loginpage.dart';
import 'package:foodiebuddyapp/Screens/SignIn/SignUpPage.dart';
import 'package:foodiebuddyapp/Screens/SignIn/signupdetails.dart';
import 'package:foodiebuddyapp/Screens/Splash/splash.dart';
import 'package:foodiebuddyapp/theme.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CustomAuthProvider(),
      child: MaterialApp(
        theme: AppTheme.themeData,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/signin': (context) => SignUpPage(),
          '/signup': (context) => SignUpForm(),
          '/login': (context) => MyLoginPage(),
          '/forgot-password': (context) => Forget(),
          '/home': (context) => RootPage(),
          '/admin': (context) => AdminPage(),
        },
      ),
    );
  }
}