import 'dart:math';

import 'package:flutter/material.dart';

import '../models.dart';

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
      return Scaffold(
        appBar: AppBar(
          title: const Text('퀴즈 결과'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              const SizedBox(height: 16),
              Text(
                '$_correct / ${_shuffled.length}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '정답률 ${(_correct * 100 / _shuffled.length).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 풀기'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('단어장으로 돌아가기'),
              ),
            ],
          ),
        ),
      );
    }

    final word = _shuffled[_index];
    final answered = _lastResult != null;
    return Scaffold(
      appBar: AppBar(
        title: Text('철자 퀴즈 (${_index + 1}/${_shuffled.length})'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_index + (answered ? 1 : 0)) / _shuffled.length,
            ),
            const SizedBox(height: 32),
            const Text(
              '다음 뜻에 해당하는 단어는?',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              word.meaning,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _input,
              focusNode: _focus,
              enabled: !answered,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _check(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '영단어를 입력하세요',
              ),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            if (answered) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _lastResult!
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _lastResult! ? Icons.check_circle : Icons.cancel,
                      color: _lastResult! ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _lastResult!
                            ? '정답!'
                            : '오답 — 정답: $_lastAnswer',
                        style: TextStyle(
                          fontSize: 16,
                          color: _lastResult!
                              ? Colors.green.shade900
                              : Colors.red.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _next,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _index + 1 >= _shuffled.length ? '결과 보기' : '다음',
                ),
              ),
            ] else
              FilledButton(
                onPressed: _check,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('확인'),
              ),
          ],
        ),
      ),
    );
  }
}
