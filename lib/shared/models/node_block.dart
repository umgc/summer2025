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
    List<Map<String, String>>? questions,
  }) {
    return NodeBlock(
      id: id ?? this.id,
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
    );
  }
}
