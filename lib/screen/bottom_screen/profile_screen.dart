import 'package:everblue_flutter/screen/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:everblue_flutter/screen/bottom_screen/cart_screen.dart';
import 'package:everblue_flutter/screen/bottom_screen/checkout_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ever Blue"),backgroundColor: Colors.teal),
      
      body: Center(
        child: Text("This is Profile section", style: TextStyle(
          fontSize: 40
        ),),
      ),
    );
  }
}