import 'package:flutter/material.dart';
import '../../notifications/models/notification_model.dart';

class Template {
  final int id;
  final String name;
  final String description;
  final String? frequency;
  final int? interval; // e.g., every 2 days, every 3 weeks
  final int? count;
  final List<bool>? daysOfWeek;
  final TimeOfDay? timeOfDay;
  final Icon icon;
  final List<Notification_dto>? notifications;

  Template({
    required this.id,
    required this.name,
    required this.description,
    this.frequency,
    this.interval,
    this.count,
    this.daysOfWeek,
    this.timeOfDay,
    this.icon = const Icon(Icons.task),
    this.notifications,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    String? timeOfDayStr = (json['timeOfDay'] != null
        ? json['timeOfDay'] as String
        : null);
    final timeParts = timeOfDayStr != null ? timeOfDayStr.split(':') : null;
    TimeOfDay? recTime;
    if (timeParts != null && timeParts.length == 2) {
      recTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }
    return Template(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      frequency: json['frequency'] != null ? json['frequency'] as String : null,
      interval: json['taskInterval'] != null ? json['taskInterval'] as int : null,
      count: json['doCount'] != null ? json['doCount'] as int : null,
      daysOfWeek: (json['daysOfWeek'] != null
          ? (json['daysOfWeek'] as List).map((e) => e as bool).toList()
          : null),
      timeOfDay: recTime,
      icon: json['icon'] != null
          ? Icon(IconData(json['icon'], fontFamily: 'MaterialIcons'))
          : const Icon(Icons.task),
      notifications: (json['notifications'] != null
          ? (json['notifications'] as List)
              .map((n) => Notification_dto.fromJson(n))
              .toList()
          : null),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'frequency': frequency,
      'taskInterval': interval,
      'doCount': count,
      'daysOfWeek': daysOfWeek,
      'timeOfDay': timeOfDay != null
          ? '${timeOfDay!.hour}:${timeOfDay!.minute}'
          : null,
      'icon': icon.icon!.codePoint,
      'notifications': notifications?.map((n) => n.toJson()).toList(),
    };
  }
}