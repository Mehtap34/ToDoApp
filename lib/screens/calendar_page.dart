import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // Takvim arayüzü için kütüphane
import '../models/task.dart'; // Task modelini içe aktarır

// CalendarPage: Tüm görevlerin takvim üzerinde görselleştirildiği sayfa
class CalendarPage extends StatefulWidget {
  final List<Task> allTasks; // Dışarıdan alınan tüm görev listesi

  const CalendarPage({super.key, required this.allTasks});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Kullanıcının takvimde seçtiği tarih (varsayılan: bugün)
  DateTime _selectedDay = DateTime.now();

  // Seçilen güne ait görevleri filtreleyip döner
  List<Task> get tasksForSelectedDay {
    return widget.allTasks
        .where(
          (task) =>
              task.dueDate != null &&
              task.dueDate!.year == _selectedDay.year &&
              task.dueDate!.month == _selectedDay.month &&
              task.dueDate!.day == _selectedDay.day,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E8), // Arka plan rengi (pastel ivory)
      appBar: AppBar(
        title: const Text('Calendar', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFF4E8), // Uygun tema rengi
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black), // Geri butonu vs. siyah
      ),
      body: Column(
        children: [
          // Takvim bileşeni
          Container(
            color: const Color(0xFFFFF4E8), // Takvim arka plan rengi
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 01, 01), // Takvim başlangıç tarihi
              lastDay: DateTime.utc(2030, 12, 31),  // Takvim bitiş tarihi
              focusedDay: _selectedDay, // Odaklanılan gün
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day), // Seçili gün kontrolü
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay; // Seçili günü güncelle
                });
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Color(0xFFE0E0E0), // Bugünün arka planı (gri daire)
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFFB7CAB1), // Seçili gün rengi (sage)
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(color: Colors.white), // Seçili gün yazısı
                weekendTextStyle: TextStyle(color: Colors.black), // Hafta sonu yazı rengi
                defaultTextStyle: TextStyle(color: Colors.black), // Diğer günler yazı rengi
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false, // Ay/hafta görünümü düğmesi kapalı
                titleCentered: true, // Ay başlığı ortalanmış
                titleTextStyle: TextStyle(
                  color: Color(0xFFB7CAB1), // Ay başlığı rengi
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFFB7CAB1)),
                rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFFB7CAB1)),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.black),
                weekendStyle: TextStyle(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Seçilen güne ait görev listesi
          Expanded(
            child: tasksForSelectedDay.isEmpty
                // Görev yoksa mesaj göster
                ? const Center(
                    child: Text(
                      "No tasks for today.",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                // Görev varsa liste olarak göster
                : ListView.builder(
                    itemCount: tasksForSelectedDay.length,
                    itemBuilder: (context, index) {
                      final task = tasksForSelectedDay[index];
                      return Card(
                        color: const Color(0xFFF7F6F2), // Kart arka plan rengi
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(task.title), // Görev başlığı
                          subtitle: Text(task.category), // Görev kategorisi
                          trailing: Icon(
                            task.isCompleted
                                ? Icons.check_circle // Tamamlandıysa yeşil tik
                                : Icons.radio_button_unchecked, // Değilse boş daire
                            color: task.isCompleted
                                ? const Color(0xFF7DBF67)
                                : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
