# Character Controller Development Plan

Originally written during the internal "V2" rewrite phase of the project.

The "V2" name refers to a development codename used while rebuilding the controller and does not correspond to a public release version.

---

# Enzo Kyon's Character Controller

## Purpose

Enzo Kyon's Character Controller is a Humanoid-based locomotion controller designed to be simple, readable, configurable, and plug-and-play.

The controller focuses exclusively on locomotion and intentionally avoids becoming an all-in-one character framework.

Its primary goals are:

- Compatibility
- Simplicity
- Readability
- Extensibility
- Cross-platform support

The controller should work with keyboard, mobile, and gamepad without requiring separate movement implementations.

---

## Source Of Truth

- Development is based on the `rework/controller-v2` branch.
- V2 is the primary implementation of the controller.
- Earlier controller experiments should not be used as a foundation for future development.
- Preserve tested functionality whenever possible.

---

## Design Goals

- Keep Humanoid for grounding, slopes, stairs, seats, replication, and compatibility.
- Keep locomotion self-contained.
- Remain compatible with Roblox Animate and custom animation systems.
- Support keyboard, mobile, and gamepad.
- Minimize required networking for basic usage.
- Prioritize readability and maintainability.
- Preserve plug-and-play behavior.

---

## Architecture

### CharacterController.lua (Client)

Responsible for:

- Input handling
- Ground state updates
- Movement simulation
- Sprinting
- Momentum
- Braking
- Jumping
- AutoJump
- Camera FOV feedback
- Shift-lock compatibility
- Reading Humanoid attributes

### AttributeCreator.lua (Server)

Responsible for:

- Creating Humanoid movement attributes
- Providing server-side integration points
- Initializing default movement values

Default attributes:

```lua
CanMove = true
MoveMultiplier = 1
```

---

## Supported Features

- Sprinting
- Configurable keybinds
- Keyboard support
- Mobile support
- Gamepad support
- AutoJump
- Coyote time
- JumpPower support
- JumpHeight support
- Sprint FOV adaptation
- Movement braking
- Movement presets
- Shift-lock remapping
- Roblox Animate compatibility

---

## Movement Presets

The included presets are examples and starting points.

Developers are encouraged to modify existing presets or create entirely new presets that better fit their own experiences.

Movement feel is subjective and there is no single "correct" configuration.

### Vanilla

Goal:

- Similar to default Roblox movement
- Smooth turning
- Instant acceleration

Recommended for:

- General Roblox experiences

### Enhanced

Goal:

- Momentum-focused movement
- Slower acceleration
- Smoother transitions

Recommended for:

- Platformers
- Adventure games

### Precise

Goal:

- Instant acceleration
- Instant turning
- No friction

Recommended for:

- Obbies
- Classic-style experiences
- Competitive movement

Notes:

- Currently the most tested preset.
- Serves as the primary reference implementation.
- Considered the most reliable preset included with the controller.

Vanilla and Enhanced should be considered reference examples rather than finalized movement styles.

---

## Server Integration

Movement can be controlled through Humanoid attributes.

Freeze movement:

```lua
humanoid:SetAttribute(
	"CanMove",
	false
)
```

Restore movement:

```lua
humanoid:SetAttribute(
	"CanMove",
	true
)
```

Speed boost:

```lua
humanoid:SetAttribute(
	"MoveMultiplier",
	1.5
)
```

Slowdown:

```lua
humanoid:SetAttribute(
	"MoveMultiplier",
	0.5
)
```

The controller automatically reacts to attribute changes.

---

## Intentionally Excluded

This controller focuses exclusively on locomotion.

The following systems are intentionally excluded from the foundation:

- Wallrunning
- Wallkicks
- Wall climbing
- Traversal abilities
- Sliding
- HeadLock
- CameraSubject switching
- Animation playback
- Combat systems

These systems should be implemented separately when needed.

---

## AI / Agent Notes

AI-assisted development is allowed and encouraged.

Tools such as ChatGPT, Gemini, Claude, Copilot, Codex, and similar assistants may be used to help:

- Understand code
- Review code
- Debug issues
- Write documentation
- Refactor systems
- Extend functionality

However:

- Review AI suggestions before accepting them.
- Test significant changes.
- Do not blindly trust rewrites.
- Preserve working functionality whenever possible.
- Understand a change before merging it.
- Prefer focused modifications over unnecessary rewrites.
- Respect the current architecture.
- Avoid introducing major systems unrelated to locomotion.

This controller was developed with AI-assisted collaboration.

AI output should be treated as suggestions rather than unquestionable truth.

---

## Open Source Philosophy

This project is intended to be modified, studied, extended, forked, and adapted.

Developers are encouraged to:

- Learn from the implementation
- Customize movement behavior
- Create new presets
- Modify existing systems
- Build their own derivatives
- Fork the project

Different games have different movement requirements.

Customization is expected and encouraged.