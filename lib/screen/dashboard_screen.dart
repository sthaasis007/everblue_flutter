import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ever Blue"),backgroundColor: Colors.teal),
      
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
          children: [
            Column(
              children: [
                Image.asset('assets/images/dashpic.png'),
              ],
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                Text("Top seller",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),),
              ],
            ),
            SizedBox(height: 10,),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/img.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 15,),
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/img.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 15,),
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/img.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 15,),
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/img.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 15,),
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/img.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 15,),
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/img.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 15,),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                Text("Most Popular",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),),
              ],
            ),
             SizedBox(height: 20,),

            Column(
              children: [
                Row(
                  children: [
                    Container(
                       height: 140,
                        width: 170,
                      decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/splash.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    ),
                    SizedBox(width: 50,),
                    Container(
                       height: 140,
                        width: 170,
                      decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/splash.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    ),
                  ],
                ),
                SizedBox(height: 50,),
                Row(
                  children: [
                    Container(
                       height: 140,
                        width: 170,
                      decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/splash.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    ),
                    SizedBox(width: 50,),
                    Container(
                       height: 140,
                        width: 170,
                      decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/splash.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    ),
                  ],
                ),
                SizedBox(height: 50,),
                Row(
                  children: [
                    Container(
                       height: 140,
                        width: 170,
                      decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/splash.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    ),
                    SizedBox(width: 50,),
                    Container(
                       height: 140,
                        width: 170,
                      decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/splash.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    ),
                  ],
                ),
                SizedBox(height: 50,),
                Row(
                  children: [
                    Container(
                       height: 140,
                        width: 170,
                      decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/splash.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    ),
                    SizedBox(width: 50,),
                    Container(
                       height: 140,
                        width: 170,
                      decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/splash.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    ),
                  ],
                ),
                SizedBox(height: 50,),
              ],
            )
            ],        
          ),
        ),
      ),
    );
  }
}