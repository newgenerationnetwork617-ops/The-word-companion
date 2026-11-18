import 'package:flutter/material.dart';
import '../../data/bible_catalog.dart';
import '../../data/bible_repository.dart';

class BibleScreen extends StatefulWidget {
 const BibleScreen({super.key});
 @override State<BibleScreen> createState()=>_BibleScreenState();
}
class _BibleScreenState extends State<BibleScreen> {
 final _repository=BibleRepository();
 BibleBook _book=bibleBooks.first;
 int _chapter=1;
 String? _versionId;
 Future<void> _pickBook() async {
  final result=await showModalBottomSheet<BibleBook>(context:context,isScrollControlled:true,showDragHandle:true,builder:(context)=>_BookPicker(selected:_book));
  if(result!=null&&mounted)setState(()=>_book=result);
 }
 Future<void> _pickChapter() async {
  final result=await showModalBottomSheet<int>(context:context,showDragHandle:true,builder:(context)=>SafeArea(child:Padding(padding:const EdgeInsets.all(20),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
   Text('Choose a chapter',style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:16),
   Wrap(spacing:8,runSpacing:8,children:List.generate(_book.chapters,(i)=>SizedBox(width:48,height:46,child:OutlinedButton(onPressed:()=>Navigator.pop(context,i+1),child:Text('${i+1}')))))
  ]))));
  if(result!=null&&mounted)setState(()=>_chapter=result);
 }
 @override Widget build(BuildContext context)=>Scaffold(
  appBar:AppBar(title:const Text('The Word Companion')),
  body:SafeArea(child:FutureBuilder<List<BibleVersion>>(
   future:_repository.getInstalledVersions(),
   builder:(context,snapshot){
    if(snapshot.hasError)return const Center(child:Text('The Bible library could not be opened.'));
    if(!snapshot.hasData)return const Center(child:CircularProgressIndicator());
    final versions=snapshot.data!;
    if(_versionId!=null&&!versions.any((v)=>v.id==_versionId))_versionId=null;
    return Column(children:[
     Padding(padding:const EdgeInsets.fromLTRB(20,12,20,14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('Bible reader',style:Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.w800)),
      const SizedBox(height:4),const Text('Choose a passage from your Scripture library.'),
      const SizedBox(height:14),
      Row(children:[
       Expanded(child:OutlinedButton.icon(onPressed:_pickBook,icon:const Icon(Icons.menu_book_outlined),label:Text(_book.name,overflow:TextOverflow.ellipsis))),
       const SizedBox(width:8),OutlinedButton(onPressed:_pickChapter,child:Text('Chapter $_chapter'))
      ]),
      const SizedBox(height:10),
      if(versions.isNotEmpty) DropdownButtonFormField<String>(
       value:_versionId,hint:const Text('Choose a translation'),
       decoration:const InputDecoration(labelText:'Translation',border:OutlineInputBorder(),prefixIcon:Icon(Icons.translate)),
       items:versions.map((v)=>DropdownMenuItem(value:v.id,child:Text('${v.name} (${v.abbreviation})'))).toList(),
       onChanged:(value)=>setState(()=>_versionId=value),
      ) else const _NoTranslationNotice(),
     ])),
     const Divider(height:1),
     Expanded(child:_versionId==null?const _EmptyReader():FutureBuilder<List<BibleVerse>>(
      key:ValueKey('$_versionId-${_book.id}-$_chapter'),
      future:_repository.getChapter(versionId:_versionId!,bookId:_book.id,chapter:_chapter),
      builder:(context,verses){
       if(verses.hasError)return const Center(child:Text('Unable to load this passage.'));
       if(!verses.hasData)return const Center(child:CircularProgressIndicator());
       if(verses.data!.isEmpty)return const _EmptyReader(message:'This chapter is not included in the selected translation package.');
       return ListView.separated(padding:const EdgeInsets.all(20),itemCount:verses.data!.length,separatorBuilder:(_,__)=>const SizedBox(height:14),itemBuilder:(context,i){
        final verse=verses.data![i];
        return Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
         SizedBox(width:30,child:Text('${verse.number}',style:TextStyle(color:Theme.of(context).colorScheme.secondary,fontWeight:FontWeight.bold))),
         Expanded(child:Text(verse.text,style:Theme.of(context).textTheme.bodyLarge?.copyWith(height:1.65,fontSize:17)))
        ]);
       });
      },
     ))
    ]);
   },
  )),
 );
}
class _NoTranslationNotice extends StatelessWidget {
 const _NoTranslationNotice();
 @override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(14),child:Row(children:[
  Icon(Icons.library_books_outlined,color:Theme.of(context).colorScheme.secondary),const SizedBox(width:10),
  const Expanded(child:Text('No Bible translation is installed yet. The reader is ready, but a licensed Scripture package is needed before verse text can appear.'))
 ])));
}
class _EmptyReader extends StatelessWidget {
 const _EmptyReader({this.message='Your selected passage will appear here when a translation is installed.'});
 final String message;
 @override Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(28),child:Column(mainAxisSize:MainAxisSize.min,children:[
  Icon(Icons.menu_book_rounded,size:48,color:Theme.of(context).colorScheme.secondary),const SizedBox(height:12),Text(message,textAlign:TextAlign.center,style:Theme.of(context).textTheme.bodyLarge)
 ])));
}
class _BookPicker extends StatefulWidget {
 const _BookPicker({required this.selected});
 final BibleBook selected;
 @override State<_BookPicker> createState()=>_BookPickerState();
}
class _BookPickerState extends State<_BookPicker> {
 String _query=''; String _testament='All';
 @override Widget build(BuildContext context){
  final books=bibleBooks.where((b)=>(_testament=='All'||b.testament==(_testament=='Old Testament'?'OT':'NT'))&&b.name.toLowerCase().contains(_query.toLowerCase())).toList();
  return SafeArea(child:SizedBox(height:MediaQuery.sizeOf(context).height*.78,child:Column(children:[
   Padding(padding:const EdgeInsets.fromLTRB(20,8,20,12),child:Text('Choose a book',style:Theme.of(context).textTheme.titleLarge)),
   Padding(padding:const EdgeInsets.symmetric(horizontal:20),child:TextField(decoration:const InputDecoration(hintText:'Search books',prefixIcon:Icon(Icons.search),border:OutlineInputBorder()),onChanged:(v)=>setState(()=>_query=v))),
   Padding(padding:const EdgeInsets.all(12),child:SegmentedButton<String>(segments:const [ButtonSegment(value:'All',label:Text('All')),ButtonSegment(value:'Old Testament',label:Text('Old Testament')),ButtonSegment(value:'New Testament',label:Text('New Testament'))],selected:{_testament},onSelectionChanged:(v)=>setState(()=>_testament=v.first))),
   Expanded(child:ListView.builder(itemCount:books.length,itemBuilder:(context,i){final book=books[i];return ListTile(title:Text(book.name),subtitle:Text('${book.chapters} chapters'),trailing:book.id==widget.selected.id?const Icon(Icons.check_circle_rounded):null,onTap:()=>Navigator.pop(context,book));}))
  ])));
 }
}
