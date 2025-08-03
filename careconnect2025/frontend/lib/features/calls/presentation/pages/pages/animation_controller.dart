import 'package:flutter/material.dart';

class EmotionAnimationController {
  final AnimationController controller;
  late Animation<double> size;
  late Animation<Color?> color;

  EmotionAnimationController({
    required TickerProvider vsync,
    required Duration duration,
  }) : controller = AnimationController(vsync: vsync, duration: duration) {
    size = Tween<double>(begin: 180, end: 220).animate(controller);
    color = ColorTween(begin: Colors.blueAccent, end: Colors.orangeAccent)
        .animate(controller);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });

    controller.forward();
  }

  void trigger() {
    controller.forward(from: 0);
  }

  void dispose() {
    controller.dispose();
  }
}
