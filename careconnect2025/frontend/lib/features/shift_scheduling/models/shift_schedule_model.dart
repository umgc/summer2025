import 'package:flutter/material.dart';

class ShiftSchedule {
  final int id;
  final String caretakerId;
  final String title;
  final String description;
  final bool recurring;
  final List<bool> daysOfWeek; // List of days the shift occurs
  final DateTime startDate; // First occurrence of the shift
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  ShiftSchedule({
    required this.id,
    required this.caretakerId,
    required this.title,
    required this.description,
    this.recurring = false,
    required this.daysOfWeek,
    required this.startDate,
    required this.startTime,
    required this.endTime,
  });

  factory ShiftSchedule.fromJson(Map<String, dynamic> json) {
    return ShiftSchedule(
      id: json['id'],
      caretakerId: json['caretakerId'],
      title: json['title'],
      description: json['description'],
      recurring: json['recurring'] ?? false,
      daysOfWeek: List<bool>.from(json['daysOfWeek'] ?? []),
      startDate: DateTime.parse(json['startDate']),
      startTime: TimeOfDay(
        hour: json['startTime']['hour'],
        minute: json['startTime']['minute'],
      ),
      endTime: TimeOfDay(
        hour: json['endTime']['hour'],
        minute: json['endTime']['minute'],
      ),
    );
  }
}
