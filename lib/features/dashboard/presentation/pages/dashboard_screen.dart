
import 'package:flutter/material.dart';

import '../../../bottom_screen/presentation/pages/cart_screen.dart';
import '../../../bottom_screen/presentation/pages/checkout_screen.dart';
import '../../../bottom_screen/presentation/pages/home_screen.dart';
import '../../../bottom_screen/presentation/pages/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectIndex = 0;

  List<Widget> lstButtomScreen = [
    const HomeScreen(),
    const CartScreen(),
    const CheckoutScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ever Blue"),backgroundColor: Colors.teal),
      body: lstButtomScreen[_selectIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home'
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart'
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Check Out'
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile'
            ),
        ],
        backgroundColor: Colors.teal,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
        currentIndex: _selectIndex,
        onTap: (index){
          setState(() {
            _selectIndex = index;
          });
        },
        ),
    );
  }
}