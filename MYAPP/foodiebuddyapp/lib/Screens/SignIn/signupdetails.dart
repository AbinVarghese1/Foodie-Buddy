import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodiebuddyapp/Screens/Login/loginpage.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
 

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  String? _gender;
  String? _userNameError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC9EFC6),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Create an account',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  hintText: 'User name',
                  controller: _userNameController,
                  icon: Icons.account_circle,
                  errorText: _userNameError,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  hintText: 'Email',
                  controller: _emailController,
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  hintText: 'Profession',
                  controller: _professionController,
                  icon: Icons.work,
                ),
                const SizedBox(height: 20),
                _buildDropdownField(
                  hintText: 'Gender',
                  value: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value as String?;
                    });
                  },
                  items: ['Male', 'Female'],
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  hintText: 'Date of Birth',
                  controller: _dateOfBirthController,
                  keyboardType: TextInputType.datetime,
                  icon: Icons.calendar_today,
                  onTap: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (selectedDate != null) {
                      String formattedDate = dateFormat.format(selectedDate);
                      _dateOfBirthController.text = formattedDate;
                    }
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  hintText: 'Password',
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  icon: Icons.lock,
                  isObscure: true,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  hintText: 'Confirm Password',
                  controller: _confirmPasswordController,
                  keyboardType: TextInputType.visiblePassword,
                  icon: Icons.lock,
                  isObscure: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C985A),
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    bool isObscure = false,
    String? errorText,
    Function()? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            cursorColor: Colors.black,
            obscureText: isObscure,
            onTap: onTap,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Colors.black,
              ),
              icon: icon != null
                  ? Icon(
                      icon,
                      color: Colors.black,
                    )
                  : null,
              errorText: errorText,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $hintText';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String hintText,
    required String? value,
    required Function(dynamic) onChanged,
    required List<String> items,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon,
              color: Colors.black,
            ),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              icon: Container(),
              onChanged: (newValue) {
                setState(() {
                  _gender = newValue;
                });
                onChanged(newValue);
              },
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Colors.black,
                ),
                contentPadding: EdgeInsets.only(left: icon != null ? 10 : 0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select $hintText';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signUp() async {
    if (_formkey.currentState!.validate()) {
      // All fields are valid, proceed with sign-up
      try {
        // Check if passwords match
        if (_passwordController.text != _confirmPasswordController.text) {
          _showErrorSnackbar('Passwords do not match');
          return;
        }

        // Check if email already exists
        final QuerySnapshot emailQuery = await FirebaseFirestore.instance
            .collection('userdata')
            .where('email', isEqualTo: _emailController.text)
            .get();
        if (emailQuery.docs.isNotEmpty) {
          _showErrorSnackbar('Email already exists');
          return;
        }

        // Check if date is valid
        final DateTime? parsedDateOfBirth = dateFormat.parse(_dateOfBirthController.text);
        if (parsedDateOfBirth == null) {
          _showErrorSnackbar('Invalid date format');
          return;
        }

        // Check if username already exists
        final QuerySnapshot userNameQuery = await FirebaseFirestore.instance
            .collection('userdata')
            .where('username', isEqualTo: _userNameController.text)
            .get();
        if (userNameQuery.docs.isNotEmpty) {
          setState(() {
            _userNameError = 'Username already exists';
          });
          _showErrorSnackbar(_userNameError!);
          return;
        }

        // Proceed with sign-up
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Save user data
        await FirebaseFirestore.instance
            .collection('userdata')
            .doc(userCredential.user!.uid)
            .set({
          'username': _userNameController.text,
          'email': _emailController.text,
          'profession': _professionController.text,
          'date_of_birth': _dateOfBirthController.text,
          'gender': _gender,
        });

        // Clear form fields
        _userNameController.clear();
        _emailController.clear();
        _professionController.clear();
        _dateOfBirthController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up successful'),
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          ),
        );

        setState(() {
          _gender = null;
          _userNameError = null;
        });

        // Navigate to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyLoginPage()),
        );
      } catch (e) {
        print('Failed to sign up: $e');
        _showErrorSnackbar('Failed to sign up: $e');
      }
    } else {
      _showErrorSnackbar('Please fill in all fields');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }
}
