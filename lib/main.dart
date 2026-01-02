
import 'package:flutter/material.dart';
import 'package:lost_n_found/core/services/hive/hive_service.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();
  await hiveService.openboxes();

  runApp(const App());
}
