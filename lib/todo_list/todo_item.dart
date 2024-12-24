import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// 一定要有个类,才能List<TodoItemMap>
class TodoItemMap {
  TodoItemMap({
    String? uuid,
    required this.id,
    required this.value,
    required this.isChecked,
    required this.errorText,
    this.dueDate,
    this.note = '',
    this.reward = '',
    DateTime? createTime,
    DateTime? updateTime,
    this.syncStatus = 0,
  }) : 
    uuid = uuid ?? const Uuid().v4(),
    createTime = createTime ?? DateTime.now(),
    updateTime = updateTime ?? DateTime.now();

  final String uuid;
  final int id;
  String value;
  bool isChecked;
  String? errorText;
  DateTime? dueDate;
  String note;
  String reward;
  final DateTime createTime;
  DateTime updateTime;
  int syncStatus;

  Map<String, dynamic> toMap() {
    return {
      "uuid": uuid,
      "id": id,
      "value": value,
      "isChecked": isChecked ? 1 : 0,
      "errorText": errorText,
      "dueDate": dueDate?.toIso8601String(),
      "note": note,
      "reward": reward,
      "createTime": createTime.toIso8601String(),
      "updateTime": updateTime.toIso8601String(),
      "syncStatus": syncStatus,
    };
  }

  factory TodoItemMap.fromMap(Map map) {
    return TodoItemMap(
      uuid: map['uuid'] as String,
      id: map['id'] as int,
      value: map['value'] as String,
      isChecked: map['isChecked'] == 1,
      errorText: map['errorText'] as String?,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      note: map['note'] ?? '',
      reward: map['reward'] ?? '',
      createTime: DateTime.parse(map['createTime']),
      updateTime: DateTime.parse(map['updateTime']),
      syncStatus: map['syncStatus'] as int? ?? 0,
    );
  }
}

typedef CheckBeforeSubmit = Function(String value, TodoItemMap item);
typedef OnChanged = Function(bool boolean, TodoItemMap item);
typedef Remove = Function(TodoItemMap item);
// 在TodoItem类中，build方法返回一个Row组件，包含复选框、文本或文本输入框以及一个删除按钮
class TodoItem extends StatelessWidget {
  TodoItem({
    required this.data,
    required this.onChanged,
    required this.checkBeforeSubmit,
    required this.remove
  }) : super(key: ObjectKey(data));

  final TodoItemMap data;
  final OnChanged onChanged;
  final CheckBeforeSubmit checkBeforeSubmit;
  final Remove remove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black12,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: data.isChecked,
            onChanged: (boolean) => onChanged(boolean!, data)
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 任务名称
                Text(
                  data.value,
                  style: data.isChecked
                    ? const TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough
                      )
                    : const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                // 奖励和截止日期
                Row(
                  children: [
                    // 奖励信息
                    Text(
                      '奖励: ${data.reward.isEmpty ? "10积分" : data.reward}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    // 如果有截止日期，显示分隔符和日期
                    if (data.dueDate != null) ...[
                      const SizedBox(width: 8),
                      const Text(
                        '|',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '截止时间: ${data.dueDate!.toString().split(' ')[0]}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // 删除按钮
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
            onPressed: () => remove(data),
          ),
        ],
      ),
    );
  }
}
