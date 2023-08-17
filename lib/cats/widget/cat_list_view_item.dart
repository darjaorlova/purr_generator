import 'package:flutter/material.dart';
import 'package:purr_generator/cats/model/cat.dart';

class CatListViewItem extends StatelessWidget {
  final Cat cat;
  final Function(Cat cat) onCatSelected;

  const CatListViewItem({
    Key? key,
    required this.cat,
    required this.onCatSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onCatSelected(cat),
      child: Card(
        color: Theme.of(context).cardColor,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  'assets/images/${cat.filePrefix}.jpg',
                  width: 120.0,
                  height: 160.0,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      cat.description,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
