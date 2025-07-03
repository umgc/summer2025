// This file contains unit tests for the NodeBlock model.
//
// These tests verify:
// - The correct initialization of NodeBlock instances using its constructor,
//   including automatic ID generation when not provided.
// - The functionality of the copyWith method to create new instances
//   with updated or retained properties.

import 'package:flutter_test/flutter_test.dart'; // Provides test and expect functions
import 'package:flutter/material.dart'; // Required for Offset
import 'package:deeptrainfront/shared/models/node_block.dart'; // Import your NodeBlock model

void main() {
  group('NodeBlock', () {
    // Test 1: NodeBlock constructor - ID is generated when not provided
    test('NodeBlock constructor generates a unique ID if not provided', () {
      final offset = Offset(100, 100);
      final node = NodeBlock(
        offset: offset,
        title: 'Test Node',
        type: 'Lesson',
      );

      // Verify that the ID is not null and is a String
      expect(node.id, isNotNull);
      expect(node.id, isA<String>());
      // A basic check for UUID format (length)
      expect(node.id.length, greaterThan(0));
    });

    // Test 2: NodeBlock constructor - provided ID is used
    test('NodeBlock constructor uses provided ID', () {
      const customId = 'my-custom-node-id';
      final offset = Offset(50, 50);
      final node = NodeBlock(
        id: customId,
        offset: offset,
        title: 'Another Node',
        type: 'Quiz',
      );

      expect(node.id, customId);
      expect(node.offset, offset);
      expect(node.title, 'Another Node');
      expect(node.type, 'Quiz');
    });

    // Test 3: NodeBlock constructor - all properties are correctly assigned
    test('NodeBlock constructor assigns all properties correctly', () {
      final node = NodeBlock(
        offset: Offset(200, 200),
        title: 'Full Node',
        type: 'Decision',
        description: 'A detailed description',
        welcomeMessage: 'Welcome!',
        lessonType: 'Video',
        lessonContent: 'Video URL',
        estimatedTime: '30',
        quizTitle: 'Intro Quiz',
        passingScore: '70',
        timeLimit: '15',
        conditionExpression: 'x > 5',
        truePathLabel: 'Go True',
        falsePathLabel: 'Go False',
        checkpointTitle: 'Checkpoint Alpha',
        checkpointNote: 'Important milestone',
      );

      expect(node.offset, Offset(200, 200));
      expect(node.title, 'Full Node');
      expect(node.type, 'Decision');
      expect(node.description, 'A detailed description');
      expect(node.welcomeMessage, 'Welcome!');
      expect(node.lessonType, 'Video');
      expect(node.lessonContent, 'Video URL');
      expect(node.estimatedTime, '30');
      expect(node.quizTitle, 'Intro Quiz');
      expect(node.passingScore, '70');
      expect(node.timeLimit, '15');
      expect(node.conditionExpression, 'x > 5');
      expect(node.truePathLabel, 'Go True');
      expect(node.falsePathLabel, 'Go False');
      expect(node.checkpointTitle, 'Checkpoint Alpha');
      expect(node.checkpointNote, 'Important milestone');
    });

    // Test 4: copyWith method - updates specified fields and retains others
    test('copyWith updates specified fields and retains others', () {
      final originalNode = NodeBlock(
        offset: Offset(10, 10),
        title: 'Original Title',
        type: 'Start',
        description: 'Original Description',
      );

      final updatedNode = originalNode.copyWith(
        offset: Offset(20, 20),
        title: 'Updated Title',
        welcomeMessage: 'New Welcome',
      );

      // Verify updated fields
      expect(updatedNode.offset, Offset(20, 20));
      expect(updatedNode.title, 'Updated Title');
      expect(updatedNode.welcomeMessage, 'New Welcome');

      // Verify retained fields
      expect(updatedNode.id, originalNode.id); // ID should be retained
      expect(updatedNode.type, 'Start');
      expect(updatedNode.description, 'Original Description');

      // Verify that it's a new instance
      expect(updatedNode, isNot(same(originalNode)));
    });

    // Test 5: copyWith method - all fields can be updated
    test('copyWith can update all fields', () {
      final originalNode = NodeBlock(
        offset: Offset(10, 10),
        title: 'Original Title',
        type: 'Start',
        description: 'Original Description',
        welcomeMessage: 'Original Welcome',
      );

      final updatedNode = originalNode.copyWith(
        id: 'new-id',
        offset: Offset(100, 100),
        title: 'New Title',
        type: 'End',
        description: 'New Description',
        welcomeMessage: 'New Welcome',
        lessonType: 'Text',
        lessonContent: 'Text content',
        estimatedTime: '60',
        quizTitle: 'Final Quiz',
        passingScore: '90',
        timeLimit: '30',
        conditionExpression: 'y < 10',
        truePathLabel: 'Path A',
        falsePathLabel: 'Path B',
        checkpointTitle: 'Final Check',
        checkpointNote: 'Final note',
      );

      expect(updatedNode.id, 'new-id');
      expect(updatedNode.offset, Offset(100, 100));
      expect(updatedNode.title, 'New Title');
      expect(updatedNode.type, 'End');
      expect(updatedNode.description, 'New Description');
      expect(updatedNode.welcomeMessage, 'New Welcome');
      expect(updatedNode.lessonType, 'Text');
      expect(updatedNode.lessonContent, 'Text content');
      expect(updatedNode.estimatedTime, '60');
      expect(updatedNode.quizTitle, 'Final Quiz');
      expect(updatedNode.passingScore, '90');
      expect(updatedNode.timeLimit, '30');
      expect(updatedNode.conditionExpression, 'y < 10');
      expect(updatedNode.truePathLabel, 'Path A');
      expect(updatedNode.falsePathLabel, 'Path B');
      expect(updatedNode.checkpointTitle, 'Final Check');
      expect(updatedNode.checkpointNote, 'Final note');
    });

    // Test 6: copyWith method - setting optional fields to null
    test('copyWith can set optional fields to null', () {
      final originalNode = NodeBlock(
        offset: Offset(10, 10),
        title: 'Node with Desc',
        type: 'Lesson',
        description: 'Some description',
        lessonType: 'Text',
      );

      final updatedNode = originalNode.copyWith(
        description: null,
        lessonType: null,
      );

      expect(updatedNode.description, isNull);
      expect(updatedNode.lessonType, isNull);
      expect(updatedNode.title, 'Node with Desc'); // Retained
    });
  });
}
