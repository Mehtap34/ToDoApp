import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class JournalHistoryPage extends StatefulWidget {
  const JournalHistoryPage({super.key});

  @override
  State<JournalHistoryPage> createState() => _JournalHistoryPageState();
}

class _JournalHistoryPageState extends State<JournalHistoryPage> {
  // Günlük dosyalarını tutan liste
  List<FileSystemEntity> journalFiles = [];

  @override
  void initState() {
    super.initState();
    _loadJournalFiles(); // Sayfa açıldığında günlük dosyalarını yükle
  }

  // Günlük dosyalarını cihazdan yükleme ve tarihe göre sıralama
  Future<void> _loadJournalFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final journalDir = Directory('${directory.path}/journals');

    // Eğer 'journals' klasörü varsa içindeki dosyaları al ve sırala
    if (await journalDir.exists()) {
      final files = journalDir.listSync()
        ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified)); // En son düzenleneni en üste al
      setState(() {
        journalFiles = files; // Dosya listesini güncelle
      });
    }
  }

  // Verilen dosyanın içeriğini oku
  Future<String> _readJournal(File file) async {
    return await file.readAsString();
  }

  // Günlük içeriğini popup ile göster
  void _showJournalContent(File file) async {
    final content = await _readJournal(file);
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF5F2EF), // Açık krem arka plan
        title: Text(
          file.path.split('/').last, // Dosya adını başlık olarak göster
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(child: Text(content)), // İçeriği göster
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'), // Kapat butonu
          ),
        ],
      ),
    );
  }

  // Günlük dosyasını silme işlemi
  void _deleteJournal(File file) async {
    await file.delete(); // Dosyayı sil
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deleted diary.')), // Bilgilendirme mesajı
    );
    _loadJournalFiles(); // Listeyi yeniden yükle
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1DAD3), // Arka plan pastel ivory
      appBar: AppBar(
        title: const Text('📚 Diary History'), // Başlık
        backgroundColor: const Color(0xFFD7A49A), // Dusty Rose
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Eğer hiç günlük yoksa bilgi göster
      body: journalFiles.isEmpty
          ? const Center(
              child: Text(
                'No diary registered yet.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: journalFiles.length, // Günlük sayısı
              itemBuilder: (context, index) {
                final file = journalFiles[index] as File;
                final name = file.path.split('/').last; // Dosya adı

                return Card(
                  color: const Color(0xFFF5F2EF), // Kart rengi
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      name, // Kart başlığı dosya adı
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF444444),
                      ),
                    ),
                    leading: const Icon(Icons.menu_book_rounded, color: Color(0xFFB7CAB1)), // Kitap ikonu
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Silme butonu
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            // Silmeden önce onay al
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: const Color(0xFFF5F2EF),
                                title: const Text('Delete?'),
                                content: Text('"$name" The diary named will be deleted.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteJournal(file); // Günlüğü sil
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // Günlük görüntüleme butonu
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye, color: Colors.teal),
                          onPressed: () => _showJournalContent(file), // Günlüğü oku ve göster
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
