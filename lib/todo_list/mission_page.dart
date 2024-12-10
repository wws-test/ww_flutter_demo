import 'package:flutter/material.dart';
import 'todo_item.dart';
import 'package:bruno/bruno.dart';
import 'task_detail_page.dart';

class MissionPage extends StatefulWidget {
  const MissionPage({super.key});

  @override
  State<MissionPage> createState() => _MissionPageState();
}

class _MissionPageState extends State<MissionPage> {
  // 存储任务项的列表
  List<TodoItemMap> list = [];
  // 错误文本，用于显示输入错误信息
  String? _errorText;
  // 任务 ID，用于唯一标识每个任务
  int id = 1;
  // 文本编辑控制器，用于获取用户输入的任务内容
  late TextEditingController _editingController;
  // 文本编辑控制器，用于获取用户输入的任务奖励
  late TextEditingController _rewardController;
  // 文本编辑控制器，用于获取用户输入的任务备注
  late TextEditingController _noteController;
  // 选择的日期，用于设置任务的截止日期
  DateTime? _selectedDate;

  @override
  void initState() {
    // 初始化状态时，创建文本编辑控制器
    super.initState();
    _editingController = TextEditingController();
    _rewardController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    // 销毁状态时，释放文本编辑控制器资源
    _editingController.dispose();
    _rewardController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // 提交任务的方法
  void _submit(value) {
    // 创建一个包含任务信息的 Map 对象
    Map<String, dynamic> obj = {
      "id": id,
      "value": value,
      "isChecked": false,
      "errorText": null,
      "dueDate": _selectedDate,
      "note": _noteController.text,
      "reward": _rewardController.text,
    };
    // 更新状态，将新任务添加到列表中，并重置 ID 和文本编辑控制器
    setState(() {
      list.insert(0, TodoItemMap.fromMap(obj));
      id = id + 1;
      _editingController.clear();
      _rewardController.clear();
      _noteController.clear();
      _selectedDate = null;
    });
  }

  // 更新任务内容的方法
  void _update(text, item) {
    // 使用 map 方法遍历列表，更新指定任务的内容
    var arr = list.map((v) {
      if (v.id == item.id) {
        v.value = text;
      }
      return v;
    }).toList();
    // 更新状态，应用更改后的任务列表
    setState(() {
      list = arr;
    });
  }

  // 删除任务的方法
  void _remove(item) {
    // 更新状态，从列表中移除指定任务
    setState(() {
      list.removeWhere((v) => v.id == item.id);
    });
  }

  // 切换任务完成状态的方法
  void _onChanged(boolean, item) {
    // 更新状态，切换指定任务的完成状态
    setState(() {
      list = list.map((v) {
        if (v.id == item.id) {
          v.isChecked = boolean;
        }
        return v;
      }).toList();
    });
  }

  // 检查并提交任务的方法
  void _checkBeforeSubmit(String value, item) {
    // 如果任务项为空，则设置错误文本
    item = item?? true;
    if (value.trim() == '') {
      setState(() {
        if (item!= true) {
          item.errorText = '失败! 内容不能为空';
        } else {
          _errorText = '失败! 内容不能为空';
        }
      });
    } 
    // 如果任务内容包含多余空格，则设置错误文本
    else {
      var lastValue = value.trim();
      if (lastValue.length!= value.length) {
        setState(() {
          if (item!= true) {
            item.errorText = '失败! 包含多余空格';
          } else {
            _errorText = '失败! 包含多余空格';
          }
        });
      } 
      // 如果任务内容通过检查，则更新或提交任务
      else {
        if (item!= true) {
          _update(value, item);
        } else {
          _submit(value);
        }
        // 重置错误文本
        setState(() {
          if (item!= true) {
            item.errorText = null;
          } else {
            _errorText = null;
          }
        });
      }
    }
  }

  // 更新任务详细信息的方法
  void _updateTaskDetails(TodoItemMap item, {DateTime? dueDate, String? note, String? reward}) {
    // 更新状态，设置任务的截止日期、备注和奖励
    setState(() {
      if (dueDate!= null) item.dueDate = dueDate;
      if (note!= null) item.note = note;
      if (reward!= null) item.reward = reward;
    });
  }

  // 打开任务详细信息页面的方法
  void _openTaskDetail(TodoItemMap task) {
    // 使用 Navigator 导航到任务详细信息页面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(
          task: task,
          onUpdate: _updateTaskDetails,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 构建任务管理页面的 UI
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 任务输入框
            TextField(
              controller: _editingController,
              decoration: InputDecoration(
                hintText: '添加步骤',
                errorText: _errorText,
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.add_circle_outline, color: Colors.blue),
              ),
              onSubmitted: (value) {
                // 当用户提交任务时，调用检查并提交任务的方法
                _checkBeforeSubmit(value, null);
              }
            ),
          
            // 任务列表
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                child: ListView(
                  children: list.map((item) {
                    // 为每个任务项创建一个 GestureDetector，用于点击时打开任务详细信息页面
                    return GestureDetector(
                      onTap: () {
                        _openTaskDetail(item);
                      },
                      child: TodoItem(
                        data: item,
                        onChanged: _onChanged,
                        checkBeforeSubmit: _checkBeforeSubmit,
                        remove: _remove
                      ),
                    );
                  }).toList()
                )
              )
            )
          ],
        ),
      )
    );
  }
} 
