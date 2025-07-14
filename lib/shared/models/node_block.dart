import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class NodeBlock {
  final String id;
  final Offset offset;
  final String title;
  final String type;
  final List<Map<String, String>>? questions;

  // optional metadata
  final String? description;
  final String? welcomeMessage;
  final String? lessonType;
  final String? lessonContent;
  final String? estimatedTime;
  final String? quizTitle;
  final String? passingScore;
  final String? timeLimit;
  final String? conditionExpression;
  final String? truePathLabel;
  final String? falsePathLabel;
  final String? checkpointTitle;
  final String? checkpointNote;
  final String? eventType;
  final String? triggerCondition;
  final String? eventContent;
  final String? eventAnswer;
  final String? parentId; // <--- Crucial: Added parentId field

  NodeBlock({
    String? id,
    required this.offset,
    required this.title,
    required this.type,
    this.description,
    this.welcomeMessage,
    this.lessonType,
    this.lessonContent,
    this.estimatedTime,
    this.quizTitle,
    this.passingScore,
    this.timeLimit,
    this.conditionExpression,
    this.truePathLabel,
    this.falsePathLabel,
    this.checkpointTitle,
    this.checkpointNote,
    this.questions,
    this.eventType,
    this.triggerCondition,
    this.eventContent,
    this.eventAnswer,
    this.parentId, // <--- Added parentId to constructor
  }) : id = id ?? _uuid.v4();

  NodeBlock copyWith({
    String? id,
    Offset? offset,
    String? title,
    String? type,
    String? description,
    String? welcomeMessage,
    String? lessonType,
    String? lessonContent,
    String? estimatedTime,
    String? quizTitle,
    String? passingScore,
    String? timeLimit,
    String? conditionExpression,
    String? truePathLabel,
    String? falsePathLabel,
    String? checkpointTitle,
    String? checkpointNote,
    String? eventType,
    String? triggerCondition,
    String? eventContent,
    String? eventAnswer,
    List<Map<String, String>>? questions,
    String? parentId, // <--- Added parentId to copyWith
  }) {
    return NodeBlock(
      id: id ?? this.id,
      offset: offset ?? this.offset,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      lessonType: lessonType ?? this.lessonContent, // Fixed potential typo here if lessonType was used for content
      lessonContent: lessonContent ?? this.lessonContent,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      quizTitle: quizTitle ?? this.quizTitle,
      passingScore: passingScore ?? this.passingScore,
      timeLimit: timeLimit ?? this.timeLimit,
      conditionExpression: conditionExpression ?? this.conditionExpression,
      truePathLabel: truePathLabel ?? this.truePathLabel,
      falsePathLabel: falsePathLabel ?? this.falsePathLabel,
      checkpointTitle: checkpointTitle ?? this.checkpointTitle,
      checkpointNote: checkpointNote ?? this.checkpointNote,
      questions: questions ?? this.questions,
      eventType: eventType ?? this.eventType,
      triggerCondition: triggerCondition ?? this.triggerCondition,
      eventContent: eventContent ?? this.eventContent,
      eventAnswer: eventAnswer ?? this.eventAnswer,
      parentId: parentId ?? this.parentId, // <--- Copy parentId
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'offset': {'dx': offset.dx, 'dy': offset.dy},
      'title': title,
      'type': type,
      'description': description,
      'welcomeMessage': welcomeMessage,
      'lessonType': lessonType,
      'lessonContent': lessonContent,
      'estimatedTime': estimatedTime,
      'quizTitle': quizTitle,
      'passingScore': passingScore,
      'timeLimit': timeLimit,
      'conditionExpression': conditionExpression,
      'truePathLabel': truePathLabel,
      'falsePathLabel': falsePathLabel,
      'checkpointTitle': checkpointTitle,
      'checkpointNote': checkpointNote,
      'questions': questions,
      'eventType': eventType,
      'triggerCondition': triggerCondition,
      'eventContent': eventContent,
      'eventAnswer': eventAnswer,
      'parentId': parentId, // <--- Include parentId in JSON
    };
  }

  factory NodeBlock.fromJson(Map<String, dynamic> json) {
    return NodeBlock(
      id: json['id'],
      offset: Offset(
        (json['offset']['dx'] as num).toDouble(),
        (json['offset']['dy'] as num).toDouble(),
      ),
      title: json['title'],
      type: json['type'],
      description: json['description'],
      welcomeMessage: json['welcomeMessage'],
      lessonType: json['lessonType'],
      lessonContent: json['lessonContent'],
      estimatedTime: json['estimatedTime'],
      quizTitle: json['quizTitle'],
      passingScore: json['passingScore'],
      timeLimit: json['timeLimit'],
      conditionExpression: json['conditionExpression'],
      truePathLabel: json['truePathLabel'],
      falsePathLabel: json['falsePathLabel'],
      checkpointTitle: json['checkpointTitle'],
      checkpointNote: json['checkpointNote'],
      eventType: json['eventType'],
      triggerCondition: json['triggerCondition'],
      eventContent: json['eventContent'],
      eventAnswer: json['eventAnswer'],
      parentId: json['parentId'], // <--- Extract parentId from JSON
      questions: (json['questions'] as List?)
          ?.map((q) => (q as Map).cast<String, String>())
          .toList(),
    );
  }
}