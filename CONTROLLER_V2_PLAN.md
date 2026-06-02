# Character Controller V2 Plan

## Goals

- Keep Humanoid for grounding, slopes, stairs, replication and compatibility.
- Remove wallkick logic entirely from the controller foundation.
- Rebuild movement around clean locomotion responsibilities.
- Keep AnimationController and SlideController separate.

## BaseCharacterController Responsibilities

- Input
- Ground Detection
- Movement
- Jumping
- Sprinting
- Momentum

## Remove From V2

- Wall detection
- Wall normals
- Wallkick state
- Wallkick forces
- Traversal-specific logic

## Desired Flow

Input
-> Desired Move Direction
-> Ground State Update
-> Speed Simulation
-> Momentum Update
-> Humanoid Output

## Future Extensions

BaseSlideController
- Sliding
- Slide-specific momentum behavior

BaseAnimationController
- Animation playback
- Movement interpretation
- Visual responsiveness

## First Milestone

1. Clean controller skeleton.
2. Camera-relative movement.
3. Ground detection.
4. Coyote time.
5. Sprinting.
6. Proper acceleration and deceleration.
7. Humanoid-compatible movement output.

Wall interactions are intentionally postponed until the locomotion foundation is proven stable.
