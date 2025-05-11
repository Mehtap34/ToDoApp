import 'package:hive/hive.dart'; // Hive kütüphanesini veri saklama için içe aktarır

// Hive'a özel kod üretimi için gerekli olan 'part' dosyası
part 'task.g.dart';

// Bu sınıfın Hive veritabanında saklanabilir  olduğunu belirtir
@HiveType(typeId: 1)
class Task extends HiveObject {
  // Görevin başlığı 
  @HiveField(0)
  String title;

  // Görevin ait olduğu kategori 
  @HiveField(1)
  String category;

  // Görevin son teslim tarihi 
  @HiveField(2)
  DateTime? dueDate;

  // Görevin tamamlanıp tamamlanmadığına bakar
  @HiveField(3)
  bool isCompleted;

  // Görevle ilgili ek açıklama ekleme
  @HiveField(4)
  String? description;

  // Görevin önceliğini belirtir
  @HiveField(5)
  String? priority;

  // Yapıcı metod: Task nesnesi oluşturmak için kullanılır
  Task({
    required this.title,
    required this.category,
    this.dueDate,
    this.isCompleted = false,
    this.description,
    this.priority,
  });
}
