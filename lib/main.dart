import 'package:flutter/material.dart';
import 'package:moon_cycle/splash_screen.dart';
import 'package:provider/provider.dart';
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
    final cycleData = Provider.of<CycleData>(context);
    debugPrint("Cycle Data Test: ${cycleData.calculateCyclePhases(context).toString()}");
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: "MoonCycle",
          initialRoute: '/',
          routes: {
            '/calendar': (context) => const CalendarPage(),
            '/settings': (context) => const SettingsPage(),
          },
          home: const SplashScreen(),
          theme: themeNotifier.isDarkMode
              ? ThemeData.dark() // Dark mode
              : ThemeData.light(), // Light mode
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
