import 'package:flutter/material.dart';
import 'package:bruno/bruno.dart';
import 'todo_item.dart';

class TaskDetailPage extends StatefulWidget {
  final TodoItemMap task;
  final Function(TodoItemMap task, {DateTime? dueDate, String? note, String? reward}) onUpdate;

  const TaskDetailPage({
    super.key, 
    required this.task,
    required this.onUpdate,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _rewardController;
  late TextEditingController _noteController;
  late DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.value);
    _rewardController = TextEditingController(text: widget.task.reward);
    _noteController = TextEditingController(text: widget.task.note);
    _selectedDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _rewardController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    widget.onUpdate(
      widget.task,
      dueDate: _selectedDate,
      note: _noteController.text,
      reward: _rewardController.text,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.pop(context);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 任务标题
              TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  widget.task.value = value;
                },
              ),
              
              const Divider(),
              
              // 截止日期
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(_selectedDate == null ? 
                  '添加截止日期' : 
                  '截止日期: ${_selectedDate!.toString().split(' ')[0]}'
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return BrnCalendarView(
                        displayMode: DisplayMode.month,
                        selectMode: SelectMode.single,
                        minDate: DateTime.now(),
                        maxDate: DateTime(2101),
                        dateChange: (DateTime date) {
                          setState(() {
                            _selectedDate = date;
                          });
                          Navigator.pop(context);
                        },
                      );
                    }
                  );
                },
              ),

              const Divider(),
              
              // 奖励
              ListTile(
                leading: const Icon(Icons.card_giftcard),
                title: TextField(
                  controller: _rewardController,
                  decoration: const InputDecoration(
                    hintText: '添加奖励',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const Divider(),
              
              // 备注
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '备注',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: '添加备注',
                        border: InputBorder.none,
                      ),
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