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

class _HomePageState extends State<HomePage>  /*with AutomaticKeepAliveClientMixin*/{
  final DateTime _focusedDay = DateTime.now(); // Current visible date
  DateTime? _selectedDay; // Selected day
  int _currentIndex = 0; // Track the currently selected tab

  late ScrollController _scrollController;
  bool _hasScrolledToToday = false;

  // @override
  // bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(!_hasScrolledToToday) {
        _scrollToToday();
        _hasScrolledToToday = true;
      }
    });
  }
  void _scrollToToday() {
    const double itemWidth = 76;
    const int daysToCenter = 15;
    const double todayPosition = itemWidth * daysToCenter;
    _scrollController.animateTo(
      todayPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  @override
  void dispose() {
    _scrollController.dispose(); // Dispose of the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cycleData = Provider.of<CycleData>(context);
    final startDate = cycleData.periodStartDate;
    final details = startDate != null ? cycleData.periodDetails[startDate] : null;
    debugPrint("Cycle Data Test: ${cycleData.calculateCyclePhases(context).toString()}");

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
      body:_getBody(_currentIndex, startDate, details),
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

  Widget buildScrollableCalendar(BuildContext context) {

    final cycleData = Provider.of<CycleData>(context);
    final phases = cycleData.calculateCyclePhases(context);
    final phaseColors = cycleData.phaseColors;

    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 35, // Display 30 days
        itemBuilder: (context, index) {
          final date = _focusedDay.add(Duration(days: index - 15)); // Days around the current date
          final isSelected = CalendarPage.isSameDay(date, _selectedDay);
          final isToday = CalendarPage.isSameDay(date, DateTime.now());
          Color backgroundColor = Colors.white;
          phases.forEach((phase, range) {
            if(date.isAfter(range.start.subtract(const Duration(days:1))) &&
                date.isBefore(range.end.add(const Duration(days:1)))) {
              backgroundColor = phaseColors[phase] ?? Colors.grey[300]!;

            }
          });
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
                color: isSelected ? Colors.pink.withOpacity(0.7)
                : isToday ?
                Colors.pinkAccent.withOpacity(0.5) : backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.pink
                      : (isToday ? Colors.pinkAccent : Colors.grey[300]!),
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
    final cycleData = Provider.of<CycleData>(context);
    final String currentPhase = cycleData.calculateCurrentPhase(context);
    debugPrint(currentPhase);
    final phases = cycleData.calculateCyclePhases(context);
    final phaseColors = cycleData.phaseColors;
    String selectedPhase = "No data";
    Color? selectedPhaseColor;

    if (_selectedDay != null) {
      phases.forEach((phase, range) {
        if (_selectedDay!.isAfter(range.start.subtract(const Duration(days: 1))) &&
            _selectedDay!.isBefore(range.end.add(const Duration(days: 1)))) {
          selectedPhase = phase;
          selectedPhaseColor = phaseColors[phase];
        }
      });
    }

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
        buildScrollableCalendar(context),
        if (_selectedDay != null && selectedPhase != "No data")
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Selected Phase: $selectedPhase",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: selectedPhaseColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat.yMMMMd().format(_selectedDay!),
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Current Cycle Phase: $currentPhase",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.circle_rounded, color: phaseColors[currentPhase],)
            ],
          )
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