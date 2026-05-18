import 'dart:convert';

import 'package:flutter/services.dart';

import 'models.dart';

class WordBank {
  static final Map<String, List<Word>> _byCategory = {};
  static final Map<ToeicLevel, List<Word>> _byToeicLevel = {};

  static List<Word> forCategory(String id) =>
      List.unmodifiable(_byCategory[id] ?? const []);

  static List<Word> forToeic(ToeicLevel level) =>
      List.unmodifiable(_byToeicLevel[level] ?? const []);

  static Future<void> load() async {
    const categoryFiles = {
      'basic': 'assets/words/english/basic.json',
      'conversation': 'assets/words/english/conversation.json',
      'toefl': 'assets/words/english/toefl.json',
      'ielts': 'assets/words/english/ielts.json',
      'csat': 'assets/words/english/csat.json',
    };
    for (final entry in categoryFiles.entries) {
      _byCategory[entry.key] = await _loadFile(entry.value);
    }
    for (final level in ToeicLevel.values) {
      _byToeicLevel[level] =
          await _loadFile('assets/words/english/toeic/${level.name}.json');
    }
  }

  static Future<List<Word>> _loadFile(String path) async {
    final raw = await rootBundle.loadString(path);
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((e) => Word(
              (e as Map<String, dynamic>)['text'] as String,
              e['meaning'] as String,
            ))
        .toList();
  }
}
