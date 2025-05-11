import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/todo_item.dart'; // TodoItem modelini içe aktarır

// TodoProvider: Uygulama içinde görev (todo) verilerini yöneten sınıf
// ChangeNotifier ile çalışır, böylece UI'da değişiklikler tetiklenebilir
class TodoProvider with ChangeNotifier {
  // Tüm görevlerin tutulduğu liste
  List<TodoItem> _todos = [];

  // Hive kutusu
  late Box<TodoItem> _todoBox;

  // Dışarıdan görev listesine erişimi sağlar (getter)
  List<TodoItem> get todos => _todos;

  // Hive'dan görevleri yükler ve _todos listesine aktarır
  Future<void> loadTodos() async {
    _todoBox = await Hive.openBox<TodoItem>('todoBox'); // Kutuyu açar
    _todos = _todoBox.values.toList(); // Tüm görevleri listeye aktarır
    notifyListeners(); // UI'ı günceller
  }

  // Tüm görevleri Hive'a kaydeder 
  Future<void> saveTodos() async {
    await _todoBox.clear(); // Önce eski verileri siler
    for (var todo in _todos) {
      await _todoBox.add(todo); // Yeni görevleri sırayla ekler
    }
  }

  // Yeni bir görev ekler
  void addTodo(String title) {
    final todo = TodoItem(title: title); // Yeni görev nesnesi oluşturur
    _todos.add(todo); // Listeye ekler
    _todoBox.add(todo); // Hive'a kaydeder
    notifyListeners(); // UI'ı günceller
  }

  // Bir görevin tamamlanma durumunu değiştirir 
  void toggleDone(int index) {
    _todos[index].isDone = !_todos[index].isDone; // Durumu tersine çevirir
    _todos[index].save(); // Hive verisini günceller
    notifyListeners(); // UI'ı günceller
  }

  // Görevi siler (hem listeden hem Hive'dan)
  void deleteTodo(int index) {
    _todos[index].delete(); // Hive'dan siler
    _todos.removeAt(index); // Listeden çıkarır
    notifyListeners(); // UI'ı günceller
  }
}
