import 'package:elites_certificate/Mentorpages/mentorhome.dart';
import 'package:elites_certificate/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StyledTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType inputType;
  final Key? fieldKey;
  final bool isPasswordField;
  final Function(String?) onSaved;
  final String? Function(String?)? validator;
  final Function(String)? onFieldSubmitted;
  final String hintText;

  StyledTextField({
    required this.controller,
    required this.inputType,
    this.fieldKey,
    required this.isPasswordField,
    required this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    required this.hintText,
  });

  @override
  _StyledTextFieldState createState() => _StyledTextFieldState();
}

class _StyledTextFieldState extends State<StyledTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(.35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        style: TextStyle(color: Colors.black),
        controller: widget.controller,
        keyboardType: widget.inputType,
        key: widget.fieldKey,
        obscureText: widget.isPasswordField == true ? _obscureText : false,
        onSaved: widget.onSaved,
        validator: widget.validator,
        onFieldSubmitted: widget.onFieldSubmitted,
        decoration: InputDecoration(
          border: InputBorder.none,
          filled: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.black45),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            child: widget.isPasswordField == true
                ? Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: _obscureText == false
                        ? Color.fromARGB(255, 0, 0, 131)
                        : Colors.grey,
                  )
                : Text(""),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          width: 100, // Set your desired width
          height: 100, // Set your desired height
          child: Image.asset("images/logo.jpg"),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "images/loginlogo.png",
                width: 150, // Set your desired width
                height: 150, // Set your desired height
              ),
              SizedBox(height: 20),
              Text(
                "Login",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              StyledTextField(
                controller: emailController,
                inputType: TextInputType.emailAddress,
                isPasswordField: false,
                onSaved: (value) {},
                validator: (value) {
                  return null;
                },
                onFieldSubmitted: (value) {},
                hintText: 'Email',
              ),
              SizedBox(height: 16.0),
              StyledTextField(
                controller: passwordController,
                inputType: TextInputType.visiblePassword,
                isPasswordField: true,
                onSaved: (value) {},
                validator: (value) {
                  return null;
                },
                onFieldSubmitted: (value) {},
                hintText: 'Password',
              ),
              SizedBox(height: 32.0),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: passwordController.text,
                      );

                      // Check the email and navigate to the appropriate page
                      String email = emailController.text.trim().toLowerCase();
                      if (email.endsWith('@nitte.edu.in')) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MentorHomePage()),
                        );
                      } else if (email.endsWith('@nmamit.in')) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        );
                      } else {
                        // Handle invalid email
                        showSnackBar(context, 'Invalid email');
                      }
                    } catch (e) {
                      print("Error: $e");
                      // Handle authentication error
                      showSnackBar(
                          context, 'Authentication failed : Invalid password');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(
                        255, 6, 0, 126), // Set your desired color here
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}
