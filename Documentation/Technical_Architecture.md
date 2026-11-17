# TECHNICAL ARCHITECTURE SPECIFICATION
# TWO PUPPIES: THE GREAT ADVENTURE

**Engine:** Godot Engine 4.7.2 Stable (Forward+ Vulkan Renderer / Godot Jolt Physics)  
**Programming Language:** GDScript 2.0 (Static Typing Enforced)  
**Target Hardware Baseline:** Windows PC (AMD Ryzen 5 9600X, 32GB RAM, NVIDIA RTX 3060 12GB)  
**Document Version:** 1.0.0  

---

## 1. ARCHITECTURAL PHILOSOPHY

The technical architecture is built on five core design principles:
1. **Strict Modular Decoupling:** Systems communicate exclusively through an Event Bus (`EventBus.gd`) or well-defined interface contracts. Monolithic manager scripts are strictly prohibited.
2. **Data-Driven Configuration:** All puppy stats, puzzle states, audio triggers, and chapter configurations are stored in Godot `Resource` (`.tres`) files rather than hard-coded script logic.
3. **Dual-Viewport First-Class Design:** Input handling, audio listeners, and camera tracking are architected around independent viewports from day one.
4. **Online Co-op Readiness (Zero Rewrite Migration):** Gameplay simulation logic is cleanly separated from local player input controllers, enabling seamless redirection to network packets via Godot's `MultiplayerSynchronizer` in future milestones.
5. **Deterministic Performance:** Zero runtime memory allocations during core gameplay loops, automated asset pooling, and lightweight node hierarchies to sustain 120+ FPS at 1440p on the baseline RTX 3060 workstation.

---

## 2. HIGH-LEVEL SYSTEM TOPOLOGY

```
                      +-------------------+
                      |   GameManager     |
                      +---------+---------+
                                |
             +------------------+------------------+
             |                                     |
    +--------v--------+                   +--------v--------+
    |    EventBus     |                   |   SaveManager   |
    +--------+--------+                   +-----------------+
             |
 +-----------+-----------+--------------------+--------------------+
 |                       |                    |                    |
+v--------------+  +-----v---------+    +-----v---------+    +-----v---------+
| SplitScreen   |  | Interaction   |    | PuzzleFramework|   | Enemy & Boss  |
| Manager       |  | Framework     |    | (Data-Driven) |    | Framework     |
+---------------+  +---------------+    +---------------+    +---------------+
 |               |         |                    |                    |
+v---------+ +---v------+  |                    |                    |
| Viewport1| |Viewport2 |  |                    |                    |
| (Bruno)  | | (Milo)   |  |                    |                    |
+----+-----+ +----+-----+  |                    |                    |
     |            |        |                    |                    |
+----v-----+ +----v-----+  |                    |                    |
| PuppyCam1| | PuppyCam2|  |                    |                    |
+----------+ +----------+  |                    |                    |
     |            |        |                    |                    |
+----v-----+ +----v-----+  |                    |                    |
| Player 1 | | Player 2 |  |                    |                    |
| (Bruno)  | | (Milo)   |  |                    |                    |
+----------+ +----------+  |                    |                    |
```

---

## 3. THE 23 MODULAR SYSTEMS

### System 1: Game Manager (`GameManager.gd`)
- Root orchestrator singleton (`Autoload`).
- Coordinates application lifecycle: Boot → Splash → Main Menu → Chapter Load → Gameplay Loop → Pause → Game Over → Victory.
- Tracks active play state, game time, debug flags, and system performance metrics.

### System 2: Player Controller (`PuppyPlayerController.gd`)
- Receives raw hardware inputs from the Input Manager and converts them into standardized `PuppyCommand` structures:
  `{ move_vec: Vector2, jump_pressed: bool, interact_held: bool, special_pressed: bool, bark_pressed: bool }`.
- Decoupled from character kinematics, enabling AI bots or network streams to drive characters without code alteration.

### System 3: Puppy Character Framework (`PuppyBase.gd`)
- Inherits from `CharacterBody3D`.
- Implements quadruped physics: velocity damping, slope sliding, paw-ground raycasting, turn rate smoothing, acceleration curves.
- Holds references to ability components, health/stamina state, and the visual model.

### System 4: Ability Components (`PuppyAbilityComponent.gd`)
- Pluggable nodes attached to the puppy:
  - `DigComponent.gd`: Raycasts for excavatable soil layers, handles particle FX and excavated item spawns.
  - `PushPullComponent.gd`: Handles rigid body grasping, directional torque limits, and joint physics.
  - `ScentComponent.gd`: Renders olfactory particle trails and reveals hidden invisible triggers within proximity.
  - `CrawlComponent.gd`: Scales collision capsule to 40% height, adjusts camera distance, and enforces crawl-tunnel navigation.
  - `BarkComponent.gd`: Emits 3D acoustic spherical trigger query, stunning small critters and alarming enemies.

### System 5: Camera Manager (`PuppyCamera.gd`)
- Third-person spring-arm orbital camera for each puppy.
- Predictive framing based on movement velocity and terrain geometry.
- Occlusion avoidance: Smoothly moves closer to the puppy if opaque geometry blocks the line of sight.

### System 6: Split-Screen Manager (`SplitScreenManager.gd`)
- Hosts two `SubViewportContainer` nodes and two `SubViewport` nodes.
- Exposes runtime orientation switching: `Orientation.VERTICAL` (Side-by-side 50/50), `Orientation.HORIZONTAL` (Top/Bottom 50/50), and `Orientation.AUTO_MERGE`.
- Handles divider bar styling, screen-shake isolation, and camera zoom during cooperative fusion moments.

### System 7: Input Manager (`InputManager.gd`)
- Handles multi-device binding: Gamepad 0, Gamepad 1, Keyboard Left, Keyboard Right.
- Device hot-plugging detection and seamless reassignment.
- Deadzone filtering, analog stick curve calibration, and accessibility button-remapping storage.

### System 8: Interaction Framework (`InteractableArea3D.gd`)
- Trigger-based contextual prompt system.
- Dispatches interactions (`on_interact_started`, `on_interact_held`, `on_interact_released`).
- Supported categories: Levers, Pressure Plates, Ropes, Scent Clues, Dig Sites, Pushable Crates, Latch Gates.

### System 9: Physics Framework (`PhysicsConfig.gd`)
- Integrated with Godot Jolt 3D Physics.
- Configured collision layers and masks:
  - Layer 1: World Static (Terrain, Buildings, Obstacles)
  - Layer 2: Puppy 1 (Bruno)
  - Layer 3: Puppy 2 (Milo)
  - Layer 4: Interactable Objects (Push blocks, Levers, Bones)
  - Layer 5: Enemies & Hazards (Moles, Cats, Sprinklers)
  - Layer 6: Scent & Sensory Triggers (Invisible to physics, queried by sensors)
  - Layer 7: Water & Fluids (Buoyancy zones)

### System 10: Puzzle Framework (`PuzzleBase.gd`)
- State-machine driven puzzle architecture.
- Puzzles maintain states: `LOCKED`, `IN_PROGRESS`, `SOLVED`, `FAILED_RESETTING`.
- Emits signals on `EventBus`: `puzzle_started`, `stage_completed(stage_idx)`, `puzzle_solved`, `puzzle_reset`.
- Guarantees failure recovery and checkpoint rollback without soft-locking.

### System 11: Enemy AI Framework (`EnemyBase.gd`)
- Hierarchical Finite State Machine (HFSM):
  `IDLE` → `PATROL` → `SUSPICIOUS` (investigating bark or scent) → `ALERT` → `CHASE` → `ATTACK` → `STUNNED` → `RESET`.
- Multi-target arbitration: Evaluates threat and distance to both Bruno and Milo independently.

### System 12: Boss Framework (`BossBase.gd`)
- Multi-phase boss architecture with dedicated cinematic transitions.
- Enforces simultaneous cooperative requirements: Player 1 distraction/positioning + Player 2 environmental activation.
- Telegraphed attack indicators using ground decals and audio cues.

### System 13: Level Manager (`LevelManager.gd`)
- Handles streaming, level loading, scene transitions, and background asset preloading.
- Employs asynchronous resource loading (`ResourceLoader.load_threaded_request`) to eliminate stutter.

### System 14: Chapter Progression (`ChapterProgression.gd`)
- Manages unlocked chapters, story beat flags, collected golden bones, and chapter statistics.

### System 15: Checkpoint System (`CheckpointManager.gd`)
- Spatially placed `Checkpoint3D` triggers save the latest safe position of both puppies.
- Respawn logic: If either puppy falls into water or gets caught, both puppies safely respawn at the active checkpoint in under 1 second.

### System 16: Save/Load System (`SaveManager.gd`)
- Encrypted JSON / binary save serialization to `user://saves/savegame.dat`.
- Implements atomic write safety: Writes to a temporary file (`savegame.dat.tmp`) before renaming to prevent data corruption during power interruption.
- Supports 3 independent save slots.

### System 17: Dialogue System (`DialogueManager.gd`)
- Lightweight dialogue runner supporting character portraits, colored subtitles, and localized text.
- Supports bark-and-whine procedural canine vocalization hooks.

### System 18: Cutscene System (`CutsceneController.gd`)
- Coordinates in-engine cinematic sequences using Godot's `AnimationPlayer` and `Camera3D`.
- Automatically transitions viewports from split-screen to full-screen cinematic framing and restores split-screen upon completion.

### System 19: Animation Manager (`PuppyAnimationManager.gd`)
- Blends animation trees (`AnimationTree` with `BlendSpace2D` and `StateMachine`).
- Handles quadruped gait blending (Walk, Trot, Run) driven by ground speed.
- IK ground alignment: Adjusts front and rear paw bones to terrain slopes via raycasts.

### System 20: Audio Manager (`AudioManager.gd`)
- Multi-bus audio mixing: `Master`, `BGM`, `SFX_P1`, `SFX_P2`, `Ambience`, `UI`.
- Dual 3D audio listener support: SubViewport 1 listens to Camera 1; SubViewport 2 listens to Camera 2.
- Interactive music layering: Adaptive percussion and string intensity based on danger and puzzle tension.

### System 21: UI Manager (`UIManager.gd`)
- Manages HUD overlays, main menu, pause menu, controller pairing screens, settings dialogs, and subtitle rendering.
- UI elements auto-scale to resolution (1080p, 1440p, 4K) using anchor layout containers.

### System 22: Achievement System (`AchievementManager.gd`)
- Tracks player accomplishments (e.g., "First Scent", "High Roller", "Unbreakable Bond", "Whiskers Tamed").
- Emits joyful in-game popup toast notifications.

### System 23: Accessibility System (`AccessibilityManager.gd`)
- High-contrast visual modes, subtitle background tinting, camera auto-leveling, toggle-instead-of-hold interactions, colorblind correction shaders, and reconfigurable input bindings.

---

## 4. MULTIPLAYER DECOUPLING & ONLINE CO-OP ROADMAP
- Input generation is strictly isolated into `PuppyCommand` structs.
- Game state changes are strictly driven through `EventBus` signals.
- In Milestone 16, a `NetworkPuppyController` will swap in place of `PuppyPlayerController` on remote clients, utilizing Godot's built-in `MultiplayerSynchronizer` to replicate position, state, and animation frames with zero changes to gameplay or puzzle logic.
