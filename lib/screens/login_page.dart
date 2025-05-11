import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todoappim/models/user_info.dart';
import 'home_page.dart';

// Kullanıcının ad ve soyad girerek giriş yaptığı sayfa
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Ad ve soyad için metin kontrolcüleri
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();

  // "Continue" butonuna basıldığında çalışacak fonksiyon
  void _goToHomePage() async {
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();

    // Alanlar boşsa kullanıcıyı uyar
    if (name.isEmpty || surname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your name and surname")),
      );
      return;
    }

    // Hive'a kullanıcı bilgilerini kaydet
    final userBox = Hive.box<UserInfo>('userBox');
    userBox.put('currentUser', UserInfo(name: name, surname: surname));

    // Ana sayfaya yönlendir (önceki sayfayı kapatarak)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(name: name, surname: surname),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF6),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFDFD),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.grey.withOpacity(0.1), // Gölge efekti
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Üstte ikon
                const Icon(Icons.person_rounded, size: 64, color: Color.fromARGB(255, 188, 182, 176)),
                const SizedBox(height: 16),
                // Başlık
                const Text(
                  'Welcome',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF6E6259)),
                ),
                const SizedBox(height: 24),
                // Ad giriş alanı
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF9E8D7E)),
                    labelText: 'Name',
                    labelStyle: const TextStyle(color: Color(0xFF8A7566)),
                    filled: true,
                    fillColor: const Color(0xFFF9F5F1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Soyad giriş alanı
                TextField(
                  controller: _surnameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF9E8D7E)),
                    labelText: 'Surname',
                    labelStyle: const TextStyle(color: Color(0xFF8A7566)),
                    filled: true,
                    fillColor: const Color(0xFFF9F5F1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Devam et butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _goToHomePage, // Butona tıklanınca çalışacak fonksiyon
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Continue', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 188, 182, 176),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
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