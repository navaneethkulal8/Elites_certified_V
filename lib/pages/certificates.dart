import 'package:flutter/material.dart';
import 'pointspage.dart';
import 'bodyCertificate.dart';

class Body extends StatefulWidget {
  final bool certificatesPressed;

  Body({required this.certificatesPressed});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return widget.certificatesPressed ? BodyCertificate() : PointsTable();
  }
}
