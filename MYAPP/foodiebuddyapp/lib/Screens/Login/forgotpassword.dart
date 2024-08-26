import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodiebuddyapp/Screens/Login/loginpage.dart';
import 'package:foodiebuddyapp/theme.dart';

class Forget extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<Forget> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String _errorMessage = '';
  final _formKey = GlobalKey<FormState>();

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firebaseAuth.sendPasswordResetEmail(email: _emailController.text);
        setState(() {
          _errorMessage = 'Password reset email sent!';
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyLoginPage()),
        );
      } on FirebaseException catch (e) {
        setState(() {
          _errorMessage = e.message ?? 'A Firebase exception occurred.';
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred: ${e.toString()}';
        });
        print(e); // For debugging purposes
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFC9EFC6),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20.0),
                    Column(
                      children: [
                        Text(
                          'RESET PASSWORD',
                          style: AppTheme.textTheme.displayLarge,
                        ),
                        const SizedBox(height: 10.0),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: AppTheme.textTheme.bodyMedium,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            style: AppTheme.textTheme.bodyLarge,
                          ),
                        ),
                        TextButton(
                          onPressed: _resetPassword,
                          child: Text(
                            'Reset Password?',
                            style: AppTheme.textTheme.bodyLarge?.copyWith(color: Colors.black),
                          ),
                        ),
                        if (_errorMessage.isNotEmpty)
                          Text(
                            _errorMessage,
                            style: AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}