import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/splash/presentation/pages/splash_screen.dart';
import '../core/widgets/shake_detector_wrapper.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: ShakeDetectorWrapper(
        child: MaterialApp(
          title: 'EverBlue',
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
        ),
      ),
    );
  }
}