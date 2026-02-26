import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class PlanScreen extends StatefulWidget {
  final Function(String title, String dailyGoal, bool navigateHome) onAddPlan;
  // [추가] 기존 데이터를 받기 위한 변수들
  final Map<String, dynamic>? initialData;
  final int? index;

  const PlanScreen({
    super.key,
    required this.onAddPlan,
    this.initialData, // 수정 시 전달받음
    this.index,       // 수정 시 전달받음
  });

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late final TextEditingController _titleController;
  final TextEditingController _startRangeController = TextEditingController();
  final TextEditingController _endRangeController = TextEditingController();

  String _selectedUnit = '쪽';
  final List<String> _unitList = ['쪽', '단원', '강'];

  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  final Set<int> _blockedWeekdays = {};
  int _selectedCount = 1;
  final List<int> _countList = [1, 2, 3, 4, 5];

  // [추가] 수정 모드인지 확인
  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    // 수정 모드라면 기존 제목을 채워줌
    _titleController = TextEditingController(
      text: _isEditing ? widget.initialData!['title'].toString().split(' (')[0] : "",
    );
  }

  String _calculateDailyGoal() {
    if (_startRangeController.text.isEmpty ||
        _endRangeController.text.isEmpty ||
        _rangeStart == null ||
        _rangeEnd == null) {
      return "정보를 모두 입력하면 하루 목표량이 계산됩니다.";
    }

    try {
      int start = int.parse(_startRangeController.text);
      int end = int.parse(_endRangeController.text);
      int totalAmount = (end - start + 1) * _selectedCount;

      int studyDays = 0;
      DateTime current = _rangeStart!;
      DateTime endLoop = _rangeEnd!.add(const Duration(days: 1));

      while (current.isBefore(endLoop)) {
        if (!_blockedWeekdays.contains(current.weekday)) {
          studyDays++;
        }
        current = current.add(const Duration(days: 1));
      }

      if (studyDays == 0) return "공부할 수 있는 날이 없습니다.";

      double dailyGoal = totalAmount / studyDays;

      return "총 $totalAmount$_selectedUnit을 $studyDays일 동안 공부해요.\n"
          "하루에 약 ${dailyGoal.ceil()}$_selectedUnit씩 공부하면 됩니다!";

    } catch (e) {
      return "숫자만 입력해주세요.";
    }
  }

  String? _getDailyGoalShortString() {
    try {
      int start = int.parse(_startRangeController.text);
      int end = int.parse(_endRangeController.text);
      int totalAmount = (end - start + 1) * _selectedCount;

      int studyDays = 0;
      DateTime current = _rangeStart!;
      DateTime endLoop = _rangeEnd!.add(const Duration(days: 1));

      while (current.isBefore(endLoop)) {
        if (!_blockedWeekdays.contains(current.weekday)) studyDays++;
        current = current.add(const Duration(days: 1));
      }

      if (studyDays == 0) return null;
      double dailyGoal = totalAmount / studyDays;

      return "${dailyGoal.ceil()}$_selectedUnit";
    } catch (e) {
      return null;
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_isEditing ? "수정 완료!" : "일정 생성 완료!"),
          content: Text(_isEditing
              ? "변경사항을 저장하고\n홈 화면으로 이동하시겠습니까?"
              : "홈 화면으로 이동하여\n투두리스트를 확인하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                String goal = _getDailyGoalShortString() ?? "목표";
                widget.onAddPlan(_titleController.text, goal, false);
                Navigator.pop(context);
                if (!_isEditing) {
                  _titleController.clear();
                  _startRangeController.clear();
                  _endRangeController.clear();
                }
              },
              child: const Text("아니요"),
            ),
            TextButton(
              onPressed: () {
                String goal = _getDailyGoalShortString() ?? "목표";
                widget.onAddPlan(_titleController.text, goal, true);
                Navigator.pop(context);
                // 수정 모드인 경우 현재 페이지도 닫아줌
                if (_isEditing) Navigator.pop(context);
              },
              child: const Text("네, 이동합니다", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_isEditing ? '계획 수정하기' : '계획 추가하기'),
          centerTitle: true
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle("제목"),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              const SizedBox(height: 24),

              _buildTitle("범위"),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startRangeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(hintText: "시작", border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("~")),
                  Expanded(
                    child: TextField(
                      controller: _endRangeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(hintText: "끝", border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedUnit,
                    items: _unitList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => _selectedUnit = val!),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildTitle("기간 설정"),
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                child: TableCalendar(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  focusedDay: _focusedDay,
                  rangeSelectionMode: RangeSelectionMode.toggledOn,
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,
                  onRangeSelected: (start, end, focusedDay) {
                    setState(() {
                      _rangeStart = start;
                      _rangeEnd = end;
                      _focusedDay = focusedDay;
                    });
                  },
                  headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false),
                ),
              ),
              const SizedBox(height: 24),

              _buildTitle("Block 요일"),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDayButton("월", 1),
                  _buildDayButton("화", 2),
                  _buildDayButton("수", 3),
                  _buildDayButton("목", 4),
                  _buildDayButton("금", 5),
                  _buildDayButton("토", 6),
                  _buildDayButton("일", 7),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  _buildTitle("목표 회독수:  "),
                  DropdownButton<int>(
                    value: _selectedCount,
                    items: _countList.map((e) => DropdownMenuItem(value: e, child: Text("$e회독"))).toList(),
                    onChanged: (val) => setState(() => _selectedCount = val!),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  _calculateDailyGoal(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isEmpty || _getDailyGoalShortString() == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("모든 정보를 올바르게 입력해주세요.")),
                      );
                      return;
                    }
                    _showConfirmationDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                      _isEditing ? "수정 완료" : "추가하기",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDayButton(String dayStr, int weekday) {
    final isBlocked = _blockedWeekdays.contains(weekday);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isBlocked) {
            _blockedWeekdays.remove(weekday);
          } else {
            _blockedWeekdays.add(weekday);
          }
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isBlocked ? Colors.redAccent : Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            dayStr,
            style: TextStyle(
              color: isBlocked ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}