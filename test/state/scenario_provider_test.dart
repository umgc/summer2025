// This file contains unit tests for the ScenarioController (StateNotifier).
//
// These tests verify the core functionality of the scenario management, including:
// - Adding new nodes.
// - Moving existing nodes to new positions.
// - Updating properties of existing nodes.
// - The undo/redo mechanism for state changes.
// - Clearing all nodes and history.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart'; // Required for Offset
import 'package:deeptrainfront/shared/models/node_block.dart'; // Import your NodeBlock model
import 'package:deeptrainfront/state/scenario_provider.dart'; // Import your ScenarioController

void main() {
  group('ScenarioController Unit Tests', () {
    late ProviderContainer
    container; // A container to hold and manage providers

    // Setup: Initialize the ProviderContainer before each test
    setUp(() {
      container = ProviderContainer();
      // Ensure the scenarioProvider is initialized with an empty state
      addTearDown(container.dispose); // Dispose the container after each test
    });

    // Helper function to create a basic NodeBlock
    NodeBlock createTestNode({
      String? id,
      Offset? offset,
      String title = 'Test Node',
      String type = 'Lesson',
    }) {
      return NodeBlock(
        id: id,
        offset: offset ?? Offset.zero,
        title: title,
        type: type,
      );
    }

    // Test 1: Initial state is empty
    test('initial state is an empty list', () {
      expect(container.read(scenarioProvider), isEmpty);
    });

    // Test 2: addNode correctly adds a new node
    test('addNode adds a new node to the state', () {
      final controller = container.read(scenarioProvider.notifier);
      final node1 = createTestNode(id: 'node1');

      controller.addNode(node1);
      expect(container.read(scenarioProvider).length, 1);
      expect(container.read(scenarioProvider).first, node1);

      final node2 = createTestNode(id: 'node2');
      controller.addNode(node2);
      expect(container.read(scenarioProvider).length, 2);
      expect(
        container.read(scenarioProvider),
        containsAllInOrder([node1, node2]),
      );
    });

    // Test 3: moveNode correctly updates a node's offset
    test('moveNode updates a node\'s offset', () {
      final controller = container.read(scenarioProvider.notifier);
      final node1 = createTestNode(id: 'node1', offset: Offset(0, 0));
      controller.addNode(node1);

      final newOffset = Offset(100, 150);
      controller.moveNode(node1, newOffset);

      expect(container.read(scenarioProvider).length, 1);
      expect(container.read(scenarioProvider).first.id, 'node1');
      expect(container.read(scenarioProvider).first.offset, newOffset);
    });

    // Test 4: updateNode correctly updates a node's properties
    test('updateNode updates a node\'s properties', () {
      final controller = container.read(scenarioProvider.notifier);
      final node1 = createTestNode(id: 'node1', title: 'Old Title');
      controller.addNode(node1);

      final updatedNode = node1.copyWith(
        title: 'New Title',
        description: 'Updated Desc',
      );
      controller.updateNode(updatedNode);

      expect(container.read(scenarioProvider).length, 1);
      expect(container.read(scenarioProvider).first.id, 'node1');
      expect(container.read(scenarioProvider).first.title, 'New Title');
      expect(
        container.read(scenarioProvider).first.description,
        'Updated Desc',
      );
    });

    // Test 5: undo functionality
    test('undo reverts to the previous state', () {
      final controller = container.read(scenarioProvider.notifier);
      final node1 = createTestNode(id: 'node1');
      final node2 = createTestNode(id: 'node2');

      controller.addNode(node1); // State: [node1]
      expect(container.read(scenarioProvider), [node1]);

      controller.addNode(node2); // State: [node1, node2]
      expect(container.read(scenarioProvider), [node1, node2]);

      controller.undo(); // State: [node1]
      expect(container.read(scenarioProvider), [node1]);

      controller.undo(); // State: [] (initial state before node1 was added)
      expect(container.read(scenarioProvider), isEmpty);
    });

    // Test 6: redo functionality
    test('redo reapplies the last undone state', () {
      final controller = container.read(scenarioProvider.notifier);
      final node1 = createTestNode(id: 'node1');
      final node2 = createTestNode(id: 'node2');

      controller.addNode(node1); // State: [node1]
      controller.addNode(node2); // State: [node1, node2]

      controller.undo(); // State: [node1]
      expect(container.read(scenarioProvider), [node1]);

      controller.redo(); // State: [node1, node2]
      expect(container.read(scenarioProvider), [node1, node2]);

      controller.undo(); // State: [node1]
      controller.undo(); // State: []

      controller.redo(); // State: [node1]
      expect(container.read(scenarioProvider), [node1]);
    });

    // Test 7: undo/redo stack management (redoStack cleared on new action)
    test('redo stack is cleared on a new action after undo', () {
      final controller = container.read(scenarioProvider.notifier);
      final node1 = createTestNode(id: 'node1');
      final node2 = createTestNode(id: 'node2');
      final node3 = createTestNode(id: 'node3');

      controller.addNode(node1); // State: [node1]
      controller.addNode(node2); // State: [node1, node2]

      controller.undo(); // State: [node1] (redoStack has [node1, node2])
      expect(container.read(scenarioProvider), [node1]);

      controller.addNode(node3); // State: [node1, node3] (new action)
      expect(container.read(scenarioProvider), [node1, node3]);

      // Now, redo should not work because _redoStack was cleared by addNode(node3)
      controller.redo();
      expect(container.read(scenarioProvider), [
        node1,
        node3,
      ]); // Should remain [node1, node3]
    });

    // Test 8: clear method resets state and stacks
    test('clear method resets state and undo/redo stacks', () {
      final controller = container.read(scenarioProvider.notifier);
      final node1 = createTestNode(id: 'node1');
      controller.addNode(node1);
      controller.addNode(createTestNode(id: 'node2'));
      controller.undo(); // Populate undo/redo stacks

      expect(
        container.read(scenarioProvider),
        isNotEmpty,
      ); // State should not be empty
      // Internally, _undoStack and _redoStack should have content

      controller.clear();

      expect(
        container.read(scenarioProvider),
        isEmpty,
      ); // State should be empty
      // NICOLE EDITS: Use a private accessor for testing if needed, or rely on public behavior
      // For _undoStack and _redoStack, we can infer they are empty if undo/redo don't work.
      controller.undo(); // Should do nothing
      expect(container.read(scenarioProvider), isEmpty);
      controller.redo(); // Should do nothing
      expect(container.read(scenarioProvider), isEmpty);
    });

    // Test 9: _saveForUndo creates a deep copy of the state
    test('_saveForUndo creates a deep copy of the state', () {
      final controller = container.read(scenarioProvider.notifier);
      final node1 = createTestNode(id: 'node1', title: 'Original');
      controller.addNode(node1); // State: [node1]

      // Manually trigger a save (normally done by addNode, etc.)
      // For testing private methods, you might need to make them public temporarily
      // or test them indirectly through public methods that call them.
      // Here, addNode calls _saveForUndo, so we can verify via undo.
      final node2 = createTestNode(id: 'node2', title: 'Second');
      controller.addNode(node2); // State: [node1, node2]

      // Modify node1 in the current state *without* saving
      final currentState = container.read(scenarioProvider);
      final modifiedNode1 = currentState[0].copyWith(title: 'Modified');
      currentState[0] =
          modifiedNode1; // Directly modify the list reference (BAD PRACTICE IN REAL CODE, GOOD FOR TESTING COPY)

      // Now, undo should revert to the state *before* the direct modification,
      // proving that _saveForUndo made a deep copy.
      controller.undo();
      expect(container.read(scenarioProvider).length, 1);
      expect(container.read(scenarioProvider).first.id, 'node1');
      expect(
        container.read(scenarioProvider).first.title,
        'Original',
      ); // Should be 'Original', not 'Modified'
    });
  });
}
