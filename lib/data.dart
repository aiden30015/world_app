import 'package:flutter/material.dart';

import 'models.dart';

const List<Category> englishCategories = [
  Category(
    id: 'basic',
    name: '기초',
    description: '입문자를 위한 기본 단어',
    icon: Icons.school,
  ),
  Category(
    id: 'conversation',
    name: '회화',
    description: '일상 대화 표현',
    icon: Icons.chat_bubble_outline,
  ),
  Category(
    id: 'toeic',
    name: 'TOEIC',
    description: '점수대별 비즈니스 영어',
    icon: Icons.business_center,
  ),
  Category(
    id: 'toefl',
    name: 'TOEFL',
    description: '학술 영어',
    icon: Icons.menu_book,
  ),
  Category(
    id: 'ielts',
    name: 'IELTS',
    description: '국제 영어 시험',
    icon: Icons.public,
  ),
  Category(
    id: 'csat',
    name: '수능',
    description: '대학수학능력시험',
    icon: Icons.edit_note,
  ),
];

const List<Language> languages = [
  Language(
    code: 'en',
    name: '영어',
    flag: '🇺🇸',
    categories: englishCategories,
  ),
  Language(
    code: 'ja',
    name: '일본어',
    flag: '🇯🇵',
    categories: [],
    available: false,
  ),
  Language(
    code: 'zh',
    name: '중국어',
    flag: '🇨🇳',
    categories: [],
    available: false,
  ),
];
