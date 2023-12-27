import 'package:flutter/material.dart';
import 'package:elites_certificate/admin/editpage/controller_editpage.dart';

class EditPage extends StatefulWidget {
  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        margin: EdgeInsets.only(bottom: 10.0),
        child: ToggleButtons(
          isSelected: [
            selectedIndex == 0,
            selectedIndex == 1,
            selectedIndex == 2, // Add button
          ],
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
                'Add User',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 4.0,
              ),
              child: Text(
                'Assign',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              // Add button
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 4.0,
              ),
              child: Text(
                'Delete  ',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          selectedColor: Colors.white,
          fillColor: const Color.fromARGB(255, 0, 42, 76),
          splashColor: const Color.fromARGB(255, 0, 42, 76),
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }
}
