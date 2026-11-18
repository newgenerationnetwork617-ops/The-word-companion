import 'package:flutter/material.dart';

import 'app/the_word_companion_app.dart';
import 'data/bundled_bible_installer.dart';
import 'data/local_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.instance.database;
  await BundledBibleInstaller().installAvailablePackages();
  runApp(const TheWordCompanionApp());
}
