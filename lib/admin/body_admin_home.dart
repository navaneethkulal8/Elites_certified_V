import 'package:elites_certificate/admin/adminhomebatch.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'batchcreation.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late CollectionReference<Map<String, dynamic>> batchesCollection;

  List<String> backgroundImages = [
    'images/card1.jpg',
    'images/card2.jpg',
    'images/card3.jpg',
    'images/card4.jpg',
  ];

  int imageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('batches').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            List<Widget> batchCards = [];

            snapshot.data!.docs.forEach((batch) {
              String batchTitle = batch.id; // Use document ID as the title
              String imagePath =
                  backgroundImages[imageIndex % backgroundImages.length];
              imageIndex++;

              batchCards.add(
                InkWell(
                  onTap: () {
                    // Navigate to the detail page when the card is clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Adminbatch(batchTitle: batchTitle),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(imagePath),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(35.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 4.0,
                                        bottom: 4.0,
                                        left: 8.0,
                                        right: 8.0,
                                      ),
                                      child: Text(
                                        batchTitle,
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.visibility,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'View',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Department of Electrical & Electronics",
                    style: TextStyle(
                      fontFamily: "fonts/Roboto-Black.ttf",
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        "Batches",
                        style: TextStyle(
                            fontSize: 23, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 5),
                      SvgPicture.asset(
                        'images/groupsicon.svg',
                        width: 25,
                        height: 25,
                        colorFilter: ColorFilter.mode(
                          const Color.fromRGBO(46, 49, 146, 38),
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Divider(
                    height: 5,
                    color: const Color.fromRGBO(46, 49, 146, 38),
                    thickness: 1,
                  ),
                ),
                Column(
                  children: batchCards,
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 0, 41, 74),
        onPressed: () {
          print('Navigating to BatchCreation...');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BatchCreation()),
          );
        },
        icon: Icon(Icons.add),
        label: Text('CREATE BATCH'),
      ),
    );
  }
}
