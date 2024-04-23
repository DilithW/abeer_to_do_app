import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class Task {
  final String name;
  final DateTime date;

  Task({required this.name, required this.date});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TaskScreen(),
    );
  }
}

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<Task> todayTasks = [];
  List<Task> tomorrowTasks = [];
  DateTime? _selectedDay;

  void addTask(Task task) {
    setState(() {
      if (_selectedDay != null && task.date.isAfter(_selectedDay!)) {
        tomorrowTasks.add(task);
      } else {
        todayTasks.add(task);
      }
    });
  }

  void editTask(Task oldTask, Task newTask) {
    setState(() {
      if (oldTask.date.isAfter(DateTime.now())) {
        tomorrowTasks.remove(oldTask);
        tomorrowTasks.add(newTask);
      } else {
        todayTasks.remove(oldTask);
        todayTasks.add(newTask);
      }
    });
  }

  void deleteTask(Task task) {
    setState(() {
      if (task.date.isAfter(DateTime.now())) {
        tomorrowTasks.remove(task);
      } else {
        todayTasks.remove(task);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TaskCard(
              title: 'Today\'s Tasks',
              tasks: todayTasks,
              onAdd: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTaskScreen(addTask),
                  ),
                );
              },
              onEdit: (oldTask, newTask) {
                editTask(oldTask, newTask);
              },
              onDelete: (task) {
                deleteTask(task);
              },
            ),
            SizedBox(height: 16.0),
            TaskCard(
              title: 'Tomorrow\'s Tasks',
              tasks: tomorrowTasks,
              onAdd: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTaskScreen(addTask),
                  ),
                );
              },
              onEdit: (oldTask, newTask) {
                editTask(oldTask, newTask);
              },
              onDelete: (task) {
                deleteTask(task);
              },
            ),
            SizedBox(height: 16.0),
            CalendarView(
              onDaySelected: (day, tasks) {
                setState(() {
                  _selectedDay = day;
                  todayTasks.clear();
                  tomorrowTasks.clear();
                  tasks.forEach((task) {
                    if (task.date.isAfter(day)) {
                      tomorrowTasks.add(task);
                    } else {
                      todayTasks.add(task);
                    }
                  });
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final Function() onAdd;
  final Function(Task, Task) onEdit;
  final Function(Task) onDelete;

  TaskCard({
    required this.title,
    required this.tasks,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(title),
            trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: onAdd,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              Task task = tasks[index];
              return ListTile(
                title: Text(task.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Open edit task screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTaskScreen(
                              task: task,
                              onEdit: (newTask) {
                                onEdit(task, newTask);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // Delete task
                        onDelete(task);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CalendarView extends StatelessWidget {
  final Function(DateTime, List<Task>) onDaySelected;

  CalendarView({required this.onDaySelected});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendar View',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Calendar(onDaySelected: onDaySelected),
          ],
        ),
      ),
    );
  }
}

class Calendar extends StatefulWidget {
  final Function(DateTime, List<Task>) onDaySelected;

  Calendar({required this.onDaySelected});

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(DateTime.now().year, DateTime.now().month, 1),
      lastDay: DateTime.utc(DateTime.now().year, DateTime.now().month + 1, 0),
      focusedDay: DateTime.now(),
      onDaySelected: (selectedDay, focusedDay) {
        widget.onDaySelected(
          selectedDay,
          // Pass empty list of tasks for now
          [],
        );
      },
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  final Function(Task) addTask;

  AddTaskScreen(this.addTask);

  @override
  Widget build(BuildContext context) {
    TextEditingController taskController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: taskController,
              decoration: InputDecoration(labelText: 'Task Name'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  addTask(Task(
                    name: taskController.text,
                    date: DateTime.now(), // Change to selected date
                  ));
                  Navigator.pop(context);
                }
              },
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatelessWidget {
  final Task task;
  final Function(Task) onEdit;

  EditTaskScreen({required this.task, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    TextEditingController taskController = TextEditingController(text: task.name);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: taskController,
              decoration: InputDecoration(labelText: 'Task Name'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  onEdit(Task(name: taskController.text, date: task.date));
                  Navigator.pop(context);
                }
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
