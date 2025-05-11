import 'package:hive/hive.dart'; // Hive kütüphanesini içe aktarır 

// Hive için gerekli olan otomatik oluşturulan kodları bağlar
part 'todo_item.g.dart';

// HiveType: Bu sınıfın Hive veritabanında saklanabilir  veri türü olduğunu belirtir
@HiveType(typeId: 0)
class TodoItem extends HiveObject {
  // Görev başlığı 
  @HiveField(0)
  String title;

  // Görevin tamamlanma durumu 
  @HiveField(1)
  bool isDone;

  // Yapıcı metod: Yeni bir görev oluşturmak için kullanılır
  TodoItem({required this.title, this.isDone = false});
}
