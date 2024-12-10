import 'package:flutter/material.dart';

// 一定要有个类,才能List<TodoItemMap>
class TodoItemMap {
  TodoItemMap({
    required this.id,
    required this.value,
    required this.isChecked,
    required this.errorText,
    this.dueDate,
    this.note = '',
    this.reward = '',
  });

  final int id;
  String value;
  bool isChecked;
  String? errorText;
  DateTime? dueDate;
  String note;
  String reward;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "value": value,
      "isChecked": isChecked,
      "errorText": errorText,
      "dueDate": dueDate?.toIso8601String(),
      "note": note,
      "reward": reward,
    };
  }

  factory TodoItemMap.fromMap(Map map) {
    return TodoItemMap(
      id: map['id'],
      value: map['value'],
      isChecked: map['isChecked'],
      errorText: map['errorText'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      note: map['note'] ?? '',
      reward: map['reward'] ?? '',
    );
  }
}

typedef CheckBeforeSubmit = Function(String value, TodoItemMap item);
typedef OnChanged = Function(bool boolean, TodoItemMap item);
typedef Remove = Function(TodoItemMap item);
// 在TodoItem类中，build方法返回一个Row组件，包含复选框、文本或文本输入框以及一个删除按钮
class TodoItem extends StatelessWidget {
  TodoItem(
      {required this.data,
      required this.onChanged,
      required this.checkBeforeSubmit,
      required this.remove})
      : super(key: ObjectKey(data));

  final TodoItemMap data;
  final OnChanged onChanged;
  final CheckBeforeSubmit checkBeforeSubmit;
  final Remove remove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Checkbox(
              value: data.isChecked,
              onChanged: (boolean) => onChanged(boolean!, data)),
          Expanded(
              child: data.isChecked
                  ? Text(
                      data.value,
                      style: data.isChecked
                          ? const TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.lineThrough)
                          : null,
                    )
                  : Container(
                      margin: const EdgeInsets.only(right: 20),
                      child: TextField(
                          controller: TextEditingController.fromValue(
                              TextEditingValue(text: data.value)),
                          decoration: InputDecoration(
                            hintText: '请输入内容',
                            errorText: data.errorText,
                          ),
                          onSubmitted: (String value) {
                            checkBeforeSubmit(value, data);
                          }))),
          ElevatedButton(
            onPressed: () {
              remove(data);
            },
            child: const Text('删除'),
          )
        ]),
        if (data.dueDate != null || data.note.isNotEmpty || data.reward.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.dueDate != null)
                  Text('截止日期: ${data.dueDate!.toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (data.note.isNotEmpty)
                  Text('备注: ${data.note}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (data.reward.isNotEmpty)
                  Text('奖励: ${data.reward}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
      ],
    );
  }
}
