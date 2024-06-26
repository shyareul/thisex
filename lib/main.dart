import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasks App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class Task {
  String title;
  String description;
  bool isCompleted;

  Task(
      {required this.title,
      required this.description,
      this.isCompleted = false});
}

class TaskList {
  String name;
  List<Task> tasks;

  TaskList({required this.name, required this.tasks});
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class EditTaskScreen extends StatefulWidget {
  final Task task;
  final Function(String, String) onSave;

  EditTaskScreen({required this.task, required this.onSave});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 여기에 새로운 build 메서드를 붙여넣습니다
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              widget.onSave(_titleController.text, _descriptionController.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Task Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  List<TaskList> taskLists = [
    TaskList(name: 'Personal', tasks: []),
    TaskList(name: 'Work', tasks: []),
    TaskList(name: 'Shopping', tasks: []),
  ];

  int currentPageIndex = 0;

  void _addNewTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTaskTitle = '';
        String newTaskDescription = '';
        return AlertDialog(
          title: Text('Add New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  autofocus: true,
                  onChanged: (value) {
                    newTaskTitle = value;
                  },
                  decoration: InputDecoration(hintText: "Enter task title"),
                ),
                SizedBox(height: 16),
                TextField(
                  onChanged: (value) {
                    newTaskDescription = value;
                  },
                  decoration:
                      InputDecoration(hintText: "Enter task description"),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (newTaskTitle.isNotEmpty) {
                  setState(() {
                    taskLists[currentPageIndex].tasks.insert(
                        0,
                        Task(
                            title: newTaskTitle,
                            description: newTaskDescription));
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editTask(int listIndex, int taskIndex) {
    Task task = taskLists[listIndex].tasks[taskIndex];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(
          task: task,
          onSave: (String newTitle, String newDescription) {
            setState(() {
              task.title = newTitle;
              task.description = newDescription;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: PageView.builder(
        itemCount: taskLists.length,
        onPageChanged: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Card(
              elevation: 4.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      taskLists[index].name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final Task item =
                              taskLists[index].tasks.removeAt(oldIndex);
                          taskLists[index].tasks.insert(newIndex, item);
                        });
                      },
                      children:
                          taskLists[index].tasks.asMap().entries.map((entry) {
                        int taskIndex = entry.key;
                        Task task = entry.value;
                        return ListTile(
                          key: ValueKey(task),
                          leading: Checkbox(
                            value: task.isCompleted,
                            onChanged: (bool? value) {
                              setState(() {
                                task.isCompleted = value!;
                              });
                            },
                          ),
                          title: Text(task.title),
                          subtitle: Text(
                            task.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            _editTask(index, taskIndex);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        tooltip: 'Add New Task',
        child: Icon(Icons.add),
      ),
    );
  }
}
