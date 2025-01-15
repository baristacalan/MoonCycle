import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  late TextEditingController _cycleLengthController;
  late TextEditingController _periodLengthController;
  static bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _cycleLengthController = TextEditingController(text: settings.cycleLength.toString());
    _periodLengthController = TextEditingController(text: settings.periodLength.toString());
    _cycleLengthController.addListener(_checkForChanges);
    _periodLengthController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final hasChanges =  _cycleLengthController.text != settings.cycleLength.toString() ||
        _periodLengthController.text != settings.periodLength.toString();
    if(_hasChanges != hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }


  @override
  void dispose() {
    _cycleLengthController.dispose();
    _periodLengthController.dispose();
    super.dispose();
  }

  // Future<bool> _onPop() async {
  //   final settings = Provider.of<SettingsProvider>(context, listen: false);
  //
  //   if (!_hasChanges) return true; // If no changes, allow navigation
  //
  //   final result = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text("Unsaved Changes"),
  //       content: const Text("You have unsaved changes. Do you want to save them before leaving?"),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop(false); // Don't save, just leave
  //           },
  //           child: const Text("No"),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             settings.saveSettings(); // Save settings changes
  //             Navigator.of(context).pop(true); // Allow navigation
  //           },
  //           child: const Text("Yes"),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   return result ?? false; // Default to false if dialog is dismissed
  // }


  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
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
              // onChanged: (value) {
              //   settings.setCycleLength(int.tryParse(value) ?? settings.cycleLength);
              // },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _periodLengthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Period Length (days)",
                border: OutlineInputBorder(),
              ),
              // onChanged: (value) {
              //   settings.setPeriodLength(int.tryParse(value) ?? settings.periodLength);
              // },
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
            const SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 40,
                    child: ElevatedButton(onPressed: () async{
                      settings.setCycleLength(int.parse(_cycleLengthController.text));
                      settings.setPeriodLength(int.parse(_periodLengthController.text));
                      await settings.saveSettings();
                      debugPrint("Cycle Length: ${settings.cycleLength.toString()}");
                      debugPrint("Period Length: ${settings.periodLength.toString()}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Settings Saved Successfully!"),)
                      );
                    },
                      child: const Text("Save",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    height: 40,
                    child: ElevatedButton(onPressed: () async{
                      await settings.resetSettings();
                      _cycleLengthController.text = settings.cycleLength.toString();
                      _periodLengthController.text = settings.periodLength.toString();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Settings Reset!")));
                    },
                      child: const Text("Reset",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsProvider with ChangeNotifier {
  int _cycleLength = 28;
  int _periodLength = 5;

  int get cycleLength => _cycleLength;
  int get periodLength => _periodLength;

  SettingsProvider() {
    loadSettings();
  }

  void setCycleLength(int length) {
    _cycleLength = length;
    notifyListeners();
  }

  void setPeriodLength(int length) {
    _periodLength = length;
    notifyListeners();
  }

  Future<void> saveSettings() async{

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('_cycleLength', _cycleLength);
    await prefs.setInt('_periodLength', _periodLength);

    _SettingsPageState._hasChanges = false;
  }

  Future<void> loadSettings() async{
    final prefs = await SharedPreferences.getInstance();
    _cycleLength = prefs.getInt('_cycleLength') ?? 28;
    _periodLength = prefs.getInt('_periodLength') ?? 5;
    notifyListeners();
  }

  Future<void> resetSettings() async {
    _cycleLength = 28;
    _periodLength = 5;
    notifyListeners();
    await saveSettings();
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