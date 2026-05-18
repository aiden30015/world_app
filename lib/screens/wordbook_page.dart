import 'package:flutter/material.dart';

import '../models.dart';
import '../routines.dart';
import '../storage.dart';
import 'language_selection_page.dart';
import 'spelling_quiz_page.dart';

class WordbookPage extends StatelessWidget {
  final Category category;
  final ToeicProfile? toeic;

  const WordbookPage({super.key, required this.category, this.toeic});

  List<Word> get _todayWords =>
      toeic != null ? toeic!.todayWords : category.words;

  List<Word> get _reviewWords => toeic?.yesterdayWords ?? const [];

  List<Word> get _quizWords => [..._reviewWords, ..._todayWords];

  Future<void> _changeCategory(BuildContext context) async {
    await clearAllSelection();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LanguageSelectionPage()),
      (route) => false,
    );
  }

  void _startQuiz(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SpellingQuizPage(words: _quizWords)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = _todayWords;
    final review = _reviewWords;
    final isEmpty = today.isEmpty && review.isEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _changeCategory(context),
            icon: const Icon(Icons.swap_horiz),
            tooltip: '언어/용도 변경',
          ),
        ],
      ),
      body: Column(
        children: [
          if (toeic != null)
            _ToeicHeader(
              profile: toeic!,
              todayCount: today.length,
              reviewCount: review.length,
            ),
          Expanded(
            child: isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        '오늘 학습할 단어가 없어요.\n시험 날짜가 지났거나 모두 학습했습니다.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView(
                    children: [
                      if (toeic != null) ...[
                        _RoutineCard(
                          steps: buildRoutine(
                            toeic!,
                            today.length,
                            review.length,
                          ),
                        ),
                        _TipCard(
                          tip: getTodayTip(toeic!.level, DateTime.now()),
                        ),
                      ],
                      if (review.isNotEmpty) ...[
                        const _SectionHeader(
                          icon: Icons.history,
                          title: '어제 복습',
                        ),
                        ..._wordTiles(review),
                      ],
                      if (today.isNotEmpty) ...[
                        _SectionHeader(
                          icon: Icons.today,
                          title: toeic != null ? '오늘 새 단어' : '단어',
                        ),
                        ..._wordTiles(today),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _startQuiz(context),
              icon: const Icon(Icons.quiz),
              label: Text('철자 퀴즈 (${_quizWords.length})'),
            ),
    );
  }

  List<Widget> _wordTiles(List<Word> words) {
    return List.generate(words.length, (index) {
      final word = words[index];
      return ListTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text(
          word.text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(word.meaning),
      );
    });
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final List<RoutineStep> steps;

  const _RoutineCard({required this.steps});

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        elevation: 0,
        color: scheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 18, color: scheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '오늘의 학습 루틴',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(steps.length, (i) {
                final step = steps[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(step.icon, size: 18, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              step.detail,
                              style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final StudyTip tip;

  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        elevation: 0,
        color: scheme.tertiaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: scheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '오늘의 학습 팁',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: scheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                tip.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: scheme.onTertiaryContainer,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tip.body,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: scheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToeicHeader extends StatelessWidget {
  final ToeicProfile profile;
  final int todayCount;
  final int reviewCount;

  const _ToeicHeader({
    required this.profile,
    required this.todayCount,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    final days = profile.daysUntilExam;
    final dayText = days > 0
        ? 'D-$days'
        : days == 0
            ? 'D-Day'
            : 'D+${-days}';
    final parts = [
      profile.level.label,
      '오늘 $todayCount개',
      if (reviewCount > 0) '복습 $reviewCount개',
    ];
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dayText,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '목표 ${profile.targetScore}점',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(parts.join(' · '), style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
