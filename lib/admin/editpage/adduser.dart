import 'package:flutter/material.dart';

class AddingUsers extends StatefulWidget {
  const AddingUsers({Key? key}) : super(key: key);

  @override
  State<AddingUsers> createState() => _AddingUsersState();
}

class _AddingUsersState extends State<AddingUsers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Creation', style: TextStyle(fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Individual User Creation', style: TextStyle(fontSize: 18)),
            _buildIndividualUserSection(),
            SizedBox(height: 20),
            Text('Multiple User Creation', style: TextStyle(fontSize: 18)),
            _buildMultipleUserSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualUserSection() {
    // Implement the UI for individual user creation here
    return Column(
      children: [
        // Add widgets for email and password input fields
        TextField(
          decoration: InputDecoration(labelText: 'Email'),
        ),
        TextField(
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        // Add a button to trigger individual user creation
        ElevatedButton(
          onPressed: () {
            // Implement the logic for individual user creation
          },
          child: Text('Create Individual User'),
        ),
      ],
    );
  }

  Widget _buildMultipleUserSection() {
    // Implement the UI for multiple user creation here
    return Column(
      children: [
        // Add a button to trigger CSV file upload
        ElevatedButton(
          onPressed: () {
            // Implement the logic for CSV file upload
          },
          child: Text('Upload CSV File'),
        ),
        // Add a button to trigger multiple user creation
        ElevatedButton(
          onPressed: () {
            // Implement the logic for multiple user creation
          },
          child: Text('Create Multiple Users'),
        ),
      ],
    );
  }
}
