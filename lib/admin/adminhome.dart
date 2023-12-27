// import 'package:elites_certificate/admin/pointdistribution.dart';
import 'package:flutter/material.dart';
import 'body_admin_home.dart';
import 'package:elites_certificate/admin/editpage/main_edit_page.dart';
import 'package:elites_certificate/features/tagcreator.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0; // Index for the selected tab

  // Define the pages or content for each tab
  final List<Widget> _pages = [AdminHome(), EditPage(), TagCreatorPage()];

  // Function to switch between tabs
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          width: 100, // Set your desired width
          height: 100, // Set your desired height
          child: Image.asset("images/logo.jpg"),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            color: const Color.fromARGB(
                255, 1, 22, 40), // Use a suitable icon for logout
            onPressed: () {
              // _handleLogout(); // Call the function to handle logout
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
            icon: Icon(Icons.edit),
            label: 'Batch edit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Call the function when a tab is tapped
      ),
    );
  }
}
