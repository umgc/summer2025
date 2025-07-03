import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

// NICOLE EDITS: Define a private sentinel class for copyWith
class _Sentinel {
  const _Sentinel();
}

class NodeBlock {
  final String id;
  final Offset offset;
  final String title;
  final String type;

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
  }) : id = id ?? _uuid.v4();

  NodeBlock copyWith({
    String? id,
    Offset? offset,
    String? title,
    String? type,
    // NICOLE EDITS: Use Object? and a default sentinel value for nullable fields
    Object? description = const _Sentinel(),
    Object? welcomeMessage = const _Sentinel(),
    Object? lessonType = const _Sentinel(),
    Object? lessonContent = const _Sentinel(),
    Object? estimatedTime = const _Sentinel(),
    Object? quizTitle = const _Sentinel(),
    Object? passingScore = const _Sentinel(),
    Object? timeLimit = const _Sentinel(),
    Object? conditionExpression = const _Sentinel(),
    Object? truePathLabel = const _Sentinel(),
    Object? falsePathLabel = const _Sentinel(),
    Object? checkpointTitle = const _Sentinel(),
    Object? checkpointNote = const _Sentinel(),
  }) {
    return NodeBlock(
      id: id ?? this.id,
      offset: offset ?? this.offset,
      title: title ?? this.title,
      type: type ?? this.type,
      // NICOLE EDITS: Check if the parameter is the sentinel.
      // If it is, use the original value. Otherwise, cast and use the provided value (which can be null).
      description: description is _Sentinel
          ? this.description
          : description as String?,
      welcomeMessage: welcomeMessage is _Sentinel
          ? this.welcomeMessage
          : welcomeMessage as String?,
      lessonType: lessonType is _Sentinel
          ? this.lessonType
          : lessonType as String?,
      lessonContent: lessonContent is _Sentinel
          ? this.lessonContent
          : lessonContent as String?,
      estimatedTime: estimatedTime is _Sentinel
          ? this.estimatedTime
          : estimatedTime as String?,
      quizTitle: quizTitle is _Sentinel ? this.quizTitle : quizTitle as String?,
      passingScore: passingScore is _Sentinel
          ? this.passingScore
          : passingScore as String?,
      timeLimit: timeLimit is _Sentinel ? this.timeLimit : timeLimit as String?,
      conditionExpression: conditionExpression is _Sentinel
          ? this.conditionExpression
          : conditionExpression as String?,
      truePathLabel: truePathLabel is _Sentinel
          ? this.truePathLabel
          : truePathLabel as String?,
      falsePathLabel: falsePathLabel is _Sentinel
          ? this.falsePathLabel
          : falsePathLabel as String?,
      checkpointTitle: checkpointTitle is _Sentinel
          ? this.checkpointTitle
          : checkpointTitle as String?,
      checkpointNote: checkpointNote is _Sentinel
          ? this.checkpointNote
          : checkpointNote as String?,
    );
  }
}
