import 'package:flutter/material.dart';

import '../data.dart';
import '../models.dart';
import '../theme.dart';
import 'category_selection_page.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          children: [
            const PageHeader(
              title: '어떤 언어를\n배워볼까요?',
              subtitle: '원하는 언어를 선택하세요',
              padding: EdgeInsets.fromLTRB(4, 0, 4, 28),
            ),
            for (final lang in languages)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _LanguageCard(language: lang),
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final Language language;

  const _LanguageCard({required this.language});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final available = language.available;
    return Opacity(
      opacity: available ? 1 : 0.55,
      child: Card(
        child: InkWell(
          onTap: available
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          CategorySelectionPage(language: language),
                    ),
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: available ? scheme.primaryContainer : kSubtle,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    language.flag,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      StatusPill(
                        text: available ? '사용 가능' : '준비 중',
                        color:
                            available ? scheme.primary : kMuted,
                        backgroundColor: available
                            ? scheme.primaryContainer
                            : kSubtle,
                      ),
                    ],
                  ),
                ),
                if (available)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: kMuted,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
