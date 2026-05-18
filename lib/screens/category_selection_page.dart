import 'package:flutter/material.dart';

import '../models.dart';
import '../storage.dart';
import '../theme.dart';
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
      appBar: AppBar(title: Text(language.name)),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: PageHeader(
                title: '어떤 용도로\n공부할까요?',
                subtitle: '목표에 맞는 단어 묶음을 선택하세요',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cat = language.categories[index];
                    return _CategoryCard(
                      category: cat,
                      onTap: () => _select(context, cat),
                    );
                  },
                  childCount: language.categories.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: scheme.primary, size: 22),
              ),
              const Spacer(),
              Text(category.name, style: t.titleLarge),
              const SizedBox(height: 4),
              Text(
                category.description,
                style: t.bodyMedium?.copyWith(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
