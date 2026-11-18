import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../data/bible_package_importer.dart';
import '../../data/hymn_package_importer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _installingBible = false;
  bool _installingHymns = false;
  String? _message;
  bool _messageIsError = false;

  Future<String?> _chooseJsonFile() async {
    final selection = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: const ['json'], withData: true);
    if (selection == null || selection.files.isEmpty) return null;
    final file = selection.files.single;
    return file.bytes != null ? utf8.decode(file.bytes!) : File(file.path!).readAsString();
  }

  Future<void> _installBiblePackage() async {
    setState(() { _installingBible = true; _message = null; });
    try {
      final content = await _chooseJsonFile();
      if (content == null) { if (mounted) setState(() => _installingBible = false); return; }
      await BiblePackageImporter().install(content);
      if (!mounted) return;
      setState(() { _message = 'Bible translation installed for offline reading.'; _messageIsError = false; _installingBible = false; });
    } catch (error) {
      if (!mounted) return;
      setState(() { _message = 'Could not install Bible package: $error'; _messageIsError = true; _installingBible = false; });
    }
  }

  Future<void> _installHymnPackage() async {
    setState(() { _installingHymns = true; _message = null; });
    try {
      final content = await _chooseJsonFile();
      if (content == null) { if (mounted) setState(() => _installingHymns = false); return; }
      await HymnPackageImporter().install(content);
      if (!mounted) return;
      setState(() { _message = 'English hymn collection installed for offline use.'; _messageIsError = false; _installingHymns = false; });
    } catch (error) {
      if (!mounted) return;
      setState(() { _message = 'Could not install hymn collection: $error'; _messageIsError = true; _installingHymns = false; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('The Word Companion')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      Text('Manage your reading library and app preferences.', style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 24),
      Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.menu_book_rounded), SizedBox(width: 10), Expanded(child: Text('Bible translation library'))]),
        const SizedBox(height: 10),
        const Text('Install a properly licensed English Bible package. Once installed, Scripture is stored locally and can be read without internet access.'),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _installingBible || _installingHymns ? null : _installBiblePackage,
          icon: _installingBible ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.file_open_outlined),
          label: Text(_installingBible ? 'Installing…' : 'Import Bible package'),
        ),
      ]))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.library_music_rounded), SizedBox(width: 10), Expanded(child: Text('English hymn library'))]),
        const SizedBox(height: 10),
        const Text('Import English hymn collections that clearly permit offline storage and redistribution. Source and licence details are retained with the collection.'),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _installingBible || _installingHymns ? null : _installHymnPackage,
          icon: _installingHymns ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.library_add_outlined),
          label: Text(_installingHymns ? 'Installing…' : 'Import hymn collection'),
        ),
      ]))),
      if (_message != null) ...[
        const SizedBox(height: 12),
        Text(_message!, style: TextStyle(color: _messageIsError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary)),
      ],
      const SizedBox(height: 12),
      const ListTile(leading: Icon(Icons.shield_outlined), title: Text('Offline and private'), subtitle: Text('Bible and hymn packages are stored locally. No account or cloud database is needed for reading.')),
      const ListTile(leading: Icon(Icons.verified_user_outlined), title: Text('Check package permissions'), subtitle: Text('Only import content from sources that clearly permit offline use and redistribution. Check the licence and attribution.')),
    ]),
  );
}
