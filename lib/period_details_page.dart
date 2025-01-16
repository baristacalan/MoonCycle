import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PeriodDetailsPage extends StatefulWidget {
  final DateTime startDate;

  const PeriodDetailsPage({required this.startDate, super.key});

  @override
  State<PeriodDetailsPage> createState() => _PeriodDetailsPageState();
}

class _PeriodDetailsPageState extends State<PeriodDetailsPage> {
  String bleedingLevel = "Light";
  String mood = "Neutral";
  String desire = "Low";
  String pain = "None";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Period Details"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Details for ${DateFormat.yMMMMd().format(widget.startDate)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            buildDropdown(
              title: "Bleeding Level",
              value: bleedingLevel,
              items: ["Light", "Medium", "Heavy"],
              onChanged: (value) => setState(() => bleedingLevel = value!),
            ),
            buildDropdown(
              title: "Mood",
              value: mood,
              items: ["Happy", "Neutral", "Sad"],
              onChanged: (value) => setState(() => mood = value!),
            ),
            buildDropdown(
              title: "Desire",
              value: desire,
              items: ["Low", "Moderate", "High"],
              onChanged: (value) => setState(() => desire = value!),
            ),
            buildDropdown(
              title: "Pain",
              value: pain,
              items: ["None", "Mild", "Severe"],
              onChanged: (value) => setState(() => pain = value!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'bleeding': bleedingLevel,
                  'mood': mood,
                  'desire': desire,
                  'pain': pain,
                });
              },
              child: const Text("Save Details"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdown({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              value: value,
              items: items
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}