import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:elites_certificate/pages/loadpdf.dart';

class HomepageStudentCertificate extends StatefulWidget {
  final String email;
  final List<dynamic> filesArray;

  const HomepageStudentCertificate({
    Key? key,
    required this.email,
    required this.filesArray,
  }) : super(key: key);

  @override
  State<HomepageStudentCertificate> createState() =>
      _HomepageStudentCertificateState(email: email, filesArray: filesArray);
}

class _HomepageStudentCertificateState
    extends State<HomepageStudentCertificate> {
  final String email;
  final List<dynamic> filesArray;

  _HomepageStudentCertificateState({
    required this.email,
    required this.filesArray,
  });

  @override
  Widget build(BuildContext context) {
    List<dynamic> approvedCertificates = widget.filesArray
        .where((certificate) => certificate['state'] == 'Approved')
        .toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(218, 5, 9, 136),
        title: Text(
          "Individual",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontFamily: "fonts/Roboto-bold.ttf"),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Certificates of: ",
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: "fonts/Roboto-bold.ttf",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  " ${widget.email}",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "fonts/Roboto-Bold.ttf",
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Divider(
              height: 10,
              color: const Color.fromRGBO(46, 49, 146, 38),
              thickness: 4,
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: approvedCertificates.length,
              itemBuilder: (context, index) {
                var fileData = approvedCertificates[index];

                return Container(
                  height: 250.0,
                  child: Card(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4.0),
                              Text(
                                widget.email,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: 300,
                                child: Text(
                                  "${fileData['name']}",
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  for (String tag
                                      in List<String>.from(fileData['tags']))
                                    Container(
                                      margin: EdgeInsets.only(right: 8.0),
                                      padding: EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Points: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  Text(
                                    "${fileData['points']}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Uploaded On: ${_formatDate(fileData['uploadedAt'])}",
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 16,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return LoadURL(pdfUrl: fileData["downloadURL"]);
                              }));
                            },
                            style: ElevatedButton.styleFrom(
                              shadowColor: Colors.white,
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.all(10.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                side: BorderSide(
                                  color: const Color.fromRGBO(46, 49, 146, 38),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20.0,
                                  height: 20.0,
                                  child: SvgPicture.asset(
                                    'images/certificate.svg',
                                    colorFilter: ColorFilter.mode(
                                      const Color.fromRGBO(46, 49, 146, 38),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4.0),
                                Text(
                                  'View Certificate',
                                  style: TextStyle(
                                    color:
                                        const Color.fromRGBO(46, 49, 146, 38),
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: fileData['state'] == 'Approved'
                                  ? Colors.green
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              fileData['state'],
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = "${dateTime.day}-${dateTime.month}-${dateTime.year}";
    return formattedDate;
  }
}
