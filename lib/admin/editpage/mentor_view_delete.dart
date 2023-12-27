import 'package:flutter/material.dart';

class MentorViewDelete extends StatefulWidget {
  const MentorViewDelete({super.key});

  @override
  State<MentorViewDelete> createState() => _BatchEditState();
}

class _BatchEditState extends State<MentorViewDelete> {
  // Define a list of items for the dropdown menu
  List<String> batchOptions = ['Batch 2024', 'Batch 2025', 'Batch 2026'];
  String selectedBatch = 'Batch 2024';

  // Define a list of mentor options
  List<String> mentorOptions = ['Mentor 1', 'Mentor 2', 'Mentor 3'];
  String selectedMentor = 'Mentor 1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Batch name
            Row(
              children: [
                Text(
                  "Batch Name:",
                  style: TextStyle(
                      fontFamily: "fonts/Roboto-Medium.ttf",
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 20),
                DropdownButton<String>(
                  value: selectedBatch,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedBatch = newValue ?? '';
                    });
                  },
                  items: batchOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            // Space to fetch data from Firebase (you can add your Firebase code here)
            SizedBox(
                height: 16.0), // Add some space between Batch name and Mentor

            // Mentor dropdown
            Row(
              children: [
                Text(
                  "Mentor:",
                  style: TextStyle(
                      fontFamily: "fonts/Roboto-Medium.ttf",
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 20),
                DropdownButton<String>(
                  value: selectedMentor,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMentor = newValue ?? '';
                    });
                  },
                  items: mentorOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            Divider(
              height: 10,
              color: Colors.amber,
            )
          ],
        ),
      ),
    );
  }
}
