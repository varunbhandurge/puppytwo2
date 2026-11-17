# TWO PUPPIES: THE GREAT ADVENTURE

[![Godot Engine](https://img.shields.io/badge/Engine-Godot%204.7.2%20Forward%2B-blue.svg)](https://godotengine.org)
[![Platform](https://img.shields.io/badge/Platform-Windows%20PC-0078D6.svg)](https://microsoft.com/windows)
[![Multiplayer](https://img.shields.io/badge/Multiplayer-2--Player%20Local%20Split--Screen-orange.svg)]()
[![QA Status](https://img.shields.io/badge/QA%20Tests-19%2F19%20PASS%20(100%25)-success.svg)]()

> *"Two Puppies. One Extraordinary Adventure. A Friendship that Makes the Impossible Possible."*

---

## 1. PROJECT OVERVIEW

**Two Puppies: The Great Adventure** is a commercial-grade, full-length cooperative 3D adventure game designed specifically for two-player local split-screen (with an architecture strictly prepared for future online co-op and console releases).

Two adorable puppy protagonists—**Bruno** (a brave, loyal, energetic Golden Retriever pup) and **Milo** (a clever, observant, agile Corgi pup)—embark on a heartwarming, monumental quest across eight chapters to reach the mythic **Aura Bone of Aethelgard**, learning along the way that their unbreakable bond is the ultimate treasure.

---

## 2. KEY FEATURES & DESIGN PILLARS

1. **Uncompromising Cooperative Interdependence:**
   - Bruno and Milo possess distinct, complementary abilities. There is no passive "Player 2".
   - **Bruno:** Mighty Dig, Heavy Push/Pull, Booming Bark (distraction & critter stun), Snout Boost platform.
   - **Milo:** Scent-o-Vision tracking, Low Crawl through tight gaps, Precision Leaps, Snout Mechanism Toggle.
2. **First-Class Split-Screen Viewport Architecture:**
   - Dynamic orientation switching: Side-by-Side (Vertical 50/50) or Top-and-Bottom (Horizontal 50/50) via hotkey **[T]**.
   - Dual 3D camera tracking with predictive velocity look-ahead and line-of-sight occlusion avoidance.
   - Dual 3D audio listener routing for spatial sound localization.
3. **Monumental Micro-Scale World:**
   - Ordinary suburban environments rendered from an 11-inch canine perspective.
   - A lawn sprinkler is a rotating water artillery cannon; flower pots are towering terra-cotta ziggurats; kitchen cabinets are sprawling multi-tier obstacle courses.
4. **Data-Driven Puzzle & Boss Framework:**
   - 32 cooperative puzzle concepts spanning 10 mechanical categories.
   - 8 multi-phase boss encounters requiring coordinated distraction, environmental manipulation, and timing.

---

## 3. PROJECT DIRECTORY STRUCTURE

```
puppytwo2/
├── Documentation/                 # Complete 16-document AAA studio specifications
│   ├── Research_Report.md         # Industry benchmarks & engine comparative matrix
│   ├── Game_Design_Document.md    # Pillars, character profiles, gameplay loops, 8 chapters
│   ├── Technical_Architecture.md  # 23 modular systems & decoupled topologies
│   ├── Character_Bible.md         # 3D specs, 25-animation matrix, canine behavior
│   ├── Story_and_Narrative.md     # Story beats, Aura Bone lore, canine dialogue
│   ├── World_Design.md            # Micro-scale perspective, lighting script, physics
│   ├── Chapter_Design.md          # Full 8-chapter level flow and pacing curves
│   ├── Puzzle_Design.md           # 30+ cooperative puzzles across 10 categories
│   ├── Boss_Design.md             # 8 unique cooperative bosses with multi-phase mechanics
│   ├── Multiplayer_Architecture.md# Phase 1 split-screen & Phase 2 online co-op readiness
│   ├── Asset_Pipeline.md          # 3D specs, PBR ORM maps, audio buses, asset register
│   ├── QA_Test_Plan.md            # Automated headless suite and master verification matrix
│   ├── Performance_Requirements.md# Frame budgets, RTX 3060 baseline profiling
│   ├── Production_Roadmap.md      # 16 sequenced milestones with acceptance criteria
│   ├── Known_Issues.md            # Defect register and technical debt watchlist
│   └── Development_Log.md         # Chronological studio operations and sprint log
├── src/
│   ├── camera/                    # SplitScreenManager & PuppyCamera
│   ├── characters/                # PuppyBase, Bruno, Milo, procedural quadruped rigs
│   ├── core/                      # EventBus, GameManager, SaveManager, AudioManager, InputManager
│   ├── enemies/                   # EnemyBase, GardenMole, BossGardenCat ("Whiskers")
│   ├── interactables/             # PressurePlate, DigMound, CrawlTunnel, ScentTrail, Checkpoint
│   ├── puzzles/                   # PuzzleBase, Puzzle1_SunkenCrate, Puzzle2_ScentMaze, Puzzle3_SprinklerBridge
│   ├── testbed/                   # PuppyCoopLab main vertical slice scene
│   └── ui/                        # HUDController, diegetic notifications, prompts
└── tests/                         # Automated headless test suite
    ├── test_character_movement.gd # Kinematics, collision, abilities, respawn
    ├── test_split_screen.gd       # Viewport world sharing, orientation, cameras
    ├── test_puzzles.gd            # Puzzle 1, 2, 3 progression and reset integrity
    ├── test_boss.gd               # Whiskers 3-phase AI and telegraphing
    ├── test_save_system.gd        # Atomic save serialization and checkpoint reload
    ├── test_runner.gd             # Master test runner script
    └── test_runner_scene.tscn     # Headless test runner scene
```

---

## 4. CONTROLS

| Action | Player 1: Bruno (Keyboard / Gamepad 0) | Player 2: Milo (Keyboard / Gamepad 1) |
| :--- | :--- | :--- |
| **Move** | W / A / S / D  (Left Stick) | Up / Down / Left / Right  (Left Stick) |
| **Jump** | Spacebar  (Button South - A / Cross) | Numpad 0  (Button South - A / Cross) |
| **Interact / Bite** | E  (Button West - X / Square) | Numpad 1  (Button West - X / Square) |
| **Bark / Vocalize** | Q  (Button North - Y / Triangle) | Numpad 2  (Button North - Y / Triangle) |
| **Special Ability** | F / Right Mouse  (Button East - B / Circle) | Numpad 3 / Right Mouse  (Button East - B / Circle) |
| **Sprint** | Left Shift (Hold) | Right Ctrl (Hold) |
| **Toggle Split-Screen** | **[T]** (Switches between Vertical and Horizontal Split-Screen) | **[T]** |
| **Pause Game** | Escape  (Start / Options) | Escape  (Start / Options) |

---

## 5. RUNNING THE GAME & TESTS

### Running the Puppy Co-op Lab Vertical Slice
```powershell
godot res://src/testbed/puppy_coop_lab.tscn
```

### Running the Headless Automated QA Test Suite
```powershell
godot --headless res://tests/test_runner_scene.tscn
```

### Current QA Suite Results:
- **Total Tests:** 19
- **Passed:** 19 (100% Pass Rate)
- **Failed:** 0
- **Engine Version:** Godot 4.7.2 Stable (Forward+ Vulkan / Godot Jolt Physics)
- **Baseline Hardware Verified:** AMD Ryzen 5 9600X, 32GB RAM, NVIDIA GeForce RTX 3060 12GB
