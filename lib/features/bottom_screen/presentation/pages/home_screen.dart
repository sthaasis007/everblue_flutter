import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
          children: [
            SizedBox(
              height: 150,
              child: Image.asset('assets/images/dashpic.png')),
            Align(
              alignment: Alignment.topLeft,
              child: Text("Top Seller",
              style: TextStyle(
                fontSize: 25,
                fontFamily: 'OpenSans Regular',
              ),),
            ),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 2)
                      ),
                    ),
                  );
                }),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text("Browse more",
              style: TextStyle(
                fontSize: 25,
                fontFamily: 'OpenSans Regular',
              ),),
            ),     
            SizedBox(
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(10),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
                children: [
                  for (int i = 1; i <= 10; i++)
                    Container(
                      color: Colors.red,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      )
    );
  }
}