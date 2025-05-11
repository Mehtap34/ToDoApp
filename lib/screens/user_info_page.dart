import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:todoappim/models/user_info.dart';

// Kullanıcı bilgilerini gösteren sayfa
class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key, required String name, required String surname});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  UserInfo? _user; // Kullanıcı verisi
  DateTime? _birthDate; // Doğum tarihi

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Sayfa açıldığında veriyi yükle
  }

  // Hive kutusundan kullanıcıyı yükleme işlemi
  void _loadUserData() {
    final userBox = Hive.box<UserInfo>('userBox');
    final storedUser = userBox.get('currentUser'); // currentUser anahtarındaki veriyi al
    if (storedUser != null) {
      setState(() {
        _user = storedUser;
        _birthDate = storedUser.birthDate;
      });
    }
  }

  // Doğum tarihi seçimi
  void _selectBirthDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000), // Varsayılan tarih
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    // Tarih seçildiyse ve kullanıcı varsa güncelle
    if (picked != null && _user != null) {
      _user!.birthDate = picked;
      await _user!.save(); // Hive’a kaydet
      setState(() {
        _birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kullanıcı henüz yüklenmemişse yükleniyor göstergesi
    if (_user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE1DAD3), // Arka plan rengi
      appBar: AppBar(
        title: const Text(
          'User Information', // Sayfa başlığı
          style: TextStyle(
            color: Color(0xFF4A3F35),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F2EF), // Üst bar rengi
        elevation: 2,
        iconTheme: const IconThemeData(color: Color(0xFF4A3F35)), // Geri tuşu rengi
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          color: const Color(0xFFF5F2EF), // Kart arka plan rengi
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.person, size: 48, color: Color(0xFF8A716A)), // Profil simgesi
                const SizedBox(height: 16),
                Text(
                  'Name: ${_user!.name}', // Ad bilgisi
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A3F35),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Surname: ${_user!.surname}', // Soyad bilgisi
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A3F35),
                  ),
                ),
                const Divider(height: 32, thickness: 1.2, color: Color(0xFFD7A49A)), // Ayırıcı çizgi
                Center(
                  // Doğum tarihi seç butonu
                  child: ElevatedButton.icon(
                    onPressed: _selectBirthDate,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Choose Date of Birth'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB7CAB1), // Buton rengi
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      elevation: 3,
                    ),
                  ),
                ),
                // Eğer doğum tarihi seçilmişse ekranda göster
                if (_birthDate != null)
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: const Color(0xFFD7A49A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD7A49A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cake, color: Color(0xFFD7A49A)), // Pasta ikonu
                        const SizedBox(width: 12),
                        Text(
                          'Selected Date: ${DateFormat('dd/MM/yyyy').format(_birthDate!)}', // Seçilen tarih
                          style: const TextStyle(fontSize: 16, color: Color(0xFF4A3F35)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
