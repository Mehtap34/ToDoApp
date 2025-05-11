import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todoappim/models/user_info.dart';
import 'package:todoappim/screens/daily_journal_page.dart';
import 'calendar_page.dart';
import 'task_home_page.dart';

// Ana sayfa (kullanıcı karşılama ve diğer sayfalara yönlendirme)
class HomePage extends StatelessWidget {
  const HomePage({super.key, required String name, required String surname});

  @override
  Widget build(BuildContext context) {
    // Hive kutusundan kullanıcı bilgilerini alma
    final userBox = Hive.box<UserInfo>('userBox');
    final user = userBox.get(
      'currentUser',
      defaultValue: UserInfo(name: 'Guest', surname: ''),
    )!;

    return Scaffold(
      backgroundColor: const Color(0xFFE1DAD3),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Geri butonunu gizle
        title: const Text(
          'Home Page',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFA4B1BA),
        elevation: 6,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Kullanıcıya hoş geldin mesajı
            Text(
              'Welcome, ${user.name}!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'You can easily manage all your tasks here.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            // Özellik kartlarının bulunduğu satır
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Görevler sayfasına yönlendirme kartı
                _buildFeatureCard(
                  context,
                  Icons.list_alt_rounded,
                  'Tasks',
                  const Color(0xFFD7A49A),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskHomePage(
                          name: user.name,
                          surname: user.surname,
                        ),
                      ),
                    );
                  },
                ),
                // Takvim sayfasına yönlendirme kartı
                _buildFeatureCard(
                  context,
                  Icons.calendar_month,
                  'Calendar',
                  const Color(0xFFA4B1BA),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CalendarPage(allTasks: []), // allTasks dışarıdan alınmalı
                      ),
                    );
                  },
                ),
                // Günlük sayfasına yönlendirme kartı
                _buildFeatureCard(
                  context,
                  Icons.menu_book_rounded,
                  'Diary',
                  const Color(0xFFB7CAB1),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DailyJournalPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Sayfadaki her bir özellik için özelleştirilmiş kart oluşturma metodu
  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon, // Karttaki ikon
    String title, // Kart başlığı
    Color backgroundColor, // Arka plan rengi
    VoidCallback onTap, // Tıklama işlevi
  ) {
    return GestureDetector(
      onTap: onTap, // Kart tıklanınca çalışacak işlem
      child: Container(
        width: 100,
        height: 130,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF4A4A4A), size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF4A4A4A),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}