
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_app/models/match_analysis.dart';
import 'package:vector_math/vector_math_64.dart';

class Metaball {
  Vector2 position;
  Vector2 velocity;
  final double radius;
  final MatchAnalysis analysis;
  double scale = 1.0;
  bool isBeingDragged = false;

  Metaball(this.analysis, {required this.radius}) 
      : position = Vector2.zero(), 
        velocity = Vector2.zero();
}

class MetaballSimulation {
  final List<Metaball> metaballs;
  Size size;
  final double gravity;
  final double damping;

  MetaballSimulation({required this.metaballs, required this.size, this.gravity = 0.1, this.damping = 0.98});

  void update() {
    for (var ball in metaballs) {
      // If a ball is being dragged by the user, don't apply simulation physics to it.
      if (ball.isBeingDragged) continue;

      // Apply gravity towards the center
      final toCenter = Vector2(size.width / 2, size.height / 2) - ball.position;
      ball.velocity += toCenter.normalized() * gravity;

      // Update position
      ball.position += ball.velocity;

      // Dampen velocity
      ball.velocity *= damping;

      // Wall collision
      if (ball.position.x < ball.radius) {
        ball.position.x = ball.radius;
        ball.velocity.x = -ball.velocity.x;
      }
      if (ball.position.x > size.width - ball.radius) {
        ball.position.x = size.width - ball.radius;
        ball.velocity.x = -ball.velocity.x;
      }
      if (ball.position.y < ball.radius) {
        ball.position.y = ball.radius;
        ball.velocity.y = -ball.velocity.y;
      }
      if (ball.position.y > size.height - ball.radius) {
        ball.position.y = size.height - ball.radius;
        ball.velocity.y = -ball.velocity.y;
      }
    }

    // Ball collision
    for (int i = 0; i < metaballs.length; i++) {
      for (int j = i + 1; j < metaballs.length; j++) {
        final ballA = metaballs[i];
        final ballB = metaballs[j];
        final distance = ballA.position.distanceTo(ballB.position);
        final minDistance = ballA.radius + ballB.radius;

        if (distance < minDistance) {
          final normal = (ballA.position - ballB.position).normalized();
          final overlap = minDistance - distance;
          
          ballA.position += normal * (overlap / 2);
          ballB.position -= normal * (overlap / 2);

          // Elastic collision response
          final relativeVelocity = ballA.velocity - ballB.velocity;
          final velocityAlongNormal = relativeVelocity.dot(normal);

          if (velocityAlongNormal > 0) continue;

          final restitution = 0.8; // Bounciness
          var impulse = -(1 + restitution) * velocityAlongNormal;
          impulse /= 1/ballA.radius + 1/ballB.radius; // Simplified mass

          final impulseVector = normal * impulse;
          ballA.velocity += impulseVector / ballA.radius;
          ballB.velocity -= impulseVector / ballB.radius;
        }
      }
    }
  }
}
