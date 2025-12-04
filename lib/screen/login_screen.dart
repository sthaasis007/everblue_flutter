import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("EverBlue",
      style: TextStyle(fontWeight:FontWeight.bold, fontSize: 30)),
      centerTitle: true,
      backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(height: 50,),
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.red,
              child: const Center(child: Text("Log in", 
              style: TextStyle(fontSize: 50, fontWeight:FontWeight.bold, fontStyle: FontStyle.italic ),)),
            ),
            SizedBox(
              height: 350,
              child: Image.asset('assets/images/profile.png'),
            ),
            Container(
              height: 80,
              width: double.infinity,
              color: Colors.blue,
              
            ),
          ],
        ),
      ),
      );
  }
}