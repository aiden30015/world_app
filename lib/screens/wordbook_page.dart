import 'package:flutter/material.dart';

import '../models.dart';
import '../routines.dart';
import '../storage.dart';
import '../theme.dart';
import '../word_bank.dart';
import 'language_selection_page.dart';
import 'spelling_quiz_page.dart';

class WordbookPage extends StatelessWidget {
  final Category category;
  final ToeicProfile? toeic;

  const WordbookPage({super.key, required this.category, this.toeic});

  List<Word> get _todayWords =>
      toeic != null ? toeic!.todayWords : WordBank.forCategory(category.id);

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
        actions: [
          IconButton(
            onPressed: () => _changeCategory(context),
            icon: const Icon(Icons.tune, size: 20),
            tooltip: '언어/용도 변경',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: isEmpty
            ? const _EmptyState()
            : ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  if (toeic != null)
                    _ToeicHero(
                      profile: toeic!,
                      todayCount: today.length,
                      reviewCount: review.length,
                    ),
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
                  ] else
                    const SizedBox(height: 8),
                  if (review.isNotEmpty) ...[
                    const _SectionLabel(title: '어제 복습'),
                    _WordList(words: review),
                  ],
                  if (today.isNotEmpty) ...[
                    _SectionLabel(
                      title: toeic != null ? '오늘 새 단어' : '단어',
                    ),
                    _WordList(words: today),
                  ],
                ],
              ),
      ),
      bottomNavigationBar: isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _startQuiz(context),
                    icon: const Icon(Icons.bolt, size: 18),
                    label: Text('철자 퀴즈 시작 · ${_quizWords.length}개'),
                  ),
                ),
              ),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration_outlined, size: 56, color: kMuted),
            const SizedBox(height: 16),
            Text(
              '오늘 학습할 단어가 없어요',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              '시험 날짜가 지났거나\n모든 단어를 학습했습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kMuted, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToeicHero extends StatelessWidget {
  final ToeicProfile profile;
  final int todayCount;
  final int reviewCount;

  const _ToeicHero({
    required this.profile,
    required this.todayCount,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final days = profile.daysUntilExam;
    final dayLabel = days > 0
        ? 'D-$days'
        : days == 0
            ? 'D-DAY'
            : 'D+${-days}';
    final subtitle = days > 0
        ? '시험까지 $days일 남았어요'
        : days == 0
            ? '오늘이 시험일이에요'
            : '시험이 종료되었어요';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.primary.withValues(alpha: 0.82)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _OnPrimaryPill(text: profile.level.label),
              const SizedBox(width: 6),
              _OnPrimaryPill(text: '목표 ${profile.targetScore}점'),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            dayLabel,
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _HeroStat(label: '오늘', value: '$todayCount개'),
              const SizedBox(width: 12),
              Container(width: 1, height: 28, color: Colors.white24),
              const SizedBox(width: 12),
              _HeroStat(label: '복습', value: '$reviewCount개'),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnPrimaryPill extends StatelessWidget {
  final String text;
  const _OnPrimaryPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.75),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: scheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    '오늘의 학습 루틴',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (int i = 0; i < steps.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _RoutineStepRow(index: i + 1, step: steps[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutineStepRow extends StatelessWidget {
  final int index;
  final RoutineStep step;

  const _RoutineStepRow({required this.index, required this.step});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$index',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: scheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(step.icon, size: 16, color: kMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kInk,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                step.detail,
                style: const TextStyle(fontSize: 12, color: kMuted),
              ),
            ],
          ),
        ),
      ],
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: scheme.onTertiaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  '오늘의 학습 팁',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              tip.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: scheme.onTertiaryContainer,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tip.body,
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                color: scheme.onTertiaryContainer.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: kMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _WordList extends StatelessWidget {
  final List<Word> words;
  const _WordList({required this.words});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        child: Column(
          children: [
            for (int i = 0; i < words.length; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
              _WordTile(index: i + 1, word: words[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _WordTile extends StatelessWidget {
  final int index;
  final Word word;
  const _WordTile({required this.index, required this.word});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kMuted,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  word.displayMeaning,
                  style: const TextStyle(fontSize: 13, color: kMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
