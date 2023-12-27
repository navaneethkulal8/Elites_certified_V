import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'loadpdf.dart';

class CertificateItem extends StatelessWidget {
  final String name;
  final String downloadURL;
  final String uploadedAt;
  final int points;
  final List<dynamic> tags;
  final String state;
  final String highlightText;
  final ScrollController? scrollController;
  final int index;

  CertificateItem({
    required this.name,
    required this.downloadURL,
    required this.uploadedAt,
    required this.points,
    required this.tags,
    required this.state,
    required this.highlightText,
    this.scrollController,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isHighlighted = highlightText.isNotEmpty &&
        name.toLowerCase().contains(highlightText.toLowerCase());
    print("Creating CertificateItem for: $name");
    if (isHighlighted && scrollController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Only scroll if there is search text
        if (highlightText.isNotEmpty) {
          scrollController!.animateTo(
            index * 200.0, // Assuming the item height is 200.0
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }

    return Container(
      height: 200.0,
      child: Card(
        elevation: 4.0, // Adjust the elevation for the shadow effect

        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  Container(
                    height: 20,
                    width: 250,
                    child: Text(
                      name,
                      style: TextStyle(
                        fontWeight:
                            isHighlighted ? FontWeight.bold : FontWeight.normal,
                        color: isHighlighted ? Colors.yellow : Colors.black,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("Tags", style: TextStyle(fontSize: 16)),

                      // Your existing code
                      SizedBox(width: 1),

                      SvgPicture.asset(
                        'images/tags_icon.svg',
                        height: 15,
                        width: 15,
                      ),
                      Text(":",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      // Display tags
                      for (String tag in tags)
                        Container(
                          margin: EdgeInsets.only(right: 8.0),
                          padding: EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Text("Uploaded At: $uploadedAt"),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return LoadURL(pdfUrl: downloadURL);
                  }));
                },
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.white,
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.all(10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      color: const Color.fromARGB(255, 1, 40, 72),
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
                          const Color.fromARGB(255, 1, 40, 72),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.0),
                    Text(
                      'View Certificate',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 1, 40, 72),
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
                  color: state == 'Approved' ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  state,
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
  }
}
