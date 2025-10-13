# Bee & Flower Simulation — Godot Project
## 🐝 Overview

This Godot 4 project simulates the natural process of pollination through autonomous interactions between bees, flowers, and a hive.
Each bee is controlled by a simple physics-based script, but together they exhibit emergent collective behavior — flying between flowers, avoiding collisions, collecting pollen, and returning to the hive.

The project demonstrates how local rules and minimal AI can create lifelike and dynamic environmental behavior.

# Core Concepts
## 🐝 Bees (RigidBody3D)

Each bee starts at the hive and searches for a target flower.

Bees move using their linear_velocity toward their target.

When two bees collide, they slightly change their position to avoid overlapping and then choose a new target.

Bees collect pollen (“butin”) from flowers and return to the hive after two successful visits.

If a bee fails to find a flower for too long, it dies (simulating limited energy and survival dependency on flowers).

## 🌼 Flowers (StaticBody3D)

Flowers are grouped under "fleurs" and can be detected by bees through collisions.

When a bee lands on a flower:

Some pistils change color from yellow to green, symbolizing pollination.

After a few visits, petals fall and the flower becomes wilted.

Wilted flowers are automatically replaced by new flowers, maintaining ecological balance.

## 🍯 Hive (Node3D)

Acts as the home base for bees.

Bees return here after collecting pollen to “rest” for a few seconds before flying out again.

This cyclical process of collecting, returning, and resting simulates natural foraging behavior.
