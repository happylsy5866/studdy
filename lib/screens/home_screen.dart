import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> todoList;
  final int totalSeconds;
  final bool isRunning;
  final VoidCallback onToggle;

  const HomeScreen({
    super.key,
    required this.todoList,
    required this.totalSeconds,
    required this.isRunning,
    required this.onToggle,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String getTodayDate() {
    DateTime now = DateTime.now();
    String dayOfWeek = ['월', '화', '수', '목', '금', '토', '일'][now.weekday - 1];
    return DateFormat('yyyy.MM.dd ($dayOfWeek)').format(now);
  }

// 시간 계산
  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  //성취율 계산
  int calculateAchievement() {
    if (widget.todoList.isEmpty) return 0;
    int doneCount = widget.todoList.where((item) => item['isDone'] == true).length;
    return ((doneCount / widget.todoList.length) * 100).round(); //소수점 반올림
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(getTodayDate(), style: const TextStyle(fontSize: 18, color: Colors.black54)),
                  const Icon(Icons.settings, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 40),

              Center(
                child: Column(
                  children: [
                    const Text("공부 시간", style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Text(_formatTime(widget.totalSeconds), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300)),
                    const SizedBox(height: 10),
                    IconButton(
                      onPressed: widget.onToggle,
                      icon: Icon(
                        widget.isRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        size: 50,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                        "성취율 ${calculateAchievement()}%",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              const Text("To Do List", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              Expanded(
                child: widget.todoList.isEmpty
                    ? const Center(child: Text("오늘 일정이 없습니다.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                  itemCount: widget.todoList.length,
                  itemBuilder: (context, index) {
                    final item = widget.todoList[index];
                    final isDone = item['isDone'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDone ? Colors.green.shade50 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDone ? Colors.green.shade200 : Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.todoList[index]['isDone'] = !isDone;
                              });
                            },
                            child: Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone ? Colors.green : Colors.transparent,
                                border: Border.all(color: isDone ? Colors.green : Colors.grey, width: 2),
                              ),
                              child: isDone ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              item['title'],
                              style: TextStyle(
                                fontSize: 16,
                                color: isDone ? Colors.grey : Colors.black87,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}