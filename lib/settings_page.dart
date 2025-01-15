import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int cycleLength = 28; // Default cycle length
  int periodLength = 5; // Default period length
  final TextEditingController _cycleLengthController =
  TextEditingController(text: "28");
  final TextEditingController _periodLengthController =
  TextEditingController(text: "5");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Cycle and Period Settings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _cycleLengthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Cycle Length (days)",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  cycleLength = int.tryParse(value) ?? cycleLength;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _periodLengthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Period Length (days)",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  periodLength = int.tryParse(value) ?? periodLength;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Appearance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: Provider.of<ThemeNotifier>(context).isDarkMode,
              onChanged: (bool value) {
                Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeNotifier with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  void toggleTheme(){
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}