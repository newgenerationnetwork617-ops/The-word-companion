import 'package:flutter/material.dart';

import 'app/the_word_companion_app.dart';
import 'data/local_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.instance.database;
  runApp(const TheWordCompanionApp());
}
