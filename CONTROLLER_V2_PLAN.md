# Character Controller V2 Plan

## Source Of Truth

- Base the rework on the recovered main-branch controller.
- Do not use the older wallkick prototype as the foundation.
- Preserve working shift-lock compatibility improvements.

## Goals

- Keep Humanoid for grounding, slopes, stairs, replication and compatibility.
- Keep the controller focused on locomotion.
- Remove traversal experiments from the foundation.
- Keep AnimationController and SlideController separate.
- Preserve compatibility with MovementLocked.

## BaseCharacterController Responsibilities

- Input
- Ground Detection
- Movement
- Sprinting
- Momentum

## Remove From V2

- Wall detection
- Wall normals
- Wallkick state
- Wallkick forces
- Traversal-specific logic
- HeadLock system
- CameraSubject switching
- Unused controller baggage

## Keep From Main Branch

- Camera-relative movement
- MovementLocked support
- Sprint FOV feedback
- Direction smoothing
- Death safeguards
- Humanoid AutoRotate shift-lock compatibility

## Desired Flow

Input
-> Desired Move Direction
-> Ground State Update
-> Speed Simulation
-> Momentum Update
-> Humanoid Output

## Shift-Lock Plan

- Sprint remains on Shift.
- Shift-lock should be moved to LeftCtrl and RightCtrl.
- Shift-lock handling should remain separate from locomotion logic whenever possible.

## Future Extensions

BaseSlideController
- Sliding
- Slide-specific momentum behavior

BaseAnimationController
- Animation playback
- Movement interpretation
- Visual responsiveness

## Priority Order

1. Real acceleration and deceleration.
2. Remove HeadLock system.
3. Shift-lock remapping support.
4. Remove custom jump handling.
5. Cleanup unused variables.
6. Humanoid-compatible movement output.

Wall interactions are intentionally excluded from the V2 foundation.