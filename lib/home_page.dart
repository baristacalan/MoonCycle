import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import "calendar.dart";
import 'cycle_data.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DateTime _focusedDay = DateTime.now(); // Current visible date
  DateTime? _selectedDay; // Selected day
  int _currentIndex = 0; // Track the currently selected tab

  DateTime lastPeriodStartDate = DateTime(2025, 2, 1); // Temporary value.

  @override
  Widget build(BuildContext context) {
    final cycleData = Provider.of<CycleData>(context);
    final startDate = cycleData.mensturationStartDate;
    final details = startDate != null ? cycleData.periodDetails[startDate] : null;

    // Debugging: Add these prints to ensure values are being fetched
    debugPrint("Start Date: $startDate");
    debugPrint("Details: $details");
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(_focusedDay);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          formattedDate,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Notification icon action
            },
          ),
        ],
      ),
      body: _getBody(_currentIndex, startDate, details),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home,), label: "Home",),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendar"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        elevation: 16,
      ),
    );
  }

  String getCurrentCyclePhase() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final today = DateTime.now();
    final cycleLength = settings.cycleLength;
    final periodLength = settings.periodLength;

    debugPrint("Cycle Length: ${cycleLength.toString()}");
    debugPrint("Period Length: ${periodLength.toString()}");
    final daysSinceLastPeriod = today.difference(lastPeriodStartDate).inDays % cycleLength;
    if (daysSinceLastPeriod <= periodLength) {
      return "Menstrual Phase";
    } else if (daysSinceLastPeriod <= 13) {
      return "Follicular Phase";
    } else if (daysSinceLastPeriod <= 15) {
      return "Ovulation Phase";
    } else {
      return "Luteal Phase";
    }
  }

  Widget buildScrollableCalendar() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 30, // Display 30 days
        itemBuilder: (context, index) {
          final date = _focusedDay.add(Duration(days: index - 15)); // Days around the current date
          final isSelected = CalendarPage.isSameDay(date, _selectedDay);
          final isToday = CalendarPage.isSameDay(date, DateTime.now());
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedDay = null;
                } else {
                  _selectedDay = date;
                }
              });
            },
            onDoubleTap: () {
              setState(() {
                _currentIndex = 1;
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isToday ? Colors.pinkAccent : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.pink
                      : (isSelected ? Colors.pinkAccent : Colors.grey[300]!),
                  width: 3,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date), // Weekday (e.g., Mon, Tue)
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${date.day}", // Day of the month
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String calculateDateDifferences(DateTime startDate, DateTime endDate) {

    int years = endDate.year - startDate.year;
    int months = endDate.month - startDate.month;
    int days = endDate.day - startDate.day;
    if(days < 0) {
      months -= 1;
      days += DateTime(endDate.year, endDate.month - 1, 0).day;
    }
    if(months < 0) {
      years -= 1;
      months += 12;
    }

    if(years < 0) {
      years = -years;
    }

    if(years == 0 && months == 0 && days == 0) {
      return "Today!";
    }
    else if(years == 0) {
      return "$months months, $days days have remained.";
    }
    else{
      return "$years years, $months months and $days days have remained";
    }

  }

  DateTime getNextValentinesDayDate() {
    final now = DateTime.now();
    final valentinesDayThisYear = DateTime(DateTime.now().year, 2, 14);
    if(now.isAfter(valentinesDayThisYear)) {
      return DateTime(DateTime.now().year+1, 2, 14);
    }
    else{return valentinesDayThisYear;}
  }

  Widget _getBody(int index, DateTime? startDate, Map<String, String>? details) {
    final currentPhase = getCurrentCyclePhase();

    if (index == 1) {
      // Calendar Page
      return const CalendarPage();
    } else if (index == 2) {
      // Settings Page
      return const SettingsPage();
    }

    // Default: Home Page
    return Column(
      children: [
        buildScrollableCalendar(),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, color: Colors.pinkAccent, size: 12),
                  SizedBox(width: 4),
                  Text("Current Phase"),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.circle, color: Colors.lightBlue, size: 12),
                  SizedBox(width: 4),
                  Text("Period Duration"),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "Current Cycle Phase: $currentPhase",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GestureDetector(
                child: buildCard(
                  title: "Now",
                  subtitle: currentPhase,
                  date: DateFormat.yMMMMd().format(DateTime.now()),
                  actionText: "Now",
                  actionColor: Colors.lightBlue,
                  icon: Icons.female,
                ),
                onTap: () {
                  setState(() {
                    _currentIndex = 1;
                  });},
              ),
              buildCard(
                title: "Period Details",
                subtitle: startDate != null && details!.isNotEmpty
                    ? "Details saved for ${DateFormat.yMMMMd().format(startDate)}"
                    : "No period data available",
                date: details != null && details.isNotEmpty
                    ? "Bleeding: ${details['bleeding'] ?? 'Unknown'}, Mood: ${details['mood'] ?? 'Unknown'}"
                    : "No details saved",
                actionText: "View",
                actionColor: Colors.blue,
                icon: Icons.health_and_safety,
              ),
              GestureDetector(
                child: buildCard(
                  title: "Valentine's Day",
                  subtitle: calculateDateDifferences(DateTime.now(), getNextValentinesDayDate()),
                  date: DateFormat.yMMMMd().format(getNextValentinesDayDate()),
                  actionText: "Click to open calendar",
                  actionColor: Colors.blue,
                  icon:  Icons.favorite_outlined,
                  iconColor: const Color.fromRGBO(150, 20, 20, 1),

                ),
                onTap: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCard({
    required String title,
    required String subtitle,
    required String date,
    required String actionText,
    required Color actionColor,
    required IconData icon,
    Color? iconColor
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: iconColor ?? Colors.pink),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  actionText,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: actionColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}