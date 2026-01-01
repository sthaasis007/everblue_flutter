import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: Padding(
      //   padding: const EdgeInsets.all(10),
      //   child: Column(
      //     children: [
      //       Align(
      //         alignment: Alignment.topLeft,
      //         child: Text("Cart",style: TextStyle(
      //           fontFamily: 'Montserrat Bold',
      //           fontSize: 30
      //         ),),
      //       ),
      //       Container(
      //         height: 100,
      //         color: Colors.red,
      //       )
      //     ],
      //   ),
      // ),
      body: Center(child: Text("welcome to cartscreen"))
      );
  }
}