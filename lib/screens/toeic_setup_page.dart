import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';
import '../storage.dart';
import '../theme.dart';
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

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TOEIC')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  const PageHeader(
                    title: '시험 정보를\n알려주세요',
                    subtitle: '점수대와 일정에 맞춰 학습 계획을 만들어드려요',
                    padding: EdgeInsets.fromLTRB(4, 0, 4, 28),
                  ),
                  const _StepLabel(step: 1, title: '현재 점수대'),
                  const SizedBox(height: 12),
                  ...ToeicLevel.values.map(
                    (lvl) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _LevelOption(
                        level: lvl,
                        selected: _level == lvl,
                        onTap: () => setState(() => _level = lvl),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _StepLabel(step: 2, title: '목표 점수'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: const InputDecoration(
                      hintText: '예: 800',
                      suffixText: '점',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                  const _StepLabel(step: 3, title: '시험 날짜'),
                  const SizedBox(height: 12),
                  _DateSelector(
                    label: _examDate == null
                        ? '날짜를 선택하세요'
                        : _formatDate(_examDate!),
                    selected: _examDate != null,
                    onTap: _pickDate,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isValid ? _submit : null,
                  child: const Text('학습 시작하기'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  final int step;
  final String title;

  const _StepLabel({required this.step, required this.title});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$step',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _LevelOption extends StatelessWidget {
  final ToeicLevel level;
  final bool selected;
  final VoidCallback onTap;

  const _LevelOption({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? scheme.primary : kBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? scheme.primary : kMuted,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: selected ? scheme.primary : kInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      level.description,
                      style: const TextStyle(fontSize: 12, color: kMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DateSelector({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? scheme.primary : kBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: selected ? scheme.primary : kMuted,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: selected ? kInk : kMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
