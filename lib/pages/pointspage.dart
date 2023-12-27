import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class PointsTable extends StatefulWidget {
  const PointsTable({Key? key}) : super(key: key);

  @override
  _PointsTableState createState() => _PointsTableState();
}

class _PointsTableState extends State<PointsTable> {
  StreamSubscription<DocumentSnapshot>? _subscription;
  int totalPoints = 0;
  List<Map<String, dynamic>> fetchedData = [];
  List<String> fileUrls = [];
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    _subscribeToFirebaseChanges();
  }

  @override
  void dispose() {
    // Dispose of your subscription or other cleanup if needed
    _subscription?.cancel();
    super.dispose();
  }

  void calculateTotalPoints(fetchedData) {
    int calculatedTotalPoints = 0;
    fetchedData.forEach((fileData) {
      print(fileData);
      if (fileData['state'] == 'Approved') {
        calculatedTotalPoints += (fileData['points'] ?? 0) as int;
        print(calculatedTotalPoints);
      }
    });

    if (_isMounted) {
      setState(() {
        totalPoints = calculatedTotalPoints;
      });
    }
  }

  void _subscribeToFirebaseChanges() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final currentUserId = user.email;
      final batchesCollectionPath = 'batches';

      // Get a reference to the batches collection
      final batchesCollection =
          FirebaseFirestore.instance.collection(batchesCollectionPath);

      // Query for the documents with the current user's email
      QuerySnapshot batchesDocsSnapshot = await batchesCollection
          .get(); // No specific condition, fetch all documents

      // Iterate over the documents in the batches collection
      batchesDocsSnapshot.docs.forEach((DocumentSnapshot batchDoc) async {
        final studentsCollectionPath = '${batchDoc.reference.path}/students';

        // Get a reference to the students collection under the current batch
        final studentsCollection =
            FirebaseFirestore.instance.collection(studentsCollectionPath);

        // Query for the documents with the current user's email
        QuerySnapshot userDocsSnapshot = await studentsCollection
            .where('email', isEqualTo: currentUserId)
            .get();

        // Iterate over the documents in the snapshot
        userDocsSnapshot.docs.forEach((DocumentSnapshot studentDoc) {
          final userFilesPath = '$studentsCollectionPath/${studentDoc.id}';

          _subscription = FirebaseFirestore.instance
              .doc(userFilesPath)
              .snapshots()
              .listen((DocumentSnapshot snapshot) {
            if (snapshot.exists) {
              final List<dynamic> filesArray = snapshot['files'] ?? [];
              print(filesArray);

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

                // Call the function to calculate total points after updating the state
                calculateTotalPoints(fetchedData);
              }
            }
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/points.png',
                    height: 100,
                    width: 100,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Total Points',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '$totalPoints',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Text(
              "Individual Scores:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: fetchedData.length,
              itemBuilder: (context, index) {
                final file = fetchedData[index];
                if (file['state'] == 'Approved') {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Container(
                          width: 250, // Set a fixed width for the container
                          child: Text(
                            file['name'] ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                // You can add additional styles if needed
                                ),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Uploaded: ${file['uploadedAt']}',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                Text(
                                  'Points: ${file['points']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          // Handle card tap if needed
                        },
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
