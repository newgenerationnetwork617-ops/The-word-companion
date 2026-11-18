import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/bible_package_importer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _installing = false;
  String? _message;
  bool _messageIsError = false;

  Future<void> _chooseAndInstallPackage() async {
    setState(() {
      _installing = true;
      _message = null;
    });
    try {
      final selection = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
      if (selection == null || selection.files.isEmpty) {
        if (mounted) setState(() => _installing = false);
        return;
      }
      final file = selection.files.single;
      final content = file.bytes != null
          ? utf8.decode(file.bytes!)
          : await File(file.path!).readAsString();
      await BiblePackageImporter().install(content);
      if (!mounted) return;
      setState(() {
        _message = '${file.name} was installed. You can now read this translation offline.';
        _messageIsError = false;
        _installing = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _message = 'Could not install this package: $error';
        _messageIsError = true;
        _installing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('The Word Companion')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Manage your reading library and app preferences.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.menu_book_rounded),
                        SizedBox(width: 10),
                        Expanded(child: Text('Bible translation library')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Install a Bible translation package saved on your device. '
                      'Once installed, its Scripture text is stored locally and '
                      'can be read without an internet connection.',
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _installing ? null : _chooseAndInstallPackage,
                      icon: _installing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.file_open_outlined),
                      label: Text(_installing ? 'Installing…' : 'Import Bible package'),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _message!,
                        style: TextStyle(
                          color: _messageIsError
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const ListTile(
              leading: Icon(Icons.shield_outlined),
              title: Text('Offline and private'),
              subtitle: Text(
                'Bible packages are imported into local storage. The app does not '
                'need an account or cloud database for reading.',
              ),
            ),
            const ListTile(
              leading: Icon(Icons.verified_user_outlined),
              title: Text('Check package permissions'),
              subtitle: Text(
                'Only import translations from sources that clearly permit '
                'offline use and redistribution. Check the licence and attribution.',
              ),
            ),
          ],
        ),
      );
}
