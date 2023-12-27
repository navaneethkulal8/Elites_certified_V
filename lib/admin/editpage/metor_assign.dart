import 'package:flutter/material.dart';

class MentorAssign extends StatefulWidget {
  const MentorAssign({super.key});

  @override
  State<MentorAssign> createState() => _MentorAssignState();
}

class _MentorAssignState extends State<MentorAssign> {
  String? selectedBatch;
  List<String> batches = ['Batch 1', 'Batch 2', 'Batch 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Batch Name: ',
                      style: TextStyle(
                          fontFamily: "Roboto-Black.ttf",
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: selectedBatch,
                      items: batches.map((String batch) {
                        return DropdownMenuItem<String>(
                          value: batch,
                          child: Text(batch),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedBatch = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unassigned Students:',
                        style: TextStyle(
                            fontFamily: "Roboto-Black.ttf",
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Container(
                        color: Colors.grey.shade200,
                        height: 200.0,
                        child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return Card(
                                // Your card content here
                                );
                          },
                        ),
                      ),
                    ],
                  )),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle the assignment logic when the button is pressed
                  },
                  child: Text('Assign'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
