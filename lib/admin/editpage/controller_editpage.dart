import 'package:elites_certificate/admin/editpage/adduser.dart';
import 'package:elites_certificate/admin/editpage/mentor_view_delete.dart';
import 'package:elites_certificate/admin/editpage/metor_assign.dart';
import 'package:flutter/material.dart';

class Body extends StatefulWidget {
  final bool certificatesPressed;

  Body({required this.certificatesPressed});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return widget.certificatesPressed
        ? AddingUsers()
        : selectedIndex == 1 // Add button
            ? MentorAssign()
            : MentorViewDelete();
  }
}
