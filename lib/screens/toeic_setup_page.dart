import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';
import '../storage.dart';
import 'wordbook_page.dart';

class ToeicSetupPage extends StatefulWidget {
  final Language language;
  final Category category;

  const ToeicSetupPage({
    super.key,
    required this.language,
    required this.category,
  });

  @override
  State<ToeicSetupPage> createState() => _ToeicSetupPageState();
}

class _ToeicSetupPageState extends State<ToeicSetupPage> {
  ToeicLevel? _level;
  final TextEditingController _targetController = TextEditingController();
  DateTime? _examDate;

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _examDate = picked);
    }
  }

  bool get _isValid {
    if (_level == null || _examDate == null) return false;
    final target = int.tryParse(_targetController.text);
    if (target == null) return false;
    if (target < 10 || target > 990) return false;
    return true;
  }

  Future<void> _submit() async {
    if (!_isValid) return;
    final profile = ToeicProfile(
      level: _level!,
      targetScore: int.parse(_targetController.text),
      examDate: _examDate!,
      startDate: DateTime.now(),
    );
    await profile.save();
    await saveSelection(widget.language.code, widget.category.id);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            WordbookPage(category: widget.category, toeic: profile),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _examDate == null
        ? '날짜 선택'
        : '${_examDate!.year}.${_examDate!.month.toString().padLeft(2, '0')}.${_examDate!.day.toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('TOEIC 설정'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('현재 점수대'),
          const SizedBox(height: 8),
          RadioGroup<ToeicLevel>(
            groupValue: _level,
            onChanged: (v) => setState(() => _level = v),
            child: Column(
              children: ToeicLevel.values
                  .map(
                    (lvl) => RadioListTile<ToeicLevel>(
                      value: lvl,
                      title: Text(lvl.label),
                      subtitle: Text(lvl.description),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('목표 점수'),
          const SizedBox(height: 8),
          TextField(
            controller: _targetController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '예: 800',
              suffixText: '점',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('시험 날짜'),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
            label: Text(dateLabel),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _isValid ? _submit : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('시작하기'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
