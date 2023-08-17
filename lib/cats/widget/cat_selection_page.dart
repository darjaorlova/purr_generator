import 'package:flutter/material.dart';
import 'package:purr_generator/cats/model/cat.dart';
import 'package:purr_generator/cats/model/cats.dart';
import 'package:purr_generator/cats/widget/cat_list_view_item.dart';
import 'package:purr_generator/cats/widget/cat_player_page.dart';

class CatSelectionPage extends StatefulWidget {
  const CatSelectionPage({super.key});

  @override
  State<CatSelectionPage> createState() => _CatSelectionPageState();
}

class _CatSelectionPageState extends State<CatSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purr selector'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        itemBuilder: (_, index) {
          return CatListViewItem(
            cat: Cats.cats[index],
            onCatSelected: _onCatSelected,
          );
        },
        itemCount: Cats.cats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8.0),
      ),
    );
  }

  void _onCatSelected(Cat cat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CatPlayerPage(
          cat: cat,
        ),
      ),
    );
  }
}
