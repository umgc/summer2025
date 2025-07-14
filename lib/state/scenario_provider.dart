import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../shared/models/node_block.dart';

final scenarioProvider =
    StateNotifierProvider<ScenarioController, List<NodeBlock>>((ref) {
  return ScenarioController();
});

class ScenarioController extends StateNotifier<List<NodeBlock>> {
  ScenarioController() : super([]);

  final List<List<NodeBlock>> _undoStack = [];
  final List<List<NodeBlock>> _redoStack = [];

  /// Adds a new node to the scenario
  void addNode(NodeBlock block) {
    _saveForUndo();
    state = [...state, block];
  }

  void removeNode(String nodeId) {
    state = state.where((node) => node.id != nodeId).toList();
  }

void replace(List<NodeBlock> newState) {
  state = newState;
  _undoStack.clear();
  _redoStack.clear();
}



  /// Moves a node to a new position
  void moveNode(NodeBlock block, Offset newOffset) {
    _saveForUndo();
    final updatedBlock = block.copyWith(offset: newOffset);
    state = [
      for (final b in state)
        if (b.id == updatedBlock.id) updatedBlock else b
    ];
  }

  /// Updates a node's properties
  void updateNode(NodeBlock updated) {
    _saveForUndo();
    state = [
      for (final block in state)
        if (block.id == updated.id) updated else block
    ];
  }

  /// Undo the last change
  void undo() {
    if (_undoStack.isNotEmpty) {
      _redoStack.add(state);
      state = _undoStack.removeLast();
    }
  }

  /// Redo the last undone change
  void redo() {
    if (_redoStack.isNotEmpty) {
      _undoStack.add(state);
      state = _redoStack.removeLast();
    }
  }

  /// Save the current state for undo
  void _saveForUndo() {
    _undoStack.add(state.map((e) => e.copyWith()).toList());
    _redoStack.clear();
  }

  /// Optional: clear all
  void clear() {
    state = [];
    _undoStack.clear();
    _redoStack.clear();
  }
}
