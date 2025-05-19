import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodiebuddyapp/Admin/adminpage.dart';
import 'package:foodiebuddyapp/Screens/Components/rootpage.dart';
import 'package:foodiebuddyapp/Screens/Login/forgotpassword.dart';
import 'package:foodiebuddyapp/theme.dart';

class MyLoginPage extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<MyLoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _usernameError;
  String? _passwordError;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        body: Container(
          color: const Color(0xFFC9EFC6),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/Main-icon.png", height: 250, width: 250),
                  const SizedBox(height: 32.0),
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Mobile number or email address',
                    errorText: _usernameError,
                  ),
                  const SizedBox(height: 16.0),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    errorText: _passwordError,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _handleLogin,
                    child: Text('Log in', style: AppTheme.textTheme.bodyLarge),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color(0xFF4AA469)),
                      minimumSize: MaterialStateProperty.all(const Size(120, 40)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      )),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Forget()),
                      );
                    },
                    child: Text('Forgot password?', style: AppTheme.textTheme.bodyMedium),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    String? errorText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          labelStyle: AppTheme.textTheme.bodyMedium,
        ),
        style: AppTheme.textTheme.bodyLarge,
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your $label';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _usernameError = null;
      _passwordError = null;
    });

    if (_formKey.currentState!.validate()) {
      try {
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _usernameController.text,
          password: _passwordController.text,
        );

        final isAdmin = await _checkIfAdmin(userCredential.user);

        if (isAdmin) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => AdminPage()),
            (Route<dynamic> route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => RootPage()),
            (Route<dynamic> route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        _handleAuthException(e);
      } catch (e) {
        _showSnackbar('An unexpected error occurred: $e.');
      }
    }
  }

  Future<bool> _checkIfAdmin(User? user) async {
    if (user == null) {
      return false;
    }

    try {
      final snapshot = await FirebaseFirestore.instance.collection('userdata').doc(user.uid).get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return data['isAdmin'] ?? false;
      }
    } catch (e) {
      _showSnackbar("Error checking admin status: $e");
    }

    return false;
  }

  void _handleAuthException(FirebaseAuthException e) {
    String errorMessage;
    if (e.code == 'user-not-found') {
      errorMessage = 'No user found for that email.';
    } else if (e.code == 'wrong-password') {
      errorMessage = 'Incorrect password. Please try again.';
    } else {
      errorMessage = 'An unexpected error occurred: ${e.message}.';
    }

    setState(() {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        _usernameError = errorMessage;
        _passwordError = errorMessage;
      } else {
        _showSnackbar(errorMessage);
      }
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.fixed,
        elevation: 10,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
