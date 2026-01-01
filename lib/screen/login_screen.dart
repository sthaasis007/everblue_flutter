
import 'package:flutter/material.dart';

import '../wedget/mybutton.dart';
import '../wedget/mytextfeild.dart';
import 'dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mail = TextEditingController();
  final TextEditingController pass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("EverBlue",
      style: TextStyle(fontWeight:FontWeight.bold, fontSize: 30)),
      centerTitle: true,
      backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 100,
                width: double.infinity,
                child: const Center(child: Text("Log in", 
                style: TextStyle(fontSize: 50, fontFamily: 'Montserrat Bold Italic' ),)),
              ),
              SizedBox(
                height: 350,
                child: Image.asset('assets/images/profile.png'),
              ),
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Column(
                  children: [
                    MyTextformfield(labelText: "Email", hintText: 'Enter valid Email', controller: mail, errorMessage: 'Enter a vaild mail'),
                    SizedBox(height: 15,),
                    MyTextformfield(labelText: "Password", hintText: 'Enter valid passwrd', controller: mail, errorMessage: 'Enter a correct password'),
                     SizedBox(height: 15,),
                     MyButton(onPressed: (){
                      Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => DashboardScreen()));
                     }, text: "Log In"),
                     ]                  
                ),
              ),
              GestureDetector(onTap: (){
                Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => SignupScreen()));
              },
              child: const Center(child: Text("Don't have a account")),
              ), 
            ],
          ),
        ),
      ),
      );
  }
}