import 'package:hive/hive.dart'; // Verileri yerel olarak saklamak için kullanılır

// Hive için oluşturulacak adapter dosyasını bağlar
part 'user_info.g.dart';

// HiveType: Bu sınıfın Hive veritabanında saklanabilir olduğunu belirtir
@HiveType(typeId: 2)
class UserInfo extends HiveObject {
  // Kullanıcı bilgileri
  @HiveField(0)
  String name;

  @HiveField(1)
  String surname;

  @HiveField(2)
  DateTime? birthDate;

  // Yapıcı metod: Kullanıcı bilgisi nesnesi oluşturur
  UserInfo({required this.name, required this.surname, this.birthDate});
}
