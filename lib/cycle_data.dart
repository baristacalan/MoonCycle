import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CycleData extends ChangeNotifier {
  DateTime? _mensturationStartDate;
  final Map<DateTime, Map<String, String>> _periodDetails = {};
  Map<DateTime, List<String>> _events = {}; // Add this for events

  DateTime? get mensturationStartDate => _mensturationStartDate;
  Map<DateTime, Map<String, String>> get periodDetails => _periodDetails;
  Map<DateTime, List<String>> get events => _events;

  // Save menstruation start date
  Future<void> setMensturationStartDate(DateTime date) async {
    _mensturationStartDate = date;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mensturationStartDate', date.toIso8601String());
  }
  // Save period details
  Future<void> setPeriodDetails(DateTime date, Map<String, String> details) async {
    _periodDetails[date] = details;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final encodedDetails = jsonEncode(
      _periodDetails.map((key, value) => MapEntry(key.toIso8601String(), value)),
    );
    await prefs.setString('periodDetails', encodedDetails);
  }
  // Add event to a date
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

  // Remove event from a date
  Future<void> removeEvent(DateTime date) async {
    if (_events[date] != null && _events[date]!.isNotEmpty) {
      _events[date]!.removeLast();
      _periodDetails[date]!.clear();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final encodedEvents = jsonEncode(
        _events.map((key, value) => MapEntry(key.toIso8601String(), value)),
      );
      await prefs.setString('events', encodedEvents);
    }
  }

  // Load events from SharedPreferences
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
}