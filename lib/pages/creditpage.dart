import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class Tag {
  final String name;
  final int points;

  Tag({required this.name, required this.points});
}

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

class CreditPage extends StatefulWidget {
  const CreditPage({Key? key, required this.file}) : super(key: key);
  final File file;

  @override
  State<CreditPage> createState() => _CreditPageState();
}

class _CreditPageState extends State<CreditPage> {
  TextEditingController _creditController = TextEditingController();
  List<String> selectedTags = [];
  bool isUploading = false;
  void uploadfile() {
    int points = calculateTotalPoints(); // Add this line
    uploadFileToFirestore(widget.file, points, selectedTags).then((_) {});
  }

  Future<void> uploadFileToFirestore(
      File file, int points, List<String> selectedTags) async {
    try {
      final String? batchId = await findBatchIdForCurrentUser();
      print(batchId);
      final User? user = FirebaseAuth.instance.currentUser;

      if (batchId != null && user != null) {
        setState(() {
          isUploading = true;
        });

        await uploadFile(batchId, user.email!, file, points, selectedTags);
      } else {
        _showSnackBar("Error getting batch information", "red");
      }
    } catch (e) {
      print("Error: $e");
      _showSnackBar("Error uploading file. Please try again.", "red");
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<String?> findBatchIdForCurrentUser() async {
    String? batchId;

    try {
      // Get the current user from Firebase Authentication
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Reference to the 'batches' collection
        CollectionReference<Map<String, dynamic>> batchesCollection =
            FirebaseFirestore.instance.collection('batches');

        // Query for the 'students' sub-collection of each batch
        QuerySnapshot<Map<String, dynamic>> batchesQuerySnapshot =
            await batchesCollection.get();

        // Iterate through batch documents
        for (QueryDocumentSnapshot<Map<String, dynamic>> batchDocument
            in batchesQuerySnapshot.docs) {
          // Reference to the 'students' sub-collection of the current batch
          CollectionReference<Map<String, dynamic>> studentsCollection =
              batchDocument.reference.collection('students');

          // Query for the document with ID matching the user's email
          DocumentSnapshot<Map<String, dynamic>> studentDocumentSnapshot =
              await studentsCollection.doc(user.email).get();

          // Check if the document exists in the 'students' sub-collection
          if (studentDocumentSnapshot.exists) {
            batchId = batchDocument.id;
            break; // Exit the loop once a match is found
          }
        }
      }
    } catch (e) {
      print("Error: $e");
    }

    return batchId;
  }

  Future<void> uploadFile(String batchId, String userEmail, File file,
      int points, List<String> tags) async {
    if (FirebaseAuth.instance.currentUser != null) {
      print("User is authenticated.");

      try {
        bool batchExists = await batchFolderExists(batchId);
        print(batchExists);

        if (batchExists) {
          bool userExists = await userFolderExists(batchId, userEmail);

          if (userExists) {
            final String timestamp =
                DateTime.now().millisecondsSinceEpoch.toString();
            final String fileName = "${file.path.split('/').last}_$timestamp";

            final firebase_storage.Reference storageRef = firebase_storage
                .FirebaseStorage.instance
                .ref(batchId)
                .child(userEmail)
                .child(fileName);

            final metadata = firebase_storage.SettableMetadata(
                contentType: 'application/pdf',
                customMetadata: {'picked-file-path': file.path});

            print("Uploading...!");
            final uploadTask = storageRef.putFile(file, metadata);
            await uploadTask;
            print("Upload complete!");

            final downloadURL = await storageRef.getDownloadURL();
            print("hello world");
            print(batchId);
            print(userEmail);
            final studentsRef = FirebaseFirestore.instance
                .collection('batches')
                .doc(batchId)
                .collection('students')
                .doc(userEmail);
            print("hello${studentsRef}");
            // Get the current array of files from Firestore
            final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
                await studentsRef.get();
            final List<dynamic>? existingFiles =
                documentSnapshot.data()?['files'];

            // Create a new array with the existing files and the new file metadata
            final List<Map<String, dynamic>> updatedFiles = [
              ...?existingFiles,
              {
                'name': file.path.split('/').last,
                'downloadURL': downloadURL,
                'uploadedAt': DateTime.now(),
                'points': points,
                'tags': tags,
                'state': 'pending',
                'email': userEmail,
              },
            ];

            // Update the 'files' array in Firestore
            await studentsRef.update({'files': updatedFiles});

            _showSnackBar(
                "File Uploaded. Batch and user folders exist.", "green");
            Navigator.pop(context);
          } else {
            _showSnackBar("Cannot upload file. User folder not found.", "red");
          }
        } else {
          _showSnackBar("Cannot upload file. Batch folder not found.", "red");
        }
      } catch (e) {
        print("Error: $e");
        _showSnackBar("Error uploading file. Please try again.", "red");
      }
    } else {
      print("User is not authenticated. Unable to upload file.");
    }
  }

  Future<bool> batchFolderExists(String year) async {
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref(year)
          .child('/')
          .listAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> userFolderExists(String year, String userEmail) async {
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref(year)
          .child(userEmail)
          .child('/')
          .listAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  void _showSnackBar(String message, String color) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
      backgroundColor: getColorFromName(
          color), // Use a function to get color from the color name
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Color getColorFromName(String colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      // Add more cases for other colors if needed
      default:
        return Colors.black; // Default color if the name is not recognized
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          backgroundColor: Colors.white,
          title: Container(
            width: 100, // Set your desired width
            height: 100, // Set your desired height
            child: Image.asset("images/logo.jpg"),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          ' Add Credit Tags',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            _creditController.text,
                            style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Total Points',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Selected Tags:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    selectedTags.isEmpty
                        ? Center(
                            child: Text(
                              'No tags selected',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
                        : Wrap(
                            spacing: 8.0,
                            children: selectedTags.map((tag) {
                              return Chip(
                                label: Text(tag),
                                deleteIcon: Icon(Icons.cancel),
                                onDeleted: () {
                                  setState(() {
                                    selectedTags.remove(tag);
                                  });
                                  // Update total points when a tag is removed
                                  _updateTotalPoints();
                                },
                              );
                            }).toList(),
                          ),
                    SizedBox(height: 30),
                    Text(
                      'Credit Tags:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    FutureBuilder<List<Tag>>(
                      future: fetchTagsFromFirestore(),
                      builder: (context, AsyncSnapshot<List<Tag>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Container(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          return Text('No data available');
                        } else {
                          List<Tag> tags = snapshot.data!;

                          List<Widget> cards = [];

                          tags.forEach((tag) {
                            cards.add(GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (!selectedTags.contains(tag.name)) {
                                    selectedTags.add(tag.name);
                                  }
                                  // Update total points when a tag is added
                                  _updateTotalPoints();
                                });
                              },
                              child: Card(
                                child: ListTile(
                                  title: Text(
                                    tag.name,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Points: ${tag.points}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ));
                          });

                          return Column(children: cards);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (isUploading)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color.fromARGB(255, 1, 40, 72),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Uploading...',
                        style: TextStyle(
                          color: Color.fromARGB(255, 1, 40, 72),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 56.0,
            child: ElevatedButton(
              onPressed: () {
                uploadfile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(
                    255, 0, 7, 136), // Set your desired color here
              ),
              child: Text(
                'Upload',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        ));
  }

  void _updateTotalPoints() {
    _creditController.text = calculateTotalPoints().toString();
  }

  int calculateTotalPoints() {
    return selectedTags.fold<int>(0, (int sum, String tagName) {
      Tag? selectedTag = fetchTagByName(tagName);

      if (selectedTag != null) {
        return sum + selectedTag.points;
      } else {
        return sum;
      }
    });
  }

  Tag? fetchTagByName(String tagName) {
    List<Tag> tags = fetchedTags;

    Tag? selectedTag = tags.firstWhereOrNull((tag) => tag.name == tagName);
    return selectedTag;
  }

  List<Tag> fetchedTags = [];

  Future<List<Tag>> fetchTagsFromFirestore() async {
    CollectionReference batches =
        FirebaseFirestore.instance.collection('creditpoints');
    List<Tag> tags = [];

    try {
      DocumentSnapshot doc = await batches.doc('creditpoints').get();

      if (doc.exists) {
        Map<String, dynamic> tagsMap =
            (doc.data() as Map<String, dynamic>?)?['tags'] ?? {};

        print('Received Tags Map: $tagsMap');

        tagsMap.forEach((tagName, points) {
          tags.add(Tag(name: tagName, points: points));
        });

        fetchedTags = tags;
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching tags: $e');
    }

    return tags;
  }
}
