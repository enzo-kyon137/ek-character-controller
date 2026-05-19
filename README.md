# EK-Locomotion-Controller

A momentum-focused Roblox character controller framework built for:
- platforming
- obbies
- movement systems
- traversal gameplay
- stylized locomotion

This project focuses on:
- momentum movement
- smooth acceleration
- wallkicks (optional)
- sliding (optional)
- directional locomotion
- animation stability
- Humanoid-compatible architecture

Instead of replacing Roblox Humanoids entirely, the framework cooperates with them while overriding movement behavior and movement feel.

---

# Philosophy

The controller follows a hybrid approach:

- Humanoid handles:
  - grounding
  - stairs
  - slopes
  - replication
  - compatibility
  - base character behavior

- Controller handles:
  - acceleration
  - momentum
  - movement direction
  - sliding
  - traversal logic
  - movement feel

- Animator handles:
  - locomotion animations
  - strafing
  - playback smoothing
  - movement interpretation
  - visual responsiveness

This separation prevents physics and animation systems from fighting each other.

---

# Project Structure

```text
src/
├── BaseCharacterController.lua
├── EK_Animate.lua
└── Shared/