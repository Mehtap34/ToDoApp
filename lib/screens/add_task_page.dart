import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

// AddTaskPage, yeni bir görev  eklemek için kullanılan sayfa.
// Kullanıcıdan başlık, kategori ve isteğe bağlı tarih bilgisi alır.
class AddTaskPage extends StatefulWidget {
  final List<String> categories; // Var olan kategoriler listesi
  final Function(Task) onAdd; // Yeni görev eklendiğinde çağrılacak fonksiyon
  final Function(String) onCategoryAdd; // Yeni kategori eklendiğinde çağrılacak fonksiyon

  const AddTaskPage({
    super.key,
    required this.categories,
    required this.onAdd,
    required this.onCategoryAdd,
  });

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  // Başlık ve yeni kategori adı için kontrolcüler
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  String? selectedCategory; // Seçilen kategori
  DateTime? selectedDate;   // Seçilen tarih
  late List<String> localCategories; // Sayfa içindeki yerel kategori listesini belirtir

  @override
  void initState() {
    super.initState();
    // Kategoriler, widget üzerinden alınıp yerel listeye atanıyor
    localCategories = List.from(widget.categories);
  }

  // Kullanıcıdan bir tarih alır
  void pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
      builder: (context, child) {
        // Tarih seçim kutusu teması
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFB7CAB1),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: const DialogTheme(backgroundColor: Color(0xFFF5E4D7)),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  // Görev kaydetme işlemi
  void saveTask() {
    // Başlık veya kategori eksikse uyarı verir
    if (_titleController.text.trim().isEmpty || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and category')),
      );
      return;
    }

    // HIVE modeline uygun bir Task nesnesi oluşturuluyor
    final newTask = Task(
      title: _titleController.text.trim(),
      category: selectedCategory!,
      dueDate: selectedDate,
      isCompleted: false,
      description: null,
      priority: null,
    );

    widget.onAdd(newTask); // Yeni görev üst widget'a gönderiliyor
    Navigator.pop(context); // Sayfa kapatılıyor
  }

  // Yeni kategori eklemek için açılan diyalog kutusu
  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF5E4D7),
        title: const Text("New Category", style: TextStyle(color: Colors.black)),
        content: TextField(
          controller: _categoryController,
          decoration: const InputDecoration(
            hintText: "Category Name",
            hintStyle: TextStyle(color: Color(0xFF6B7280)),
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Color(0xFFF9F6F2),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Diyalog kapatılır
              _categoryController.clear(); // Girdi temizlenir
            },
            child: const Text("cancel", style: TextStyle(color: Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () {
              String newCategory = _categoryController.text.trim();
              // Kategori boş değilse ve daha önce eklenmemişse
              if (newCategory.isNotEmpty && !localCategories.contains(newCategory)) {
                setState(() {
                  localCategories.add(newCategory); // Listeye eklenir
                  selectedCategory = newCategory; // Seçili kategori olarak ayarlanır
                });
                widget.onCategoryAdd(newCategory); // Ana widget'a bildirilir
              }
              Navigator.pop(context); // Diyalog kapatılır
              _categoryController.clear(); // Girdi temizlenir
            },
            child: const Text("Add", style: TextStyle(color: Color(0xFF4B5563))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text('Add Task', style: TextStyle(color: Colors.black87)),
        backgroundColor: const Color(0xFFFFF8F0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Görev başlığı girişi
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                labelStyle: const TextStyle(color: Colors.black87),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: const Color(0xFFEAEAEA),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Kategori seçici dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: const Color(0xFFF9F6F2),
                    ),
                    items: localCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                ),
                // Yeni kategori eklemek için buton
                IconButton(
                  onPressed: _showAddCategoryDialog,
                  icon: const Icon(Icons.add),
                  color: const Color(0xFFB7CAB1),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Tarih seçme butonu
            ElevatedButton.icon(
              onPressed: pickDate,
              icon: const Icon(Icons.date_range),
              label: const Text('Choose Date'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA4B1BA),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            // Seçilen tarihi gösteren metin
            if (selectedDate != null)
              Text(
                'Selected Date: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: 20),
            // Görevi kaydetme butonu
            ElevatedButton(
              onPressed: saveTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD7A49A),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}