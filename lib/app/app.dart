import 'package:flutter/material.dart';

import '../features/splash/presentation/pages/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EverBlue',
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      );
  }
}