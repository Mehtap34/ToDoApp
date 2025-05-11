import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Hive Flutter entegrasyonu
import 'package:todoappim/screens/home_page.dart'; // Ana sayfa
import 'models/todo_item.dart'; // Todo veri modeli
import 'models/task.dart'; // Görev veri modeli
import 'models/user_info.dart'; // Kullanıcı bilgisi veri modeli
import 'screens/login_page.dart'; // Giriş ekranı

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter sisteminin tamamen hazırlandığından emin olunur

  // Hive başlatılıyor
  await Hive.initFlutter();

  // Veri model adapter'ları Hive'a yalnızca bir kere kayıt edilir
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TodoItemAdapter()); // TodoItem için adapter, ID: 0
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TaskAdapter());     // Task için adapter, ID: 1
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(UserInfoAdapter()); // UserInfo için adapter, ID: 2

  // Hive veri kutuları (box) açılıyor
  await Hive.openBox<Task>('taskBox');           // Görevleri saklamak için box
  await Hive.openBox<UserInfo>('userBox');       // Kullanıcı bilgilerini saklamak için box

  // Uygulama başlatılıyor
  runApp(const TaskApp());
}

// Uygulamanın ana widget'ı
class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager', // Uygulama başlığı
      debugShowCheckedModeBanner: false, // Debug etiketi gizleniyor
      theme: ThemeData(
        fontFamily: 'Roboto', // Yazı tipi
        primaryColor: const Color(0xFFB7CAB1), // Temel renk: pastel yeşil
        scaffoldBackgroundColor: const Color(0xFFFFF8F0), // Arka plan rengi: pastel fildişi
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFB7CAB1), // Renk şeması ayarı
        ),
      ),
      home: const EntryPoint(), // İlk açılacak ekran
    );
  }
}

// Giriş noktası: Kullanıcı giriş yapmış mı kontrol eder
class EntryPoint extends StatelessWidget {
  const EntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box<UserInfo>('userBox'); // Kullanıcı kutusu açılıyor
    final currentUser = userBox.get('currentUser'); // 'currentUser' anahtarındaki veriyi al

    // Eğer kayıtlı kullanıcı varsa ana sayfaya yönlendir
    if (currentUser != null) {
      return HomePage(
        name: currentUser.name,
        surname: currentUser.surname,
      );
    } else {
      // Aksi halde giriş ekranını göster
      return const LoginPage();
    }
  }
}
