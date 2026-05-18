import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';
import 'models.dart';

const String prefLangKey = 'selected_language';
const String prefCategoryKey = 'selected_category';

Language? findLanguage(String? code) {
  if (code == null) return null;
  for (final lang in languages) {
    if (lang.code == code) return lang;
  }
  return null;
}

Category? findCategory(Language? lang, String? id) {
  if (lang == null || id == null) return null;
  for (final cat in lang.categories) {
    if (cat.id == id) return cat;
  }
  return null;
}

Future<void> saveSelection(String langCode, String categoryId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(prefLangKey, langCode);
  await prefs.setString(prefCategoryKey, categoryId);
}

Future<void> clearAllSelection() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(prefLangKey);
  await prefs.remove(prefCategoryKey);
  await ToeicProfile.clear();
}

class ToeicProfile {
  final ToeicLevel level;
  final int targetScore;
  final DateTime examDate;
  final DateTime startDate;

  const ToeicProfile({
    required this.level,
    required this.targetScore,
    required this.examDate,
    required this.startDate,
  });

  static const _levelKey = 'toeic_level';
  static const _targetKey = 'toeic_target';
  static const _examKey = 'toeic_exam';
  static const _startKey = 'toeic_start';

  static Future<ToeicProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final lvlName = prefs.getString(_levelKey);
    final target = prefs.getInt(_targetKey);
    final exam = prefs.getString(_examKey);
    final start = prefs.getString(_startKey);
    if (lvlName == null || target == null || exam == null || start == null) {
      return null;
    }
    final level = ToeicLevel.values.firstWhere(
      (e) => e.name == lvlName,
      orElse: () => ToeicLevel.none,
    );
    return ToeicProfile(
      level: level,
      targetScore: target,
      examDate: DateTime.parse(exam),
      startDate: DateTime.parse(start),
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_levelKey, level.name);
    await prefs.setInt(_targetKey, targetScore);
    await prefs.setString(_examKey, examDate.toIso8601String());
    await prefs.setString(_startKey, startDate.toIso8601String());
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_levelKey);
    await prefs.remove(_targetKey);
    await prefs.remove(_examKey);
    await prefs.remove(_startKey);
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  int get daysUntilExam =>
      _dateOnly(examDate).difference(_dateOnly(DateTime.now())).inDays;

  int get dayIndex =>
      _dateOnly(DateTime.now()).difference(_dateOnly(startDate)).inDays;

  int get totalDays =>
      _dateOnly(examDate).difference(_dateOnly(startDate)).inDays;

  List<Word> get allWords => toeicWordsByLevel[level] ?? const [];

  List<Word> _wordsForDay(int day) {
    final words = allWords;
    if (words.isEmpty || day < 0) return const [];
    final total = totalDays <= 0 ? 1 : totalDays;
    final perDay = (words.length / total).ceil().clamp(1, words.length);
    final start = day * perDay;
    if (start >= words.length) return const [];
    final end = (start + perDay).clamp(0, words.length);
    return words.sublist(start, end);
  }

  List<Word> get todayWords {
    final words = allWords;
    if (words.isEmpty) return const [];
    if (daysUntilExam <= 0) return words;
    return _wordsForDay(dayIndex.clamp(0, totalDays));
  }

  List<Word> get yesterdayWords {
    if (dayIndex <= 0) return const [];
    if (daysUntilExam <= 0) return const [];
    return _wordsForDay(dayIndex - 1);
  }
}
