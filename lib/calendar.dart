import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'cycle_data.dart';
import 'period_details_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final cycleData = Provider.of<CycleData>(context);
    final events = cycleData.events;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "CupertinoSystemText")),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(DateTime.now().year - 10, 1, 1),
            lastDay: DateTime.utc(DateTime.now().year + 10, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) => events[day] ?? [],


          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _addEvent(context, cycleData),
                child: const Text("Add Event"),
              ),
              ElevatedButton(
                onPressed: () => _removeEvent(context, cycleData),
                child: const Text("Remove Event"),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: _selectStartDate
              ,
              child: const Text("Set Mensturation Start Date"),
            ),
          ),
          if (_selectedDay != null) ...[
            Text(
              "Selected Date: ${DateFormat.yMMMMd().format(_selectedDay!)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._getEventsForDay(events, _selectedDay!).map((event) => ListTile(
              title: Text(event),
              leading: const Icon(Icons.event, color: Colors.pinkAccent),
            )),
          ],
        ],
      ),
    );
  }

  void _addEvent(BuildContext context, CycleData cycleData) {
    if (_selectedDay == null) return;

    showDialog(
      context: context,
      builder: (context) {
        String eventTitle = "";
        return AlertDialog(
          title: const Text("Add Event"),
          content: TextField(
            onChanged: (value) {
              eventTitle = value;
            },
            decoration: const InputDecoration(hintText: "Enter event title"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await cycleData.addEvent(_selectedDay!, eventTitle);
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _removeEvent(BuildContext context, CycleData cycleData) {
    if (_selectedDay == null) return;
    cycleData.removeEvent(_selectedDay!);
  }

  void _selectStartDate() async {
    if (_selectedDay == null) return;
    // Navigate to PeriodDetailsPage and wait for details
    final details = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PeriodDetailsPage(startDate: _selectedDay!),
      ),
    );
    if (details != null) {
      final cycleData = Provider.of<CycleData>(context, listen: false);
      await cycleData.setMensturationStartDate(_selectedDay!);
      await cycleData.setPeriodDetails(_selectedDay!, details);
      setState(() {
        // Change it back to cycleData._events if any problems occur.
        if (cycleData.events[_selectedDay!] == null) {
          cycleData.events[_selectedDay!] = [];
        }
        cycleData.events[_selectedDay!]!.add("Menstruation Start: ${details['bleeding']}, Mood:${details['mood']}, Pain: ${details['pain']}");
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Period details saved for${DateFormat.yMMMMd().format(_selectedDay!)}"),
        ),
      );
    }
  }

  List<String> _getEventsForDay(Map<DateTime, List<String>> events, DateTime day) {
    return events[day] ?? [];
  }

}