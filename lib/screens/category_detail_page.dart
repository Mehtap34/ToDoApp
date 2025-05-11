import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

// Belirli bir kategoriye ait görevlerin gösterildiği sayfa
class CategoryDetailPage extends StatefulWidget {
  final String category; // Görüntülenecek kategori adı
  final VoidCallback onDeleteCategory; // Kategori silindiğinde tetiklenecek fonksiyon

  const CategoryDetailPage({
    super.key,
    required this.category,
    required this.onDeleteCategory,
    required List<Task> tasks, // (Gereksiz, kullanılmıyor. Silinebilir.)
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  late Box<Task> taskBox; // Hive kutusu (veritabanı)

  // Yalnızca bu kategoriye ait görevleri filtreler
  List<Task> get _filteredTasks =>
      taskBox.values.where((task) => task.category == widget.category).toList();

  @override
  void initState() {
    super.initState();
    taskBox = Hive.box<Task>('taskBox'); // Hive kutusu açılır
  }

  // Kategoriyi ve içindeki görevleri silme onayı
  void _confirmDeleteCategory(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF5F2EF),
        title: const Text("Delete the category?"),
        content: Text(
          "‘${widget.category}’ category and tasks in it will be deleted.",
        ),
        actions: [
          // Vazgeç butonu
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          // Silme işlemi onayı
          TextButton(
            onPressed: () {
              final tasksToDelete = _filteredTasks;
              for (var task in tasksToDelete) {
                task.delete(); // Hive'dan görev silinir
              }
              widget.onDeleteCategory(); // Ana ekrana kategori silindiğini bildir
              Navigator.pop(context); // Diyalog kapat
              Navigator.pop(context); // Sayfadan çık
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Yeni görev eklemek için diyalog kutusu
  void _addTaskDialog() {
    String title = '';
    String description = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF5F2EF),
        title: const Text("Add New Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık girişi
            TextField(
              decoration: const InputDecoration(labelText: "Title"),
              onChanged: (value) => title = value,
            ),
            // Açıklama girişi
            TextField(
              decoration: const InputDecoration(labelText: "Explanation"),
              onChanged: (value) => description = value,
            ),
          ],
        ),
        actions: [
          // İptal butonu
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          // Ekleme işlemi
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD7A49A),
            ),
            onPressed: () {
              if (title.isNotEmpty) {
                final newTask = Task(
                  title: title,
                  description: description,
                  category: widget.category,
                  isCompleted: false,
                );
                taskBox.add(newTask); // Görev Hive'a kaydedilir
                setState(() {}); // Arayüz yenilenir
                Navigator.pop(context); // Diyalog kapanır
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // Görevin tamamlanma durumunu değiştirir
  void _toggleCompletion(Task task) {
    task.isCompleted = !task.isCompleted;
    task.save(); // Hive veritabanında güncellenir
    setState(() {}); // Arayüz yenilenir
  }

  // Görevi siler
  void _deleteTask(Task task) {
    task.delete(); // Hive'dan silinir
    setState(() {}); // Liste yenilenir
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _filteredTasks; // Kategoriye ait görevler alınır

    return Scaffold(
      backgroundColor: const Color(0xFFE1DAD3),
      appBar: AppBar(
        title: Text(widget.category, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFD7A49A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Kategori silme butonu
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () => _confirmDeleteCategory(context),
          ),
        ],
      ),
      body: tasks.isEmpty
          // Eğer görev yoksa bilgi mesajı göster
          ? const Center(
              child: Text(
                "There are no tasks in this category.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          // Görev listesi
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  color: const Color(0xFFF5F2EF),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough // Tamamlanan görev üstü çizilir
                            : null,
                      ),
                    ),
                    subtitle: task.description != null && task.description!.isNotEmpty
                        ? Text(task.description!)
                        : null,
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) => _toggleCompletion(task),
                      activeColor: const Color(0xFFB7CAB1),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTask(task),
                    ),
                    onTap: () => _toggleCompletion(task),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTaskDialog, // Yeni görev ekleme butonu
        backgroundColor: const Color(0xFFD7A49A),
        child: const Icon(Icons.add),
      ),
    );
  }
}