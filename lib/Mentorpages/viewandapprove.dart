import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'studentcertificate.dart';

class ViewAndApprove extends StatefulWidget {
  const ViewAndApprove({Key? key}) : super(key: key);

  @override
  State<ViewAndApprove> createState() => ViewAndApproveState();
}

class ViewAndApproveState extends State<ViewAndApprove> {
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
        QuerySnapshot batchQuerySnapshot =
            await _firestore.collection('batches').get();

        for (QueryDocumentSnapshot batchDocument in batchQuerySnapshot.docs) {
          CollectionReference mentorsCollection =
              batchDocument.reference.collection('mentors');
          QuerySnapshot querySnapshot = await mentorsCollection.get();

          for (QueryDocumentSnapshot mentorDocument in querySnapshot.docs) {
            String mentorEmail = mentorDocument['email'];
            if (mentorEmail == _user!.email) {
              List<dynamic> studentsArray =
                  List.from(mentorDocument['students'] ?? []);

              for (String studentEmail in studentsArray) {
                List<dynamic> filesArray = await getCertificatesData(
                    batchDocument.reference, studentEmail);

                // Filter out certificates that are not in 'pending' state
                List<dynamic> pendingFilesArray = filesArray
                    .where((certificate) => certificate['state'] == 'pending')
                    .toList();

                if (pendingFilesArray.isNotEmpty) {
                  studentsData[studentEmail] = pendingFilesArray;
                }
              }

              break;
            }
          }
        }
      } catch (e) {
        print('Error getting students data: $e');
      }
    }

    return studentsData;
  }

  Future<List<dynamic>> getCertificatesData(
      DocumentReference batchDocument, String email) async {
    List<dynamic> certificatesData = [];

    try {
      DocumentReference studentDocumentRef =
          batchDocument.collection('students').doc(email);

      DocumentSnapshot studentSnapshot = await studentDocumentRef.get();

      if (studentSnapshot.exists && studentSnapshot.data() != null) {
        Map<String, dynamic> studentData =
            studentSnapshot.data()! as Map<String, dynamic>;

        certificatesData =
            studentData.containsKey('files') ? studentData['files'] : [];
      }
    } catch (e) {
      print('Error getting certificates data: $e');
    }

    return certificatesData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Certificates Pending Approval",
                      style:
                          TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Divider(
                        thickness: 3,
                        color: const Color.fromRGBO(46, 49, 146, 38),
                      ),
                    )
                  ],
                ),
              ),
              if (_user != null)
                FutureBuilder<Map<String, List<dynamic>>>(
                  future: _getStudentsData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      Map<String, List<dynamic>> studentsData =
                          snapshot.data ?? {};
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var entry in studentsData.entries)
                              _buildStudentCard(entry.key, entry.value),
                          ],
                        ),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(String studentEmail, List<dynamic> filesArray) {
    return Container(
      height: 100,
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentCertificate(
                // Corrected method name
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
                      Container(
                        width: 200,
                        child: Text(
                          "$studentEmail",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Pending approval: ${filesArray.length}",
                        style: TextStyle(fontSize: 16),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                Positioned(
                  top: 25, // Adjust the top position as needed
                  right: 8, // Adjust the right position as needed
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
