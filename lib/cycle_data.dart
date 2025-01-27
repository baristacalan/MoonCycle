import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:moon_cycle/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CycleData extends ChangeNotifier {
  DateTime? _periodStartDate;
  final Map<DateTime, Map<String, String>> _periodDetails = {};
  Map<DateTime, List<String>> _events = {};

  DateTime? get periodStartDate => _periodStartDate;
  Map<DateTime, Map<String, String>> get periodDetails => _periodDetails;
  Map<DateTime, List<String>> get events => _events;
  final Map<String, Color> phaseColors = {
    "Menstrual": Colors.red,
    "Follicular": Colors.blue,
    "Ovulation": Colors.green,
    "Luteal": Colors.orange,
  };

  Future<void> setPeriodStartDate(DateTime date) async {
    _periodStartDate = date;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('periodStartDate', date.toIso8601String());
  }

  Future<void> setPeriodDetails(DateTime date, Map<String, String> details) async {
    _periodDetails[date] = details;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final encodedDetails = jsonEncode(
      _periodDetails.map((key, value) => MapEntry(key.toIso8601String(), value)),
    );
    await prefs.setString('periodDetails', encodedDetails);
  }

  Future<void> addEvent(DateTime date, String event) async {
    if (_events[date] == null) {
      _events[date] = [];
    }
    _events[date]!.add(event);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final encodedEvents = jsonEncode(
      _events.map((key, value) => MapEntry(key.toIso8601String(), value)),
    );
    await prefs.setString('events', encodedEvents);
  }

  Future<void> removeEvent(DateTime date) async {
    if (_events[date] != null && _events[date]!.isNotEmpty) {
      _events[date]!.removeLast();

      if(_periodStartDate == date) {
        _periodStartDate = null;
      }
      _periodDetails.remove(date);
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final encodedEvents = jsonEncode(
        _events.map((key, value) => MapEntry(key.toIso8601String(), value)),
      );
      await prefs.setString('events', encodedEvents);
    }
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final eventsString = prefs.getString('events');
    if (eventsString != null) {
      final decodedEvents = jsonDecode(eventsString) as Map<String, dynamic>;
      _events = decodedEvents.map((key, value) =>
          MapEntry(DateTime.parse(key), List<String>.from(value as List)));
    }

    notifyListeners();
  }

  Map<String, DateTimeRange> calculateCyclePhases(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if(_periodStartDate == null) return {};
    final startDate = _periodStartDate!;
    final cycleLength = settings.cycleLength;
    final periodLength = settings.periodLength;

    return{
      "Menstrual": DateTimeRange(
          start: startDate,
          end: startDate.add(Duration(days: periodLength - 1))),

      "Follicular": DateTimeRange(
          start: startDate.add(Duration(days: periodLength)),
          end: startDate.add(const Duration(days: 12))),

      "Ovulation": DateTimeRange(
          start: startDate.add(const Duration(days: 13)),
          end: startDate.add(const Duration(days: 15 ))),

      "Luteal": DateTimeRange(
          start: startDate.add(const Duration(days: 16)),
          end: startDate.add(Duration(days: cycleLength - 1))),
    };
  }

  String calculateCurrentPhase(BuildContext context) {
    if(_periodStartDate == null) return "No data";
    final now = DateTime.now();
    final cyclePhases = calculateCyclePhases(context);

    for(var entry in cyclePhases.entries) {
      if(now.isAfter(entry.value.start) && now.isBefore(entry.value.end)) {
        return entry.key;
      }
    }
    return "No data";
  }
}