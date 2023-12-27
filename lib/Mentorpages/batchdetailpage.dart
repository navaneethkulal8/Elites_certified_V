import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homepagestudentcert.dart';

class BatchDetailPage extends StatefulWidget {
  final String batchTitle;

  BatchDetailPage(this.batchTitle);

  @override
  State<BatchDetailPage> createState() => _BatchDetailPageState();
}

class _BatchDetailPageState extends State<BatchDetailPage> {
  late User? _user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
    });
  }

  Future<Map<String, List<dynamic>>> _getStudentsData() async {
    Map<String, List<dynamic>> studentsData = {};

    if (_user != null) {
      try {
        QuerySnapshot batchQuerySnapshot = await _firestore
            .collection('batches')
            .doc(widget.batchTitle)
            .collection('mentors')
            .where('email', isEqualTo: _user!.email)
            .get();

        print(
            'Batch Query Successful: ${batchQuerySnapshot.docs.length} mentors found');

        for (QueryDocumentSnapshot mentorDocument in batchQuerySnapshot.docs) {
          List<dynamic> studentsArray =
              List.from(mentorDocument['students'] ?? []);
          for (String studentEmail in studentsArray) {
            DocumentReference studentRef = _firestore
                .collection('batches')
                .doc(widget.batchTitle)
                .collection('students')
                .doc(studentEmail);

            // Now you can use the `reference` property on the DocumentReference
            List<dynamic> filesArray = await getCertificatesData(studentRef);

            studentsData[studentEmail] = filesArray;
          }
        }
      } catch (e) {
        print('Error getting students data: $e');
      }
    }

    return studentsData;
  }

  Future<List<dynamic>> getCertificatesData(
      DocumentReference mentorDocument) async {
    List<dynamic> certificatesData = [];

    try {
      DocumentSnapshot studentSnapshot = await mentorDocument.get();

      if (studentSnapshot.exists) {
        Map<String, dynamic>? studentData =
            studentSnapshot.data() as Map<String, dynamic>?;

        if (studentData != null && studentData.containsKey('files')) {
          certificatesData = List.from(studentData['files']);
        }

        print("${certificatesData}");
      }
    } catch (e) {
      print('Error getting certificates data: $e');
    }

    return certificatesData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(218, 2, 6, 139),
        title: Text("Batch"),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, List<dynamic>>>(
          future: _getStudentsData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              Map<String, List<dynamic>> studentsData = snapshot.data ?? {};
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Certificates of Batch:",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "${widget.batchTitle}",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Divider(
                        height: 10,
                        color: const Color.fromRGBO(46, 49, 146, 38),
                      ),
                    ),
                    for (var entry in studentsData.entries)
                      _buildStudentCard(entry.key, entry.value),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildStudentCard(String studentEmail, List<dynamic> filesArray) {
    List<dynamic> approvedCertificates = filesArray
        .where((certificate) => certificate['state'] == 'Approved')
        .toList();
    num totalPoints = 0;

    // Calculate total points
    for (var certificate in approvedCertificates) {
      totalPoints += certificate['points'] ?? 0;
    }
    return Container(
      height: 120,
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomepageStudentCertificate(
                email: studentEmail,
                filesArray: filesArray,
              ),
            ),
          );
        },
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$studentEmail",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Certificates: ${approvedCertificates.length}",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Total Points: ${totalPoints}",
                        style: TextStyle(fontSize: 16),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                Positioned(
                  top: 25,
                  right: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "View",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.remove_red_eye, size: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
