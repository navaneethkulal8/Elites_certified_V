import 'package:elites_certificate/pages/creditpage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'certificate_builder.dart';
// import 'package:elites_certificate/features/tagspage.dart';

class BodyCertificate extends StatefulWidget {
  @override
  _BodyCertificateState createState() => _BodyCertificateState();
}

class _BodyCertificateState extends State<BodyCertificate> {
  List<String> fileUrls = [];
  List<Map<String, dynamic>> fetchedData = [];
  bool _isMounted = false;
  List<Map<String, dynamic>> displayedData = [];
  TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  StreamSubscription<DocumentSnapshot>? _subscription;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _isMounted = true;
    _subscribeToFirebaseChanges();
    displayedData = List.from(fetchedData);
  }

  @override
  void dispose() {
    super.dispose();
    _isMounted = false;
    _subscription?.cancel();
  }

  void _subscribeToFirebaseChanges() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final currentUserId = user.email;
      final batchesCollectionPath = 'batches';

      final batchesCollection =
          FirebaseFirestore.instance.collection(batchesCollectionPath);

      QuerySnapshot batchesDocsSnapshot = await batchesCollection.get();

      batchesDocsSnapshot.docs.forEach((DocumentSnapshot batchDoc) async {
        final studentsCollectionPath = '${batchDoc.reference.path}/students';

        final studentsCollection =
            FirebaseFirestore.instance.collection(studentsCollectionPath);

        QuerySnapshot userDocsSnapshot = await studentsCollection
            .where('email', isEqualTo: currentUserId)
            .get();

        userDocsSnapshot.docs.forEach((DocumentSnapshot studentDoc) {
          final userFilesPath = '$studentsCollectionPath/${studentDoc.id}';

          _subscription = FirebaseFirestore.instance
              .doc(userFilesPath)
              .snapshots()
              .listen((DocumentSnapshot snapshot) {
            if (snapshot.exists) {
              final List<dynamic>? filesArray = snapshot['files'];

              if (filesArray != null) {
                final List<String> newFileUrls = filesArray
                    .map((files) => files['downloadURL'] as String)
                    .toList();

                final List<Map<String, dynamic>> newData =
                    filesArray.map((files) {
                  final timestamp = files['uploadedAt'] as Timestamp;
                  final uploadedAtDate = timestamp.toDate();
                  final formattedDate =
                      "${uploadedAtDate.day}-${uploadedAtDate.month}-${uploadedAtDate.year}";

                  return {
                    'name': files['name'],
                    'downloadURL': files['downloadURL'],
                    'uploadedAt': formattedDate,
                    'points': files['points'],
                    'tags': files['tags'],
                    'state': files['state'],
                  };
                }).toList();

                if (_isMounted) {
                  setState(() {
                    fetchedData = newData;
                    fileUrls = newFileUrls;
                  });
                }
              } else {
                print('No "files" field in the document');
              }
            }
          });
        });
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      print('Attempting to pick pdf file.');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        withData: true,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        File file = File(result.files.single.path!);

        if (await file.exists()) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreditPage(
                file: file,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("File not found")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please Pick a File")),
        );
        print('File picking canceled.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Some Error Occurred. Please Try Again")),
      );
      print('Error picking Pdf file: $e');
    }
  }

  void _onSearchTextChanged(String searchText) {
    setState(() {
      displayedData = fetchedData
          .where((certificate) => certificate['name']
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 2.0,
                      left: 4.0,
                      right: 4.0,
                    ),
                    child: Container(
                      width: 100, // Set your desired width
                      height: 50, // Set your desired height
                      child: Image.asset("images/logo.jpg"),
                    ),
                  ),
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                          top: 8.0,
                          bottom: 8.0,
                          left: 8.0,
                          right: 8.0,
                        ),
                        child: Text(
                          'Your Certificates',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00233F),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Container(
                        width: 45,
                        height: 45,
                        child: Image.asset("images/badge.jpg"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: SearchBarDelegate(
              controller: searchController,
              onTextChanged: _onSearchTextChanged,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(
                      top: 4.0, bottom: 4.0, left: 8.0, right: 8.0),
                  child: CertificateItem(
                    name: fetchedData[index]['name'],
                    downloadURL: fetchedData[index]['downloadURL'],
                    uploadedAt: fetchedData[index]['uploadedAt'],
                    points: fetchedData[index]['points'],
                    tags: fetchedData[index]['tags'],
                    state: fetchedData[index]['state'],
                    highlightText: searchController.text,
                    scrollController: _scrollController,
                    index: index,
                  ),
                );
              },
              childCount: fetchedData.length,
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () async {
            await _pickFile();
          },
          backgroundColor: const Color.fromARGB(255, 1, 40, 72),
          child: const Icon(
            Icons.add,
            size: 36.0,
            color: Colors.amber,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final Function(String) onTextChanged;
  SearchBarDelegate({required this.controller, required this.onTextChanged});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: TextField(
          controller: controller,
          onChanged: onTextChanged,
          style: TextStyle(fontFamily: "Roboto-BoldItalic"),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            hintText: 'Search...',
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 70.0;

  @override
  double get minExtent => 70.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
