import 'package:flutter/material.dart';

import '../../data/bible_catalog.dart';
import '../../data/bible_repository.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key, this.repository});

  final BibleRepository? repository;

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  late final BibleRepository _repository;
  late Future<List<BibleVersion>> _versionsFuture;
  BibleBook _book = bibleBooks.first;
  int _chapter = 1;
  String? _versionId;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? BibleRepository();
    _versionsFuture = _repository.getInstalledVersions();
  }

  Future<void> _pickBook() async {
    final result = await showModalBottomSheet<BibleBook>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _BookPicker(selected: _book),
    );
    if (result != null && mounted) {
      setState(() {
        _book = result;
        _chapter = 1;
      });
    }
  }

  Future<void> _pickChapter() async {
    final result = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose a chapter',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  _book.chapters,
                  (index) => SizedBox(
                    width: 48,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, index + 1),
                      child: Text('${index + 1}'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (result != null && mounted) setState(() => _chapter = result);
  }

  Future<void> _openVerseActions(BibleVerse verse) async {
    final versionId = _versionId;
    if (versionId == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _VerseActionsSheet(
        repository: _repository,
        versionId: versionId,
        book: _book,
        chapter: _chapter,
        verse: verse,
        onStudy: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(
              content: Text(
                'Study workspace for ${_book.name} ${_chapter}:${verse.number} is being prepared.',
              ),
            ),
          );
        },
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('The Word Companion')),
        body: SafeArea(
          child: FutureBuilder<List<BibleVersion>>(
            future: _versionsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Bible reader',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      const Text(
                        'The Bible library could not be opened. Please restart the app.',
                      ),
                    ],
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final versions = snapshot.data!;
              if (_versionId != null &&
                  !versions.any((version) => version.id == _versionId)) {
                _versionId = null;
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bible reader',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        const Text('Choose a passage from your Scripture library.'),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickBook,
                                icon: const Icon(Icons.menu_book_outlined),
                                label: Text(_book.name,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: _pickChapter,
                              child: Text('Chapter $_chapter'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (versions.isNotEmpty)
                          DropdownButtonFormField<String>(
                            initialValue: _versionId,
                            hint: const Text('Choose a translation'),
                            decoration: const InputDecoration(
                              labelText: 'English translation',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.menu_book_outlined),
                            ),
                            items: versions
                                .map((version) => DropdownMenuItem(
                                      value: version.id,
                                      child: Text(
                                        '${version.name} (${version.abbreviation})',
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _versionId = value),
                          )
                        else
                          const _NoTranslationNotice(),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: _versionId == null
                        ? const _EmptyReader()
                        : FutureBuilder<List<BibleVerse>>(
                            key: ValueKey(
                              '$_versionId-${_book.id}-$_chapter',
                            ),
                            future: _repository.getChapter(
                              versionId: _versionId!,
                              bookId: _book.id,
                              chapter: _chapter,
                            ),
                            builder: (context, verses) {
                              if (verses.hasError) {
                                return const Center(
                                  child: Text('Unable to load this passage.'),
                                );
                              }
                              if (!verses.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (verses.data!.isEmpty) {
                                return const _EmptyReader(
                                  message:
                                      'This chapter is not included in the selected English translation package.',
                                );
                              }
                              return ListView.separated(
                                padding: const EdgeInsets.all(20),
                                itemCount: verses.data!.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final verse = verses.data![index];
                                  return _VerseTile(
                                    verse: verse,
                                    onTap: () => _openVerseActions(verse),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      );
}

class _VerseTile extends StatelessWidget {
  const _VerseTile({required this.verse, required this.onTap});

  final BibleVerse verse;
  final VoidCallback onTap;

  Color? _highlight(BuildContext context) {
    switch (verse.highlightColor) {
      case 'gold':
        return Colors.amber.withValues(alpha: 0.20);
      case 'blue':
        return Colors.blue.withValues(alpha: 0.14);
      case 'green':
        return Colors.green.withValues(alpha: 0.14);
      case 'rose':
        return Colors.pink.withValues(alpha: 0.13);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) => Material(
        color: _highlight(context) ?? Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    '${verse.number}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    verse.text,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.65, fontSize: 17),
                  ),
                ),
                if (verse.isBookmarked)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.bookmark, size: 17),
                  ),
                if (verse.hasNote)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.edit_note, size: 18),
                  ),
              ],
            ),
          ),
        ),
      );
}

class _VerseActionsSheet extends StatefulWidget {
  const _VerseActionsSheet({
    required this.repository,
    required this.versionId,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.onStudy,
  });

  final BibleRepository repository;
  final String versionId;
  final BibleBook book;
  final int chapter;
  final BibleVerse verse;
  final VoidCallback onStudy;

  @override
  State<_VerseActionsSheet> createState() => _VerseActionsSheetState();
}

class _VerseActionsSheetState extends State<_VerseActionsSheet> {
  late bool _bookmarked;
  String? _highlight;
  String? _note;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bookmarked = widget.verse.isBookmarked;
    _highlight = widget.verse.highlightColor;
    _loadNote();
  }

  Future<void> _loadNote() async {
    try {
      final note = await widget.repository.getNote(
        bookId: widget.book.id,
        chapter: widget.chapter,
        verse: widget.verse.number,
      );
      if (mounted) setState(() {
        _note = note;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleBookmark() async {
    final result = await widget.repository.toggleBookmark(
      versionId: widget.versionId,
      bookId: widget.book.id,
      chapter: widget.chapter,
      verse: widget.verse.number,
    );
    if (mounted) setState(() => _bookmarked = result);
  }

  Future<void> _setHighlight(String? color) async {
    await widget.repository.setHighlight(
      versionId: widget.versionId,
      bookId: widget.book.id,
      chapter: widget.chapter,
      verse: widget.verse.number,
      colorKey: color,
    );
    if (mounted) setState(() => _highlight = color);
  }

  Future<void> _editNote() async {
    final controller = TextEditingController(text: _note ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personal verse note'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 7,
          decoration: const InputDecoration(
            hintText: 'Write what you want to remember about this verse…',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save note'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null) return;
    await widget.repository.saveNote(
      bookId: widget.book.id,
      chapter: widget.chapter,
      verse: widget.verse.number,
      noteText: result,
    );
    if (mounted) setState(() => _note = result.trim().isEmpty ? null : result.trim());
  }

  @override
  Widget build(BuildContext context) {
    final reference = '${widget.book.name} ${widget.chapter}:${widget.verse.number}';
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reference, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(widget.verse.text, style: Theme.of(context).textTheme.bodyLarge),
            const Divider(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(_bookmarked ? Icons.bookmark : Icons.bookmark_border),
              title: Text(_bookmarked ? 'Remove bookmark' : 'Bookmark verse'),
              onTap: _toggleBookmark,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Highlight verse'),
              subtitle: Wrap(
                spacing: 8,
                children: [
                  _HighlightChoice(
                    label: 'Gold',
                    selected: _highlight == 'gold',
                    color: Colors.amber,
                    onTap: () => _setHighlight(_highlight == 'gold' ? null : 'gold'),
                  ),
                  _HighlightChoice(
                    label: 'Blue',
                    selected: _highlight == 'blue',
                    color: Colors.blue,
                    onTap: () => _setHighlight(_highlight == 'blue' ? null : 'blue'),
                  ),
                  _HighlightChoice(
                    label: 'Green',
                    selected: _highlight == 'green',
                    color: Colors.green,
                    onTap: () => _setHighlight(_highlight == 'green' ? null : 'green'),
                  ),
                  _HighlightChoice(
                    label: 'Rose',
                    selected: _highlight == 'rose',
                    color: Colors.pink,
                    onTap: () => _setHighlight(_highlight == 'rose' ? null : 'rose'),
                  ),
                ],
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.edit_note),
              title: Text(_loading
                  ? 'Loading personal note…'
                  : _note == null
                      ? 'Add personal note'
                      : 'Edit personal note'),
              onTap: _loading ? null : _editNote,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.auto_stories_outlined),
              title: const Text('Study this verse'),
              subtitle: const Text('Open the verse study workspace'),
              onTap: widget.onStudy,
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightChoice extends StatelessWidget {
  const _HighlightChoice({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
        avatar: CircleAvatar(backgroundColor: color, radius: 6),
        label: Text(label),
        onPressed: onTap,
        side: selected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : null,
      );
}

class _NoTranslationNotice extends StatelessWidget {
  const _NoTranslationNotice();

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.library_books_outlined,
                  color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'No English Bible translation is installed yet. Import a licensed English Scripture package in Settings to begin reading.',
                ),
              ),
            ],
          ),
        ),
      );
}

class _EmptyReader extends StatelessWidget {
  const _EmptyReader({
    this.message =
        'Your selected passage will appear here when an English translation is installed.',
  });

  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_rounded,
                  size: 48, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      );
}

class _BookPicker extends StatefulWidget {
  const _BookPicker({required this.selected});

  final BibleBook selected;

  @override
  State<_BookPicker> createState() => _BookPickerState();
}

class _BookPickerState extends State<_BookPicker> {
  String _query = '';
  String _testament = 'All';

  @override
  Widget build(BuildContext context) {
    final books = bibleBooks
        .where((book) =>
            (_testament == 'All' ||
                book.testament ==
                    (_testament == 'Old Testament' ? 'OT' : 'NT')) &&
            book.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .78,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text('Choose a book',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search books',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'All', label: Text('All')),
                  ButtonSegment(
                      value: 'Old Testament', label: Text('Old Testament')),
                  ButtonSegment(
                      value: 'New Testament', label: Text('New Testament')),
                ],
                selected: {_testament},
                onSelectionChanged: (value) =>
                    setState(() => _testament = value.first),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return ListTile(
                    title: Text(book.name),
                    subtitle: Text('${book.chapters} chapters'),
                    trailing: book.id == widget.selected.id
                        ? const Icon(Icons.check_circle_rounded)
                        : null,
                    onTap: () => Navigator.pop(context, book),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
