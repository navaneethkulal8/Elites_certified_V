import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'batchdetailpage.dart';

class Mentorbody extends StatefulWidget {
  const Mentorbody({Key? key});

  @override
  State<Mentorbody> createState() => _MentorbodyState();
}

class _MentorbodyState extends State<Mentorbody> {
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
                        builder: (context) => BatchDetailPage(batchTitle),
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
    );
  }
}
