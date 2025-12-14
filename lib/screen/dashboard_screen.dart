import 'package:everblue_flutter/screen/bottom_screen/cart_screen.dart';
import 'package:everblue_flutter/screen/bottom_screen/checkout_screen.dart';
import 'package:everblue_flutter/screen/bottom_screen/profile_screen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ever Blue"),backgroundColor: Colors.teal),
      
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
          IconButton(
            icon: Icon(Icons.home,  color: Colors.teal),
            onPressed: () {Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => DashboardScreen()));},
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart,  color: Colors.teal),
            onPressed: () {
              Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => CartScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.payment,  color: Colors.teal),
            onPressed: () {
              Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => CheckoutScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.person,  color: Colors.teal),
            onPressed: () {
              Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
          ),
          ],
        ),
      ),
      body: Center(
        child: Text("This is dashboard", style: TextStyle(
          fontSize: 40
        ),),
      ),
    );
  }
}