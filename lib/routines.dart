import 'package:flutter/material.dart';

import 'models.dart';
import 'storage.dart';

class StudyTip {
  final String title;
  final String body;

  const StudyTip(this.title, this.body);
}

class RoutineStep {
  final IconData icon;
  final String label;
  final String detail;

  const RoutineStep({
    required this.icon,
    required this.label,
    required this.detail,
  });
}

const Map<ToeicLevel, List<StudyTip>> tipsByLevel = {
  ToeicLevel.none: [
    StudyTip(
      '매일 같은 시간 5분',
      '시작이 막막하다면 시간만 잡으세요. 매일 같은 시간 5분이 한 달 후 큰 차이를 만듭니다.',
    ),
    StudyTip(
      '소리내어 발음하기',
      '단어를 외울 때 입으로 따라 읽으면 듣기에도 도움이 됩니다.',
    ),
    StudyTip(
      '뜻 → 단어 순서로 익히기',
      '한국어 뜻을 보고 영단어를 떠올리는 연습이 실제 회화·작문에 직결됩니다.',
    ),
    StudyTip(
      '완벽보다 반복',
      '오늘 다 못 외워도 됩니다. 내일 또 봐도 됩니다. 횟수가 실력입니다.',
    ),
    StudyTip(
      '오답 노트 만들기',
      '퀴즈에서 틀린 단어는 따로 적어두고 다음날 가장 먼저 보세요.',
    ),
  ],
  ToeicLevel.lv200: [
    StudyTip(
      '비즈니스 기본 어휘 우선',
      'office, meeting, report 같은 빈출 단어는 LC·RC 어디든 나옵니다. 먼저 잡으세요.',
    ),
    StudyTip(
      '한 단어 → 여러 품사',
      'order는 명사(주문)이자 동사(주문하다). 같이 외우면 효율이 두 배입니다.',
    ),
    StudyTip(
      'Part 5 먼저 손대기',
      '문법·어휘 한 문장짜리 문제부터 풀면 점수 올리기 쉽습니다.',
    ),
    StudyTip(
      '받아쓰기 5분',
      'LC 음원을 듣고 한 문장이라도 받아 적어보세요. 익숙한 단어도 못 듣는 경우가 많습니다.',
    ),
    StudyTip(
      '한 번에 10개씩',
      '20개 외우려다 0개 되는 것보다 10개를 확실히가 낫습니다.',
    ),
  ],
  ToeicLevel.lv500: [
    StudyTip(
      '동의어·반의어 묶기',
      '토익은 패러프레이징 천국입니다. raise = increase = boost를 함께 외우세요.',
    ),
    StudyTip(
      '지문 속 모르는 단어 표시',
      'RC 풀고 나서 표시한 단어만 따로 모아 외우면 실전 어휘가 쌓입니다.',
    ),
    StudyTip(
      'collocation 의식하기',
      'make a decision, take a break — 단어 단위가 아닌 묶음으로 외우세요.',
    ),
    StudyTip(
      '주말엔 누적 복습',
      '월~금 새 단어, 토~일은 그 주에 본 단어 전체 한 번씩 다시.',
    ),
    StudyTip(
      'LC 오답률 점검',
      'Part 3·4에서 동일 유형이 반복 틀린다면 어휘보다 청취 훈련을 늘리세요.',
    ),
  ],
  ToeicLevel.lv700: [
    StudyTip(
      '단어보다 미묘한 차이',
      'effective vs efficient, ensure vs assure. 비슷한 단어 구분이 700 → 800의 핵심.',
    ),
    StudyTip(
      'collocation 본격적으로',
      'submit a proposal, reach a conclusion. 동사+명사 짝을 외우면 작문도 자연스러워집니다.',
    ),
    StudyTip(
      '비즈니스 영문 메일 읽기',
      '실전 어휘는 살아있는 텍스트에서 가장 빨리 흡수됩니다.',
    ),
    StudyTip(
      '시간 압박 훈련',
      'Part 7 한 지문당 시간을 정해놓고 풀어야 어휘력이 점수로 바뀝니다.',
    ),
    StudyTip(
      'idiom·구동사 비중 올리기',
      'put off, look into, come up with — 이 영역에서 점수가 갈립니다.',
    ),
  ],
  ToeicLevel.lv700plus: [
    StudyTip(
      '단어 자체보단 문맥 추론',
      '900 이상은 모르는 단어가 나와도 문맥에서 의미를 잡는 속도 게임입니다.',
    ),
    StudyTip(
      '신문·기사 일상화',
      'BBC, Reuters 비즈니스 섹션 하루 하나. 단어가 살아 움직입니다.',
    ),
    StudyTip(
      'Part 7 스키밍·스캐닝',
      '어휘력은 충분합니다. 시간 분배와 문제 유형 패턴이 만점을 가릅니다.',
    ),
    StudyTip(
      '학술 어휘 보충',
      'comprise, constitute, attribute 같은 격식 어휘를 추가로 잡으세요.',
    ),
    StudyTip(
      '오답 단어 정리는 한 줄로',
      '이 단계에선 노트가 길어지면 안 봅니다. 한 줄 메모만.',
    ),
  ],
};

StudyTip getTodayTip(ToeicLevel level, DateTime today) {
  final tips = tipsByLevel[level];
  if (tips == null || tips.isEmpty) {
    return const StudyTip('학습 시작', '오늘도 한 단어부터.');
  }
  final dayOfYear =
      today.difference(DateTime(today.year, 1, 1)).inDays;
  return tips[dayOfYear % tips.length];
}

List<RoutineStep> buildRoutine(
  ToeicProfile profile,
  int todayCount,
  int reviewCount,
) {
  final steps = <RoutineStep>[];
  if (reviewCount > 0) {
    steps.add(
      RoutineStep(
        icon: Icons.history,
        label: '복습',
        detail: '어제 단어 $reviewCount개 다시 보기',
      ),
    );
  }
  if (todayCount > 0) {
    steps.add(
      RoutineStep(
        icon: Icons.book_outlined,
        label: '학습',
        detail: '오늘 새 단어 $todayCount개',
      ),
    );
  }
  final quizCount = todayCount + reviewCount;
  if (quizCount > 0) {
    steps.add(
      RoutineStep(
        icon: Icons.quiz,
        label: '점검',
        detail: '철자 퀴즈로 $quizCount개 확인',
      ),
    );
  }
  final daysLeft = profile.daysUntilExam;
  if (daysLeft > 0 && daysLeft <= 7) {
    steps.add(
      RoutineStep(
        icon: Icons.flag,
        label: '시험 임박',
        detail: 'D-$daysLeft · 전체 단어 빠르게 훑기',
      ),
    );
  }
  return steps;
}
