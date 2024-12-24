import 'package:flutter/material.dart';
import 'todo_item.dart';
import 'task_detail_page.dart';
import 'services/db_service.dart';

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
    // 使用 Future.microtask 确保在 build 之后加载数据
    Future.microtask(() => _loadTodos());
  }

  @override
  void dispose() {
    // 销毁状态时，释放文本编辑控制器资源
    _editingController.dispose();
    _rewardController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  // 处理任务项点击事件
  void _onItemTap(TodoItemMap item) {
    // 导航到任务详细信息页面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(
          task: item,
          onUpdate: _updateTaskDetails,
        ),
      ),
    );
  }
  // 提交任务的方法
  void _submit(value) async {
    TodoItemMap todo = TodoItemMap(
      id: id,
      value: value,
      isChecked: false,
      errorText: null,
      dueDate: _selectedDate,
      note: _noteController.text,
      reward: _rewardController.text,
    );
    
    await DBService.insertTodo(todo);
    await _loadTodos();
    
    // 重置输入
    _editingController.clear();
    _rewardController.clear();
    _noteController.clear();
    _selectedDate = null;
  }

  void _update(text, item) {
    // var arr = list.map((v) => v).toList();
    // 思路:原本list在map后得到的类型是Iterable<TodoItemMap>实际上需要List<TodoItemMap>
    // 所以最后要toList()转换
    // 之后要对个别的���做处理,注意:如果v=>v,前面不用括号包裹,会报错 Undefined name 'v'.
    // 如下:
    // var arr = list.map(v => v).toList();

    var arr = list.map((v) {
      if (v.id == item.id) {
        v.value = text;
      }
      return v;
    }).toList();

    setState(() {
      list = arr;
    });
  }

  void _remove(TodoItemMap item) async {
    await DBService.deleteTodo(item.uuid);
    await _loadTodos();
  }

  void _onChanged(boolean, item) {
    setState(() {
      list = list.map((v) {
        if (v.id == item.id) {
          v.isChecked = boolean;
        }
        return v;
      }).toList();
    });
  }

  void _checkBeforeSubmit(String value, item) {
    item = item ?? true;
    if (value.trim() == '') {
      setState(() {
        if (item != true) {
          item.errorText = '失败! 内容不能为空';
        } else {
          _errorText = '失败! 内容不能为空';
        }
      });
    } else {
      var lastValue = value.trim();
      if (lastValue.length != value.length) {
        setState(() {
          if (item != true) {
            item.errorText = '失败! 包含多余空格';
          } else {
            _errorText = '失败! 包含多余空格';
          }
        });
      } else {
        if (item != true) {
          _update(value, item);
        } else {
          _submit(value);
        }
        setState(() {
          if (item != true) {
            item.errorText = null;
          } else {
            _errorText = null;
          }
        });
      }
    }
  }

  void _updateTaskDetails(TodoItemMap item, {DateTime? dueDate, String? note, String? reward}) async {
    if (dueDate != null) item.dueDate = dueDate;
    if (note != null) item.note = note;
    if (reward != null) item.reward = reward;
    
    await DBService.updateTodo(item);
    await _loadTodos();
  }

  void _openTaskDetail(TodoItemMap task) {
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

  // 修改加载方法，添加错误处理
  Future<void> _loadTodos() async {
    try {
      final todos = await DBService.getTodos();
      if (mounted) {  // 确保 widget 还在树中
        setState(() {
          list = todos;
        });
      }
    } catch (e) {
      print('Error loading todos: $e');  // 添加错误日志
      // 可以在这里添加错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('加载任务失败')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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