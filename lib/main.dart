import 'package:flutter/material.dart';
import 'package:moon_cycle/period_details_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cycle_data.dart';
import 'calendar.dart';
import 'home_page.dart';
import 'settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cycleData = CycleData();
  await cycleData.loadData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => cycleData),
        ChangeNotifierProvider(create: (_) => SettingsProvider())
      ],
      child: const PeriodApp(),
    ),
  );
}

class PeriodApp extends StatelessWidget {
  const PeriodApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    debugPrint("sus ${settings.periodLength}");
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
