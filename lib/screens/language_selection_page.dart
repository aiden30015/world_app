import 'package:flutter/material.dart';

import '../data.dart';
import 'category_selection_page.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('언어 선택'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: languages.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final lang = languages[index];
          return ListTile(
            leading: Text(lang.flag, style: const TextStyle(fontSize: 28)),
            title: Text(lang.name),
            subtitle: Text(lang.available ? '사용 가능' : '준비 중'),
            enabled: lang.available,
            trailing: const Icon(Icons.chevron_right),
            onTap: lang.available
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CategorySelectionPage(language: lang),
                      ),
                    );
                  }
                : null,
          );
        },
      ),
    );
  }
}
