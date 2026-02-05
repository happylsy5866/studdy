import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/daily_record.dart';

class CalendarPage extends StatefulWidget {
  final int todaySeconds;
  final int todayRate;

  const CalendarPage({
    super.key,
    required this.todaySeconds,
    required this.todayRate,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  late final Map<DateTime, DailyRecord> _records;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _records = {
      today.subtract(const Duration(days: 1)): DailyRecord(studySeconds: 3600, achievementRate: 100),
      today.subtract(const Duration(days: 2)): DailyRecord(studySeconds: 7200, achievementRate: 70),
      today.subtract(const Duration(days: 3)): DailyRecord(studySeconds: 1800, achievementRate: 50),
      today.subtract(const Duration(days: 4)): DailyRecord(studySeconds: 900, achievementRate: 30),
      today.subtract(const Duration(days: 5)): DailyRecord(studySeconds: 0, achievementRate: 0),
    };
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Color _getHeatmapColor(int rate) {
    if (rate >= 100) return const Color(0xFFFF3CDE);
    if (rate >= 70) return const Color(0xFFFF64E6);
    if (rate >= 50) return const Color(0xFFFF85EB);
    if (rate >= 30) return const Color(0xFFFFB2F3);
    if (rate >= 10) return const Color(0xFFFFE2FB);
    return Colors.grey[100]!;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayKey = DateTime(now.year, now.month, now.day);

    final displayRecords = Map<DateTime, DailyRecord>.from(_records);
    displayRecords[todayKey] = DailyRecord(
      studySeconds: widget.todaySeconds,
      achievementRate: widget.todayRate,
    );

    final dateKey = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final selectedRecord = displayRecords[dateKey] ?? DailyRecord(studySeconds: 0, achievementRate: 0);

    final int totalSeconds = selectedRecord.studySeconds;
    final int h = totalSeconds ~/ 3600;
    final int m = (totalSeconds % 3600) ~/ 60;
    final int s = totalSeconds % 60;
    final String formattedTime =
        "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final record = displayRecords[DateTime(day.year, day.month, day.day)];
                  return _buildCalendarDay(day, record?.achievementRate ?? 0);
                },
                selectedBuilder: (context, day, focusedDay) {
                  final record = displayRecords[DateTime(day.year, day.month, day.day)];
                  return _buildCalendarDay(day, record?.achievementRate ?? 0, isSelected: true);
                },
                todayBuilder: (context, day, focusedDay) {
                  final record = displayRecords[DateTime(day.year, day.month, day.day)];
                  return _buildCalendarDay(day, record?.achievementRate ?? 0);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${_selectedDate.month}월 ${_selectedDate.day}일", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildStatItem("성취도", "${selectedRecord.achievementRate}%"),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      _buildStatItem("공부 시간", formattedTime),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(DateTime day, int achievement, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _getHeatmapColor(achievement),
        borderRadius: BorderRadius.circular(4),
        border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
      ),
      child: Center(
        child: Text('${day.day}', style: TextStyle(color: Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}