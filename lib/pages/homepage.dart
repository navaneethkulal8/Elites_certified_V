import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication
import 'certificates.dart';
import 'package:elites_certificate/signin/loginpage.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0; // 0 for Certificates, 1 for Your Points
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Set the system status bar color to the default
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
      statusBarBrightness: Brightness.light,
    ));
  }

  // Function to handle the logout action with Firebase
  Future<void> _handleLogout() async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()));
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          width: 200, // Set your desired width
          height: 200, // Set your desired height
          child: Image.asset("images/nittelogo.jpg"),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            color: const Color.fromARGB(
                255, 1, 22, 40), // Use a suitable icon for logout
            onPressed: () {
              _handleLogout(); // Call the function to handle logout
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Body(
              certificatesPressed: selectedIndex == 0,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.0),
        ),
        margin: EdgeInsets.only(bottom: 20.0),
        child: ToggleButtons(
          isSelected: [selectedIndex == 0, selectedIndex == 1],
          onPressed: (int newIndex) {
            setState(() {
              selectedIndex = newIndex;
            });
            // Perform your actions based on selectedIndex
          },
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 4.0,
              ),
              child: Text(
                'Certificates',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 4.0,
              ),
              child: Text(
                'Your Points',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          selectedColor: Colors.white,
          fillColor: const Color.fromARGB(255, 1, 40, 72),
          splashColor: const Color.fromARGB(255, 1, 40, 72),
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }
}
