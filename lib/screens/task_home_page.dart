import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todoappim/screens/calendar_page.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import 'add_task_page.dart';
import 'category_detail_page.dart';
import 'home_page.dart';
import 'user_info_page.dart';

class TaskHomePage extends StatefulWidget {
  final String name;
  final String surname;

  const TaskHomePage({super.key, required this.name, required this.surname});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  // Hive kutusuna erişim için kutu tanımı
  late Box<Task> taskBox;

  // Arama çubuğu için filtreleme metni
  String searchQuery = '';

  // Kategori listesi
  List<String> categories = [
    'Daily Planner',
    'Appointment',
    'Work',
    'Shopping',
  ];

  // Takvimde seçili olan gün
  DateTime _selectedDay = DateTime.now();

  // Günlük notlar için harita
  Map<DateTime, String> dailyNotes = {};
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    taskBox = Hive.box<Task>('taskBox'); // Hive kutusu başlatılıyor
  }

  // Yeni görev ekleme işlemi
  void addTask(Task task) {
    taskBox.add(task);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task Added Successfully')),
    );
  }

  // Görev silme işlemi
  void deleteTask(int index) {
    taskBox.deleteAt(index);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task Deleted')),
    );
  }

  // Görev tamamlandı/tamamlanmadı durumunu değiştirme
  void toggleTaskCompletion(int index) {
    final task = taskBox.getAt(index);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      task.save();
      setState(() {});
    }
  }

  // Görev ekleme sayfasını açar
  void showAddTaskPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskPage(
          categories: categories,
          onAdd: addTask,
          onCategoryAdd: (newCategory) {
            setState(() {
              if (!categories.contains(newCategory)) {
                categories.add(newCategory);
              }
            });
          },
        ),
      ),
    );
  }

  // Takvim sayfasına gider
  void showCalendarPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CalendarPage(allTasks: taskBox.values.toList()),
      ),
    );
  }

  // Kullanıcı bilgileri sayfasına gider
  void showUserInfoPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserInfoPage(name: widget.name, surname: widget.surname),
      ),
    );
  }

  // Görevleri arama filtresine göre listeleme
  List<Task> get filteredTasks {
    final allTasks = taskBox.values.toList();
    if (searchQuery.isEmpty) return allTasks;
    return allTasks.where((task) =>
        task.title.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  // Her kategori için özel bir renk döndürür
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Daily Planner':
        return const Color(0xFFD7A49A);
      case 'Appointment':
        return const Color(0xFFA4B1BA);
      case 'Work':
        return const Color(0xFFE4C9B6);
      case 'Shopping':
        return const Color(0xFFB7CAB1);
      default:
        return const Color(0xFFE4C9B6);
    }
  }

  // Kategori kartlarını oluşturan widget
  Widget _buildCategoryCard(String category, Color color) {
    List<Task> categoryTasks = filteredTasks.where((t) => t.category == category).toList();
    int completedCount = categoryTasks.where((t) => t.isCompleted).length;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryDetailPage(
              category: category,
              tasks: categoryTasks,
              onDeleteCategory: () {
                setState(() {
                  categories.remove(category);
                  for (int i = taskBox.length - 1; i >= 0; i--) {
                    if (taskBox.getAt(i)?.category == category) {
                      taskBox.deleteAt(i);
                    }
                  }
                });
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori adı ve tamamlanan görev sayısı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '$completedCount/${categoryTasks.length} tasks',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Görev listesi
            ...categoryTasks.map((task) => _buildTaskItem(task)),
          ],
        ),
      ),
    );
  }

  // Tek bir görev öğesi
  Widget _buildTaskItem(Task task) {
    int index = taskBox.values.toList().indexOf(task);
    return ListTile(
      title: Text(task.title),
      subtitle: task.description != null ? Text(task.description!) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: task.isCompleted,
            onChanged: (value) => toggleTaskCompletion(index),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => deleteTask(index),
          ),
        ],
      ),
      onTap: () => toggleTaskCompletion(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1DAD3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA4B1BA),
        elevation: 0,
        title: const Text(
          'Tasks',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Takvim widget'ı
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: _selectedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });
              },
            ),
            const SizedBox(height: 10),
            // Seçilen güne ait not
            Text(
              "Not (${DateFormat('dd/MM/yyyy').format(_selectedDay)}):",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _noteController..text = dailyNotes[_selectedDay] ?? '',
              onChanged: (value) {
                setState(() {
                  dailyNotes[_selectedDay] = value;
                });
              },
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Leave a note for today...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Kategori kartları
            ...categories.map((cat) => _buildCategoryCard(cat, _getCategoryColor(cat))),
          ],
        ),
      ),
      // Görev ekleme butonu
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskPage,
        backgroundColor: const Color(0xFFD7A49A),
        child: const Icon(Icons.add),
      ),
      // Alt navigasyon çubuğu
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 2) {
            showAddTaskPage();
          } else if (index == 1) {
            showCalendarPage();
          } else if (index == 3) {
            showUserInfoPage();
          } else if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  name: widget.name,
                  surname: widget.surname,
                ),
              ),
            );
          }
        },
        selectedItemColor: const Color(0xFFD7A49A),
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 40), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: ''),
        ],
      ),
    );
  }
}