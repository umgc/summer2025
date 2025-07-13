import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class NodeBlock {
  final String id;
  // adding scenarioID field
  final String scenarioId;
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

  NodeBlock({
    String? id,
    // adding scenarioID field
    this.scenarioId = 'DEFAULT_SCENARIO', // Default value for new nodes
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
  }) : id = id ?? _uuid.v4();

  // Added factory constructor for deserialization from JSON
  factory NodeBlock.fromJson(Map<String, dynamic> json) {
    return NodeBlock(
      id: json['id'] as String,
      scenarioId:
          json['scenarioId'] as String? ??
          'DEFAULT_SCENARIO', // Handle optional scenarioId
      offset: Offset(
        (json['offset']['dx'] as num)
            .toDouble(), // Ensure type safety for Offset components
        (json['offset']['dy'] as num).toDouble(),
      ),
      title: json['title'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      welcomeMessage: json['welcomeMessage'] as String?,
      lessonType: json['lessonType'] as String?,
      lessonContent: json['lessonContent'] as String?,
      estimatedTime: json['estimatedTime'] as String?,
      quizTitle: json['quizTitle'] as String?,
      passingScore: json['passingScore'] as String?,
      timeLimit: json['timeLimit'] as String?,
      questions: (json['questions'] as List<dynamic>?)
          ?.map((q) => (q as Map<String, dynamic>).cast<String, String>())
          .toList(),
      conditionExpression: json['conditionExpression'] as String?,
      truePathLabel: json['truePathLabel'] as String?,
      falsePathLabel: json['falsePathLabel'] as String?,
      checkpointTitle: json['checkpointTitle'] as String?,
      checkpointNote: json['checkpointNote'] as String?,
      eventType: json['eventType'] as String?,
      triggerCondition: json['triggerCondition'] as String?,
      eventContent: json['eventContent'] as String?,
      eventAnswer: json['eventAnswer'] as String?,
    );
  }

  // Added toJson() method for serialization to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scenarioId': scenarioId, // Include scenarioId in JSON output
      'offset': {'dx': offset.dx, 'dy': offset.dy},
      'title': title,
      'type': type,
      if (description != null) 'description': description,
      if (welcomeMessage != null) 'welcomeMessage': welcomeMessage,
      if (lessonType != null) 'lessonType': lessonType,
      if (lessonContent != null) 'lessonContent': lessonContent,
      if (estimatedTime != null) 'estimatedTime': estimatedTime,
      if (quizTitle != null) 'quizTitle': quizTitle,
      if (passingScore != null) 'passingScore': passingScore,
      if (timeLimit != null) 'timeLimit': timeLimit,
      if (questions != null && questions!.isNotEmpty) 'questions': questions,
      if (conditionExpression != null)
        'conditionExpression': conditionExpression,
      if (truePathLabel != null) 'truePathLabel': truePathLabel,
      if (falsePathLabel != null) 'falsePathLabel': falsePathLabel,
      if (checkpointTitle != null) 'checkpointTitle': checkpointTitle,
      if (checkpointNote != null) 'checkpointNote': checkpointNote,
      if (eventType != null) 'eventType': eventType,
      if (triggerCondition != null) 'triggerCondition': triggerCondition,
      if (eventContent != null) 'eventContent': eventContent,
      if (eventAnswer != null) 'eventAnswer': eventAnswer,
    };
  }

  NodeBlock copyWith({
    String? id,
    // Added 'scenarioId' to copyWith method
    String? scenarioId,
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
  }) {
    return NodeBlock(
      id: id ?? this.id,
      // Used 'scenarioId' in copyWith return
      scenarioId: scenarioId ?? this.scenarioId,
      offset: offset ?? this.offset,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      lessonType: lessonType ?? this.lessonType,
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
    );
  }
}
