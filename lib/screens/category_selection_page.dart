import 'package:flutter/material.dart';

import '../models.dart';
import '../storage.dart';
import 'toeic_setup_page.dart';
import 'wordbook_page.dart';

class CategorySelectionPage extends StatelessWidget {
  final Language language;

  const CategorySelectionPage({super.key, required this.language});

  Future<void> _select(BuildContext context, Category category) async {
    if (category.requiresToeicSetup) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              ToeicSetupPage(language: language, category: category),
        ),
      );
      return;
    }
    await saveSelection(language.code, category.id);
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => WordbookPage(category: category)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${language.name} · 용도 선택'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: language.categories.length,
        itemBuilder: (context, index) {
          final category = language.categories[index];
          return Card(
            elevation: 2,
            child: InkWell(
              onTap: () => _select(context, category),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category.icon,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
