import 'package:flutter/material.dart';

class Word {
  final String text;
  final List<String> meanings;

  const Word(this.text, this.meanings);

  String get displayMeaning => meanings.join(' / ');
}

class Category {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  bool get requiresToeicSetup => id == 'toeic';
}

class Language {
  final String code;
  final String name;
  final String flag;
  final List<Category> categories;
  final bool available;

  const Language({
    required this.code,
    required this.name,
    required this.flag,
    required this.categories,
    this.available = true,
  });
}

enum ToeicLevel {
  none('시험 경험 없음', '아직 응시 경험이 없어요'),
  lv200('0 ~ 200점', '입문'),
  lv500('201 ~ 500점', '기초'),
  lv700('501 ~ 700점', '중급'),
  lv700plus('701점 이상', '고급');

  final String label;
  final String description;

  const ToeicLevel(this.label, this.description);
}
