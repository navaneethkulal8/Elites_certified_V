import 'package:elites_certificate/Mentorpages/homepagestudentcert.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Adminbatch extends StatefulWidget {
  const Adminbatch({super.key, required this.batchTitle});
  final String batchTitle;

  Adminbatch.namedConstructor(this.batchTitle, {Key? key}) : super(key: key);

  @override
  State<Adminbatch> createState() => _AdminbatchState();
}

class _AdminbatchState extends State<Adminbatch> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _getStudentsData() async {
    List<Map<String, dynamic>> studentsDataList = [];

    try {
      CollectionReference studentsCollection = _firestore
          .collection('batches')
          .doc(widget.batchTitle)
          .collection('students');

      QuerySnapshot studentsQuerySnapshot = await studentsCollection.get();

      for (QueryDocumentSnapshot studentDocument
          in studentsQuerySnapshot.docs) {
        List<dynamic> filesArray = await getCertificatesData(studentDocument);

        Map<String, dynamic> studentData = {
          'email': studentDocument.id,
          'filesArray': filesArray,
        };

        studentsDataList.add(studentData);
      }
    } catch (e) {
      print('Error getting students data: $e');
    }

    return studentsDataList;
  }

  Future<List<dynamic>> getCertificatesData(
      DocumentSnapshot studentDocument) async {
    List<dynamic> certificatesData = [];

    try {
      Map<String, dynamic>? studentData =
          studentDocument.data() as Map<String, dynamic>?;

      if (studentData != null && studentData.containsKey('files')) {
        certificatesData = List.from(studentData['files']);
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getStudentsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>> studentsDataList = snapshot.data ?? [];
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
                  for (Map<String, dynamic> studentData in studentsDataList)
                    _buildStudentCard(
                        studentData['email'], studentData['filesArray']),
                ],
              ),
            );
          }
        },
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
                        "Certificates: ${filesArray.length}",
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
