import 'dart:convert';

import 'package:flutter/material.dart';

import '../../notifications/models/notification_model.dart';

class Task {
  int id;
  int? userId; // Optional, can be null if not assigned to a user
  String name;
  String description;
  DateTime date;
  TimeOfDay? timeOfDay; // Optional, can be null if not set
  bool isComplete;
  List<Notification_dto>? notifications;
  String? frequency; // e.g., 'daily', 'weekly', 'monthly'
  int? interval; // e.g., every 2 days, every 3 weeks
  int? count; // Number of occurrences
  List<bool>? daysOfWeek; // e.g., [true, false, true, false, true, false, false] for Mon, Wed, Fri



  Task({
    required this.id,
    required this.name,
    this.description = "",
    required this.date,
    this.timeOfDay,
    this.userId,
    this.isComplete = false,
    this.notifications,
    this.frequency,
    this.interval,
    this.count,
    this.daysOfWeek,
  });
  
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] != null ? json['id'] as int : -1,
      name: json['name'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      timeOfDay: json['timeOfDay'] != null
          ? TimeOfDay(
              hour: json['timeOfDay']['hour'],
              minute: json['timeOfDay']['minute'],
            )
          : null,
      userId: json['assignedTo'],
      isComplete: json['isComplete'] ?? false,
      frequency: json['frequency'],
      interval: json['taskInterval'],
      count: json['doCount'],
      daysOfWeek: json['daysOfWeek'] != null
          ? (json['daysOfWeek'] is String
              ? List<bool>.from(jsonDecode(json['daysOfWeek']))
              : List<bool>.from(json['daysOfWeek']))
          : null
    );
  }

  Map<String, dynamic> toJson() {
    String taskType = 'custom'; // Default task type
    if (daysOfWeek != null) {
      taskType = 'dayOfWeek';
    } else if (frequency != null && interval != null) {
      taskType = 'frequency';
    }
    return {
      'name': name,
      'description': description,
      'date': date.toString(),
      'timeOfDay': timeOfDay != null
          ? "${timeOfDay!.hour}:${timeOfDay!.minute}"
          : null,
      'isCompleted': isComplete,
      // 'notifications': null,
      'frequency': frequency,
      'taskInterval': interval,
      'doCount': count,
      'daysOfWeek': jsonEncode(daysOfWeek),
      'taskType': taskType,
    };
  }
}

class FrequencyTask extends Task {
  final String frequency; // e.g., 'daily', 'weekly', 'monthly'
  final int interval; // e.g., every 2 days, every 3 weeks
  final int? count; // Number of occurrences

  FrequencyTask({
    required this.frequency,
    required this.interval,
    this.count = 0,
    required super.id,
    required super.name,
    required super.description,
    required super.date,
    super.timeOfDay,
    super.userId,
    super.isComplete = false,
    super.notifications,
  });

  factory FrequencyTask.fromJson(Map<String, dynamic> json) {
    return FrequencyTask(
      frequency: json['frequency'],
      interval: json['taskInterval'],
      count: json['doCount'],
      id: json['id'],
      name: json['name'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      timeOfDay: json['timeOfDay'] != null
          ? TimeOfDay(
              hour: json['timeOfDay']['hour'],
              minute: json['timeOfDay']['minute'],
            )
          : null,
      userId: json['userId'],
      isComplete: json['isComplete'] ?? false,
      notifications: (json['notifications'] as List?)
          ?.map((n) => Notification_dto.fromJson(n))
          .toList(),
    );
  }
}

class DayOfWeekTask extends Task {
  final List<bool> daysOfWeek; // e.g., [true, false, true, false, true, false, false] for Mon, Wed, Fri

  DayOfWeekTask({
    required this.daysOfWeek,
    required super.id,
    required super.name,
    required super.description,
    required super.date,
    super.timeOfDay,
    super.userId,
    super.isComplete = false,
    super.notifications,
  });

  factory DayOfWeekTask.fromJson(Map<String, dynamic> json) {
    return DayOfWeekTask(
      daysOfWeek: List<bool>.from(json['daysOfWeek']),
      id: json['id'],
      name: json['name'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      timeOfDay: json['timeOfDay'] != null
          ? TimeOfDay(
              hour: json['timeOfDay']['hour'],
              minute: json['timeOfDay']['minute'],
            )
          : null,
      userId: json['userId'],
      isComplete: json['isComplete'] ?? false,
      notifications: (json['notifications'] as List?)
          ?.map((n) => Notification_dto.fromJson(n))
          .toList(),
    );
  }
}