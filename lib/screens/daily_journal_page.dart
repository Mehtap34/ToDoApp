import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih biçimlendirme için
import 'dart:io'; // Dosya işlemleri için
import 'package:path_provider/path_provider.dart'; // Uygulama klasör yolları için
import 'journal_history_page.dart'; // Geçmiş günlükleri görüntülemek için

class DailyJournalPage extends StatefulWidget {
  const DailyJournalPage({super.key});

  @override
  State<DailyJournalPage> createState() => _DailyJournalPageState();
}

class _DailyJournalPageState extends State<DailyJournalPage> {
  // Kullanıcının günlük girdisini kontrol etmek için controller
  final TextEditingController _journalController = TextEditingController();

  // Günlüğü kaydetme işlemi
  Future<void> saveJournal() async {
    final text = _journalController.text.trim(); // Boşlukları sil

    // Eğer kullanıcı bir şey yazmamışsa uyarı göster
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something.')),
      );
      return;
    }

    // Güncel tarihi biçimlendir (dosya adı için kullanılacak)
    final now = DateTime.now();
    final dateString = DateFormat('yyyy-MM-dd – kk:mm').format(now);

    // Belgeler dizinini al
    final directory = await getApplicationDocumentsDirectory();
    final journalDir = Directory('${directory.path}/journals');

    // Eğer "journals" klasörü yoksa oluştur
    if (!await journalDir.exists()) {
      await journalDir.create(recursive: true);
    }

    // Yeni bir .txt dosyası oluştur ve günlüğü kaydet
    final file = File('${journalDir.path}/$dateString.txt');
    await file.writeAsString(text);

    // Başarı mesajı göster ve metin alanını temizle
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diary saved!')),
    );
    _journalController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1DAD3), // Arka plan: pastel ivory
      appBar: AppBar(
        title: const Text('📝 Write Diary'),
        backgroundColor: const Color(0xFFD7A49A), // Başlık: Dusty Rose
        elevation: 0,
        foregroundColor: Colors.white, // Yazılar beyaz
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What went through your mind today??',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF444444),
              ),
            ),
            const SizedBox(height: 16),
            // Günlük giriş alanı
            TextField(
              controller: _journalController,
              maxLines: 12,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F2EF), // Açık krem ton
                hintText: 'Write your thoughts...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            // Günlüğü kaydetme butonu
            ElevatedButton.icon(
              onPressed: saveJournal,
              icon: const Icon(Icons.save_alt_rounded, size: 24),
              label: const Text(
                'Save Diary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFB7CAB1), // Sage
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Geçmiş günlüklere geçiş butonu
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JournalHistoryPage(),
                  ),
                );
              },
              icon: const Icon(Icons.history_rounded, size: 24),
              label: const Text(
                'Diary History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFD7A49A), // Dusty Rose
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
