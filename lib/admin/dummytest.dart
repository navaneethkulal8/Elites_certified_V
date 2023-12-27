import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:csv/csv.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BatchCreation extends StatefulWidget {
  const BatchCreation({Key? key});

  @override
  State<BatchCreation> createState() => _BatchCreationState();
}

class _BatchCreationState extends State<BatchCreation> {
  final TextEditingController _batchNameController = TextEditingController();
  final TextEditingController _fileController = TextEditingController();
  PlatformFile? _selectedFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fileController.text = 'No file selected';
  }

  Future<void> _pickCSVFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
          _fileController.text = _selectedFile!.name;
        });
      }
    } catch (e) {
      print('Error picking CSV file: $e');
    }
  }

  Future<List<Map<String, dynamic>>?> readCSVFile() async {
    if (_selectedFile == null) {
      // Display an error message or return early
      return null;
    }

    final String csvString = String.fromCharCodes(_selectedFile!.bytes!);
    final List<List<dynamic>> csvTable =
        CsvToListConverter().convert(csvString);

    if (csvTable.isEmpty) return null;

    final headers = csvTable[0].map((e) => e.toString()).toList();
    final List<Map<String, dynamic>> userList = [];

    for (int i = 1; i < csvTable.length; i++) {
      final userMap =
          Map.fromIterables(headers, csvTable[i].map((e) => e.toString()));
      userList.add(userMap);
    }

    return userList;
  }

  Future<void> createUsersInFirebase() async {
    if (_selectedFile == null) {
      // Display an error message or return early
      return;
    }

    final batchName = _batchNameController.text;
    final List<Map<String, dynamic>>? users = await readCSVFile();

    if (users != null) {
      try {
        // Create a batch reference
        final batchReference = _firestore.batch();

        for (final user in users) {
          final studentEmail = user['studentemail'];
          final studentPassword = user['studentpassword'];
          final mentorEmail = user['mentor'];

          // Create student account
          final studentCredential = await _auth.createUserWithEmailAndPassword(
            email: studentEmail,
            password: studentPassword,
          );

          // Add student data to batch
          final studentRef = _firestore
              .collection('batches')
              .doc(batchName)
              .collection('students')
              .doc(studentCredential.user!.uid);
          batchReference.set(studentRef, {'email': studentEmail});

          if (mentorEmail.isNotEmpty) {
            // Student has a mentor
            final mentorRef = _firestore
                .collection('batches')
                .doc(batchName)
                .collection('mentors')
                .doc(mentorEmail);

            // Add student to mentor's list
            batchReference.update(mentorRef, {
              'students': FieldValue.arrayUnion([studentCredential.user!.uid]),
            });
          }
        }

        // Commit the batch
        await batchReference.commit();
      } catch (e) {
        print('Error creating user: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Batch Creation'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _batchNameController,
              decoration: InputDecoration(
                labelText: 'Batch Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _fileController,
                    readOnly: true,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Container(
                padding: EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  onPressed: _pickCSVFile,
                  child: Text('Select CSV File'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 21, 2, 128),
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: createUsersInFirebase,
            child: Text(
              'Create Batch',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Color.fromARGB(255, 21, 2, 128),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
