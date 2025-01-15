import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cycle_data.dart';
import 'calendar.dart';
import 'home_page.dart';
import 'settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  final cycleData = CycleData();
  await cycleData.loadData(); // Load stored data

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => cycleData),
      ],
      child: const PeriodApp(),
    ),
  );
}

class PeriodApp extends StatelessWidget {
  const PeriodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: "MoonCycle",
          initialRoute: '/',
          routes: {
            '/calendar': (context) => const CalendarPage(),
            '/settings': (context) => const SettingsPage(),
          },
          home: const HomePage(),
          theme: themeNotifier.isDarkMode
              ? ThemeData.dark() // Dark mode
              : ThemeData.light(), // Light mode
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
