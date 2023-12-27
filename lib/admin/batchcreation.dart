import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:csv/csv.dart' as csv;
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

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
      print('Attempting to pick CSV file.');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        withData: true,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        print('CSV file picked successfully.');

        // Ensure that the file content is read into memory
        PlatformFile file = result.files.first;

        await readFileContents(file);
      } else {
        print('No files selected.');
      }
    } catch (e) {
      print('Error picking CSV file: $e');
    }
  }

  Future<void> readFileContents(PlatformFile file) async {
    try {
      List<int> fileBytes = [];

      if (file.readStream != null) {
        // Read the content of the file asynchronously using ByteStream
        await for (List<int> bytesChunk in file.readStream!) {
          fileBytes.addAll(bytesChunk);
        }
      } else if (file.bytes != null) {
        // Use file.bytes directly if readStream is null
        fileBytes = file.bytes!;
      } else {
        print('Error: Both readStream and bytes are null.');
        return;
      }

      // Check for and remove the UTF-8 BOM (Byte Order Mark)
      if (fileBytes.length >= 3 &&
          fileBytes[0] == 0xEF &&
          fileBytes[1] == 0xBB &&
          fileBytes[2] == 0xBF) {
        fileBytes = fileBytes.sublist(3);
      }

      if (fileBytes.isNotEmpty) {
        setState(() {
          _selectedFile = PlatformFile(
            path: file.path,
            name: file.name,
            bytes: Uint8List.fromList(fileBytes),
            readStream: file.readStream,
            size: file.size,
          );
          _fileController.text = _selectedFile!.name;
        });

        // Add debug print for file content
        print('File Content: ${_selectedFile?.bytes}');
      } else {
        print('Error: File bytes are empty.');
      }
    } catch (e) {
      print('Error reading file content: $e');
    }
  }

  Future<List<Map<String, dynamic>>?> readCSVFile() async {
    if (_selectedFile?.bytes?.isEmpty ?? true) {
      print("Error: Selected file is empty or null.");
      return null;
    }

    try {
      final String csvString = String.fromCharCodes(_selectedFile!.bytes!);
      print('CSV Content: $csvString');

      final List<List<dynamic>> csvTable =
          csv.CsvToListConverter().convert(csvString);

      if (csvTable.isEmpty) {
        print('Error: CSV table is empty.');
        return null;
      }

      final List<Map<String, dynamic>> userList = [];

      // Assuming the first row is the header
      final headers = csvTable[0].map((e) => e.toString().trim()).toList();
      print(headers);

      for (int i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        if (row.length != headers.length) {
          print(
              'Error: Number of columns in row $i does not match the number of headers.');
          continue; // Skip this row
        }

        final userMap = Map.fromIterables(
          headers,
          row.map((e) => e.toString().trim()),
        );

        // Replace 'email' with the correct column name
        final studentEmail = userMap['email'] ?? '';
        print('Student Email: $studentEmail');

        userList.add(userMap);
      }

      return userList;
    } catch (e) {
      print('Error reading CSV file: $e');
      return null;
    }
  }

  Future<void> createUsersInFirebase() async {
    final List<Map<String, dynamic>>? users = await readCSVFile();
    final batchName = _batchNameController.text;

    if (users != null && users.isNotEmpty) {
      try {
        final batchReference = _firestore.batch();
        print(users);

        // Create the batch document with the batch name as the document ID
        final batchDocRef = _firestore.collection('batches').doc(batchName);
        final storage = firebase_storage.FirebaseStorage.instance;

        // Create a reference to the batch folder in Firebase Storage
        final batchStorageRef = storage.ref().child('$batchName');

        // Add batch details to the batch document
        batchReference.set(batchDocRef, {
          'batchName': batchName,
          // Add other batch details as needed
        });

        for (final i in users) {
          print("navi is a S class developer");
          final email = i['email'] ?? '';
          final studentStorageRef = batchStorageRef.child('${email}');
          String content =
              await rootBundle.loadString('images/placeholder.txt');

          print(content);

          // Convert the string content to bytes before uploading
          List<int> bytes = content.codeUnits;

          try {
            // Use putData instead of putFile
            await studentStorageRef.putData(Uint8List.fromList(bytes));
          } catch (e) {
            print("Something occurred: $e");
          }
        }

        for (final user in users) {
          final studentEmail = user['email'] ?? '';
          final studentPassword = user['password'] ?? '';
          final mentorName = user['mentor'] ?? '';
          final mentorEmail =
              user['mentor_email'] ?? ''; // Get mentor email from the userMap

          print('Student Email: $studentEmail');
          print('Mentor Name: $mentorName');
          print('Mentor Email: $mentorEmail');

          final studentCredential = await _auth.createUserWithEmailAndPassword(
            email: studentEmail,
            password: studentPassword,
          );

          if (studentCredential.user != null) {
            final studentRef = batchDocRef
                .collection('students')
                .doc(studentCredential.user!.email);

            batchReference.set(studentRef, {
              'email': studentEmail,
              'batchName': batchName,
            });

            if (mentorName.isNotEmpty) {
              final mentorRef =
                  batchDocRef.collection('mentors').doc(mentorName);

              // Check if mentor document exists before updating
              final mentorDoc = await mentorRef.get();

              if (mentorDoc.exists) {
                batchReference.update(mentorRef, {
                  'students':
                      FieldValue.arrayUnion([studentCredential.user!.email]),
                  'email':
                      mentorEmail, // Store mentor email in the mentor document
                });
              } else {
                // Mentor document does not exist, create a new mentor
                await batchDocRef.collection('mentors').doc(mentorName).set({
                  'students': [studentCredential.user!.email],
                  'email':
                      mentorEmail, // Store mentor email in the mentor document
                });
              }
            }
          } else {
            print('Error: Student credential is null.');
          }
        }

        // Commit the batch transaction
        await batchReference.commit();
        print('Batch committed successfully.');
      } catch (e, stackTrace) {
        print('Error creating user: $e');
        print(stackTrace);
      }
    } else {
      print("No users found or error in creating users");
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
