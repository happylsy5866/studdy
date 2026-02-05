import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'graph_screen.dart';
import 'plan_screen.dart';
import 'calendar_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _totalSeconds = 0;
  int _savedSeconds = 0;
  int _savedRate = 0;

  Timer? _timer;
  bool _isRunning = false;

  int _calculateAchievement() {
    if (_globalTodoList.isEmpty) return 0;
    int doneCount = _globalTodoList.where((item) => item['isDone'] == true).length;
    return ((doneCount / _globalTodoList.length) * 100).round();
  }

  void _toggleTimer() {
    setState(() {
      if (_isRunning) {
        _timer?.cancel();
        _savedSeconds = _totalSeconds;
        _savedRate = _calculateAchievement();

      } else {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _totalSeconds++;
          });
        });
      }
      _isRunning = !_isRunning;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  final List<Map<String, dynamic>> _globalTodoList = [
    {'title': '영어 (29쪽)', 'isDone': false},
  ];

  void _addNewPlan(String title, String dailyGoal, bool goHome) {
    setState(() {
      _globalTodoList.add({
        'title': '$title ($dailyGoal)',
        'isDone': false,
      });

      if (goHome) {
        _selectedIndex = 0;
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        todoList: _globalTodoList,
        totalSeconds: _totalSeconds,
        isRunning: _isRunning,
        onToggle: _toggleTimer,
      ),
      const GraphScreen(),
      PlanScreen(onAddPlan: _addNewPlan),
      CalendarPage(
        todaySeconds: _savedSeconds,
        todayRate: _savedRate,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: '그래프'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: '추가'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '달력'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}