import 'package:flutter/material.dart';
import 'package:elites_certificate/Mentorpages/mentorbody.dart';
import 'package:elites_certificate/Mentorpages/viewandapprove.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elites_certificate/signin/loginpage.dart';
import 'package:flutter/services.dart';

class MentorHomePage extends StatefulWidget {
  const MentorHomePage({Key? key}) : super(key: key);

  @override
  State<MentorHomePage> createState() => _MentorHomePageState();
}

class _MentorHomePageState extends State<MentorHomePage> {
  int _selectedIndex = 0;
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

  final List<Widget> _pages = [
    Mentorbody(),
    ViewAndApprove(),
  ];

  // Function to switch between tabs
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
            color: const Color.fromRGBO(
                46, 49, 146, 38), // Use a suitable icon for logout
            onPressed: () {
              _handleLogout(); // Call the function to handle logout
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_outlined),
            label: 'Approval',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Call the function when a tab is tapped
      ),
    );
  }
}
