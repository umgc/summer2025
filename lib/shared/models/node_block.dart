import 'package:flutter/material.dart'; // For Offset

class NodeBlock {
  final String id;
  final Offset offset;
  final String type;
  final String title;
  final String? parentId;

  // Lesson Node properties
  final String? lessonType; // 'Text', 'Image', 'Video'
  final String? lessonContent; // Text content, image URL, or video URL
  final String? estimatedTime; // Estimated time to complete lesson

  // Quiz Node properties
  final String? quizTitle;
  final String? passingScore;
  final String? timeLimit;
  final List<Map<String, String>>? questions; // List of {'question': '', 'answer': ''}

  // Decision Node properties
  final String? conditionExpression; // e.g., 'score > 80', 'itemCollected == true'
  final String? truePathLabel;
  final String? falsePathLabel;

  // Checkpoint Node properties
  final String? checkpointTitle;
  final String? checkpointNote;

  // Start Node properties
  final String? welcomeMessage;

  // Event Node properties
  final String? eventType; // e.g., 'Pop Quiz', 'Surprise Task'
  final String? triggerCondition; // e.g., 'Random', 'After Lesson X'
  final String? eventContent; // Content for the event
  final String? eventAnswer; // Answer for pop quizzes in events
  final int? randomTriggerChance; // Percentage (0-100) for random events

  // NEW: Add description field
  final String? description;

  NodeBlock({
    required this.id,
    required this.offset,
    required this.type,
    required this.title,
    this.parentId,
    this.lessonType,
    this.lessonContent,
    this.estimatedTime,
    this.quizTitle,
    this.passingScore,
    this.timeLimit,
    this.questions,
    this.conditionExpression,
    this.truePathLabel,
    this.falsePathLabel,
    this.checkpointTitle,
    this.checkpointNote,
    this.welcomeMessage,
    this.eventType,
    this.triggerCondition,
    this.eventContent,
    this.eventAnswer,
    this.randomTriggerChance,
    this.description, // Initialize the new field
  });

  // copyWith method to facilitate immutable updates
  NodeBlock copyWith({
    String? id,
    Offset? offset,
    String? type,
    String? title,
    String? parentId,
    String? lessonType,
    String? lessonContent,
    String? estimatedTime,
    String? quizTitle,
    String? passingScore,
    String? timeLimit,
    List<Map<String, String>>? questions,
    String? conditionExpression,
    String? truePathLabel,
    String? falsePathLabel,
    String? checkpointTitle,
    String? checkpointNote,
    String? welcomeMessage,
    String? eventType,
    String? triggerCondition,
    String? eventContent,
    String? eventAnswer,
    int? randomTriggerChance,
    String? description, // Add to copyWith
  }) {
    return NodeBlock(
      id: id ?? this.id,
      offset: offset ?? this.offset,
      type: type ?? this.type,
      title: title ?? this.title,
      parentId: parentId ?? this.parentId,
      lessonType: lessonType ?? this.lessonType,
      lessonContent: lessonContent ?? this.lessonContent,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      quizTitle: quizTitle ?? this.quizTitle,
      passingScore: passingScore ?? this.passingScore,
      timeLimit: timeLimit ?? this.timeLimit,
      questions: questions ?? this.questions,
      conditionExpression: conditionExpression ?? this.conditionExpression,
      truePathLabel: truePathLabel ?? this.truePathLabel,
      falsePathLabel: falsePathLabel ?? this.falsePathLabel,
      checkpointTitle: checkpointTitle ?? this.checkpointTitle,
      checkpointNote: checkpointNote ?? this.checkpointNote,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      eventType: eventType ?? this.eventType,
      triggerCondition: triggerCondition ?? this.triggerCondition,
      eventContent: eventContent ?? this.eventContent,
      eventAnswer: eventAnswer ?? this.eventAnswer,
      randomTriggerChance: randomTriggerChance ?? this.randomTriggerChance,
      description: description ?? this.description, // Update here
    );
  }

  // toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'offset': {'dx': offset.dx, 'dy': offset.dy},
      'type': type,
      'title': title,
      'parentId': parentId,
      'lessonType': lessonType,
      'lessonContent': lessonContent,
      'estimatedTime': estimatedTime,
      'quizTitle': quizTitle,
      'passingScore': passingScore,
      'timeLimit': timeLimit,
      'questions': questions,
      'conditionExpression': conditionExpression,
      'truePathLabel': truePathLabel,
      'falsePathLabel': falsePathLabel,
      'checkpointTitle': checkpointTitle,
      'checkpointNote': checkpointNote,
      'welcomeMessage': welcomeMessage,
      'eventType': eventType,
      'triggerCondition': triggerCondition,
      'eventContent': eventContent,
      'eventAnswer': eventAnswer,
      'randomTriggerChance': randomTriggerChance,
      'description': description, // Add to JSON
    };
  }

  // fromJson factory for deserialization
  factory NodeBlock.fromJson(Map<String, dynamic> json) {
    return NodeBlock(
      id: json['id'] as String,
      offset: Offset(
        (json['offset'] as Map<String, dynamic>)['dx'] as double, // Ensure casting to Map<String, dynamic>
        (json['offset'] as Map<String, dynamic>)['dy'] as double, // Ensure casting to Map<String, dynamic>
      ),
      type: json['type'] as String,
      title: json['title'] as String,
      parentId: json['parentId'] as String?,
      lessonType: json['lessonType'] as String?,
      lessonContent: json['lessonContent'] as String?,
      estimatedTime: json['estimatedTime'] as String?,
      quizTitle: json['quizTitle'] as String?,
      passingScore: json['passingScore'] as String?,
      timeLimit: json['timeLimit'] as String?,
      questions: (json['questions'] as List<dynamic>?)
          ?.map((q) => Map<String, String>.from(q as Map))
          .toList(),
      conditionExpression: json['conditionExpression'] as String?,
      truePathLabel: json['truePathLabel'] as String?,
      falsePathLabel: json['falsePathLabel'] as String?,
      checkpointTitle: json['checkpointTitle'] as String?,
      checkpointNote: json['checkpointNote'] as String?,
      welcomeMessage: json['welcomeMessage'] as String?,
      eventType: json['eventType'] as String?,
      triggerCondition: json['triggerCondition'] as String?,
      eventContent: json['eventContent'] as String?,
      eventAnswer: json['eventAnswer'] as String?,
      randomTriggerChance: json['randomTriggerChance'] as int?,
      description: json['description'] as String?, // Read from JSON
    );
  }
}