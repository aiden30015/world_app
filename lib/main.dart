import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'screens/language_selection_page.dart';
import 'screens/wordbook_page.dart';
import 'storage.dart';
import 'theme.dart';
import 'word_bank.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WordBank.load();
  runApp(const WordApp());
}

class WordApp extends StatelessWidget {
  const WordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word App',
      theme: buildAppTheme(),
      home: const _StartupGate(),
    );
  }
}

class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  bool _loading = true;
  Category? _savedCategory;
  ToeicProfile? _savedToeic;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = findLanguage(prefs.getString(prefLangKey));
    final category = findCategory(lang, prefs.getString(prefCategoryKey));
    ToeicProfile? toeic;
    if (category?.id == 'toeic') {
      toeic = await ToeicProfile.load();
      if (toeic == null) {
        await clearAllSelection();
        setState(() {
          _loading = false;
        });
        return;
      }
    }
    setState(() {
      _savedCategory = category;
      _savedToeic = toeic;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_savedCategory != null) {
      return WordbookPage(category: _savedCategory!, toeic: _savedToeic);
    }
    return const LanguageSelectionPage();
  }
}