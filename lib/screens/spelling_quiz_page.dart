import 'dart:math';

import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';

class SpellingQuizPage extends StatefulWidget {
  final List<Word> words;

  const SpellingQuizPage({super.key, required this.words});

  @override
  State<SpellingQuizPage> createState() => _SpellingQuizPageState();
}

class _SpellingQuizPageState extends State<SpellingQuizPage> {
  late final List<Word> _shuffled;
  final TextEditingController _input = TextEditingController();
  final FocusNode _focus = FocusNode();
  int _index = 0;
  int _correct = 0;
  bool? _lastResult;
  String? _lastAnswer;

  @override
  void initState() {
    super.initState();
    _shuffled = [...widget.words]..shuffle(Random());
  }

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _check() {
    if (_lastResult != null) return;
    final guess = _input.text.trim().toLowerCase();
    if (guess.isEmpty) return;
    final answer = _shuffled[_index].text.trim().toLowerCase();
    final isCorrect = guess == answer;
    setState(() {
      _lastResult = isCorrect;
      _lastAnswer = _shuffled[_index].text;
      if (isCorrect) _correct++;
    });
  }

  void _next() {
    if (_index + 1 >= _shuffled.length) {
      setState(() => _index++);
      return;
    }
    setState(() {
      _index++;
      _lastResult = null;
      _lastAnswer = null;
      _input.clear();
    });
    _focus.requestFocus();
  }

  void _restart() {
    setState(() {
      _shuffled.shuffle(Random());
      _index = 0;
      _correct = 0;
      _lastResult = null;
      _lastAnswer = null;
      _input.clear();
    });
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    if (_shuffled.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('철자 퀴즈')),
        body: const Center(child: Text('출제할 단어가 없어요.')),
      );
    }
    if (_index >= _shuffled.length) {
      return _buildResult(context);
    }
    return _buildQuestion(context);
  }

  Widget _buildQuestion(BuildContext context) {
    final word = _shuffled[_index];
    final answered = _lastResult != null;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_index + 1} / ${_shuffled.length}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: (_index + (answered ? 1 : 0)) / _shuffled.length,
                  minHeight: 6,
                  backgroundColor: kSubtle,
                  valueColor: AlwaysStoppedAnimation(scheme.primary),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '이 뜻에 맞는 영단어는?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 36,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kBorder),
                      ),
                      child: Center(
                        child: Text(
                          word.meaning,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: kInk,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _input,
                      focusNode: _focus,
                      enabled: !answered,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _check(),
                      decoration: const InputDecoration(
                        hintText: '영단어 입력',
                      ),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: kInk,
                      ),
                    ),
                    if (answered) ...[
                      const SizedBox(height: 16),
                      _FeedbackPanel(
                        correct: _lastResult!,
                        answer: _lastAnswer!,
                      ),
                    ],
                    const Spacer(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: answered ? _next : _check,
                  child: Text(
                    answered
                        ? (_index + 1 >= _shuffled.length ? '결과 보기' : '다음 문제')
                        : '확인',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rate = (_correct * 100 / _shuffled.length).round();
    return Scaffold(
      appBar: AppBar(title: const Text('퀴즈 결과')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.emoji_events_outlined,
                  size: 48,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '$rate%',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: scheme.primary,
                  letterSpacing: -2,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_correct / ${_shuffled.length} 정답',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kMuted,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _restart,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('다시 풀기'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('단어장으로 돌아가기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  final bool correct;
  final String answer;

  const _FeedbackPanel({required this.correct, required this.answer});

  @override
  Widget build(BuildContext context) {
    final bg = correct ? const Color(0xFFE9F7EF) : const Color(0xFFFDECEC);
    final fg = correct ? const Color(0xFF166534) : const Color(0xFF991B1B);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            correct ? Icons.check_circle : Icons.cancel,
            color: fg,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              correct ? '정답이에요!' : '정답: $answer',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
