import 'package:flutter/material.dart';
import '../../data/hymn_repository.dart';

class HymnsScreen extends StatefulWidget {
  const HymnsScreen({super.key, this.repository});
  final HymnRepository? repository;
  @override
  State<HymnsScreen> createState() => _HymnsScreenState();
}

class _HymnsScreenState extends State<HymnsScreen> {
  late final HymnRepository _repository;
  final TextEditingController _searchController = TextEditingController();
  late Future<List<HymnCollection>> _collections;
  Future<List<HymnSummary>>? _results;
  String? _selectedCollection;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? HymnRepository();
    _collections = _repository.getCollections();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String value) {
    setState(() {
      _selectedCollection = null;
      _results = value.trim().isEmpty ? null : _repository.searchHymns(value);
    });
  }

  Future<void> _openHymn(HymnSummary hymn) async {
    final entry = await _repository.getHymn(hymn.id);
    if (!mounted) return;
    if (entry == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This hymn could not be opened.')));
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => HymnDetailScreen(hymn: entry)));
  }

  void _openCollection(HymnCollection collection) {
    setState(() {
      _selectedCollection = collection.id;
      _results = _repository.getHymnsForCollection(collection.id);
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_selectedCollection == null ? 'Hymn Library' : 'Collection')),
      body: SafeArea(child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Sing and reflect', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Search your installed English hymn collections. Your library stays on this device.', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 18),
          TextField(
            controller: _searchController,
            onChanged: _search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search hymn title or words',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                tooltip: 'Clear search',
                onPressed: () { _searchController.clear(); _search(''); },
                icon: const Icon(Icons.close_rounded),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 22),
          if (_results != null) ...[
            Row(children: [
              Expanded(child: Text(_selectedCollection == null ? 'Search results' : 'Hymns in this collection', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
              if (_selectedCollection != null) TextButton(onPressed: () => setState(() { _selectedCollection = null; _results = null; }), child: const Text('All collections')),
            ]),
            const SizedBox(height: 10),
            FutureBuilder<List<HymnSummary>>(
              future: _results,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
                if (snapshot.hasError) return const Text('Hymns could not be loaded. Please try again.');
                final hymns = snapshot.data ?? const [];
                if (hymns.isEmpty) return const Text('No hymns were found here.');
                return Column(children: hymns.map((hymn) => Card(child: ListTile(
                  leading: const Icon(Icons.music_note_rounded),
                  title: Text(hymn.title),
                  subtitle: Text([if (hymn.hymnNumber != null) 'No. \${hymn.hymnNumber}', hymn.collectionName].join(' • ')),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _openHymn(hymn),
                ))).toList());
              },
            ),
          ] else ...[
            Text('Your collections', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            FutureBuilder<List<HymnCollection>>(
              future: _collections,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
                if (snapshot.hasError) return const Text('Your hymn collections could not be loaded.');
                final collections = snapshot.data ?? const [];
                if (collections.isEmpty) {
                  return Card(child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(children: [
                      Icon(Icons.library_music_outlined, size: 42, color: theme.colorScheme.secondary),
                      const SizedBox(height: 12),
                      Text('No hymn collection installed yet', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      const Text('Your hymn library is ready for English collections with verified public-domain or redistribution licences. No copyrighted lyrics will be added without permission.', textAlign: TextAlign.center),
                    ]),
                  ));
                }
                return Column(children: collections.map((collection) => Card(child: ListTile(
                  leading: const Icon(Icons.library_music_rounded),
                  title: Text(collection.name),
                  subtitle: Text('\${collection.hymnCount} hymns • \${collection.licenceName}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _openCollection(collection),
                ))).toList());
              },
            ),
          ],
        ],
      )),
    );
  }
}

class HymnDetailScreen extends StatelessWidget {
  const HymnDetailScreen({super.key, required this.hymn});
  final HymnEntry hymn;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(hymn.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(24), children: [
      Text(hymn.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text([if (hymn.hymnNumber != null) 'Hymn \${hymn.hymnNumber}', hymn.collectionName].join(' · '), style: Theme.of(context).textTheme.bodyMedium),
      const Divider(height: 28),
      SelectableText(hymn.lyrics, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8)),
      const SizedBox(height: 28),
      Text('Source: \${hymn.sourceName}', style: Theme.of(context).textTheme.bodySmall),
      Text('Licence: \${hymn.licenceName}', style: Theme.of(context).textTheme.bodySmall),
    ])),
  );
}
