
import 'package:flutter/material.dart';

import '../../../../core/widgets/mybutton.dart';
import '../../../../core/widgets/mytextfeild.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController number = TextEditingController();
  final TextEditingController password = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("EverBlue",
      style: TextStyle(fontWeight:FontWeight.bold, fontSize: 30)),
      centerTitle: true,
      backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                height: 100,
                width: double.infinity,
                child: const Center(child: Text("Sign up", 
                style: TextStyle(fontSize: 50, fontWeight:FontWeight.bold, fontStyle: FontStyle.italic ),)),
              ),
              SizedBox(
                height: 200,
                child: Image.asset('assets/images/profile.png'),
              ),
              SizedBox(
                height: 340,
                width: double.infinity,
                child: Column(
                  children: [
                    MyTextformfield(labelText: "Name", hintText: 'Enter Full name', controller: name, errorMessage: 'Enter your name'),
                    SizedBox(height: 15,),
                    MyTextformfield(labelText: "Email", hintText: 'Enter a valid email', controller: email, errorMessage: 'Enter a valid email'),
                     SizedBox(height: 15,),
                    MyTextformfield(labelText: "number", hintText: 'Enter a phone number', controller: number, errorMessage: 'Enter a valid phone number'),
                     SizedBox(height: 15,),
                    MyTextformfield(labelText: "Password", hintText: '8 character long', controller: password, errorMessage: 'Enter a pasword'),
                     SizedBox(height: 15,),
                     MyButton(onPressed: (){
                      Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => LoginScreen()));
                     }, text: "Create account"),
                     ]
                ),
              ),
               GestureDetector(onTap: (){
                Navigator.pushReplacement(context
                , MaterialPageRoute(builder: (context) => LoginScreen()));
              },
                child: const Center(child: Text("Already have account")),
              ),
            ],
          ),
        ),
      ),
      );
  }   
}