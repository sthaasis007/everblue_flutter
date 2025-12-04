import 'package:everblue_flutter/screen/login_screen.dart';
import 'package:everblue_flutter/wedget/mybutton.dart';
import 'package:everblue_flutter/wedget/mytextfeild.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
            Container(
              height: 100,
              width: double.infinity,
              child: const Center(child: Text("Log in", 
              style: TextStyle(fontSize: 50, fontWeight:FontWeight.bold, fontStyle: FontStyle.italic ),)),
            ),
            SizedBox(
              height: 350,
              child: Image.asset('assets/images/profile.png'),
            ),
            Container(
              height: 300,
              width: double.infinity,
              child: Column(
                children: [
                  // MyTextformfield(labelText: "Email", hintText: 'Enter valid Email', controller: mail, errorMessage: 'Enter a vaild mail'),
                  // SizedBox(height: 15,),
                  // MyTextformfield(labelText: "Password", hintText: 'Enter valid passwrd', controller: mail, errorMessage: 'Enter a correct password'),
                  //  SizedBox(height: 15,),
                  //  MyButton(onPressed: (){}, text: "Log In"),
                   ]
              ),
            ),
             GestureDetector(onTap: (){
              Navigator.push(context
              , MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: SizedBox(
              height: 25,
              width: double.infinity,
              child: const Center(child: Text("Already have account")),
            ),
            ),
          ],
        ),
      ),
      );
  }   
}