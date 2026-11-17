# TPGA-2026-001 — ASSET INVENTORY

**Project ID:** TPGA-2026-001  
**Project Name:** Puppy Adventure  
**Audit Date:** 2026-11-17  
**Inventory Scope:** Scenes, Shaders, Scripts, Audio, Documentation, and Packaging  

---

## 1. 3D Scenes (`.tscn`) — 17 Scenes Total

| Scene Path | Purpose / Domain | Status | Recommendation |
| :--- | :--- | :--- | :--- |
| `src/characters/bruno.tscn` | Bruno character model & collision | Functional (Primitives) | **Replace Visuals with Blender Rig** |
| `src/characters/milo.tscn` | Milo character model & collision | Functional (Primitives) | **Replace Visuals with Blender Rig** |
| `src/chapters/chapter_1_backyard/chapter_1_backyard.tscn` | Full Chapter 1 Level | Production-Ready | **Retain as Flagship Chapter** |
| `src/chapters/chapter_2_forgotten_garden/...tscn` | Chapter 2 Level Scene | Prototype | Retain for campaign progression |
| `src/chapters/chapter_3_giant_kitchen/...tscn` | Chapter 3 Level Scene | Prototype | Retain for campaign progression |
| `src/chapters/chapter_4_forest_of_giants/...tscn` | Chapter 4 Forest Scene | Prototype | **Upgrade to "The Whispering Forest"** |
| `src/chapters/chapter_5_riverlands/...tscn` | Chapter 5 River Scene | Prototype | Retain for campaign progression |
| `src/chapters/chapter_6_toy_factory/...tscn` | Chapter 6 Toy Factory | Prototype | Retain for campaign progression |
| `src/chapters/chapter_7_dark_underground/...tscn` | Chapter 7 Cavern Scene | Prototype | Retain for campaign progression |
| `src/chapters/chapter_8_mountain_of_bones/...tscn` | Chapter 8 Summit Scene | Prototype | Retain for campaign progression |
| `src/testbed/puppy_coop_lab.tscn` | Mechanics Testing Sandbox | Functional | **Retain as Testing Playground** |
| `src/ui/hud.tscn` | Split-Screen Co-op HUD | Production-Ready | **Retain** |
| `src/ui/pause_menu.tscn` | 5-Tab In-Game Pause Hub | Production-Ready | **Retain** |
| `src/ui/chapter_select_menu.tscn` | Campaign Chapter Selector | Production-Ready | **Retain** |
| `src/ui/objective_beacon.tscn` | 3D Waypoint World Beacon | Production-Ready | **Retain** |
| `src/interactables/golden_bone_pickup.tscn` | Collectible Golden Bone | Production-Ready | **Retain** |
| `tests/test_runner_scene.tscn` | Automated QA Harness Scene | Production-Ready | **Retain** |

---

## 2. Custom Shaders (`.gdshader`) — 7 Shaders Total

| Shader Path | Purpose | Status | Recommendation |
| :--- | :--- | :--- | :--- |
| `src/shaders/stylized_lawn_ground.gdshader` | Manicured mowing stripes & sod normal map | Production-Ready | **Retain & Adapt for Forest Floor** |
| `src/shaders/realistic_stylized_grass.gdshader` | 3-stop gradient, wind waves, puppy trample | Production-Ready | **Retain for Undergrowth Scatter** |
| `src/shaders/fur_rim_fluff.gdshader` | Clamped rim-fluff silhouette shader | Functional | **Upgrade with Blender fur textures** |
| `src/shaders/cartoon_eye.gdshader` | Procedural dilated iris & specular highlight | Functional | **Retain & attach to sculpted head** |
| `src/shaders/stylized_water.gdshader` | Dual-wave normal foam & depth absorption | Functional | **Enhance for Forest Stream Crossing** |
| `src/shaders/atmospheric_fog.gdshader` | Height-based distance fog blending | Functional | **Retain for Canopy Atmosphere** |
| `src/shaders/stylized_grass.gdshader` | Legacy vertex wind grass | Deprecated | Remove in favor of `realistic_stylized_grass` |

---

## 3. Core Architecture & Scripts (`.gd`) — 65 Scripts Total

- **Core Singletons:** `event_bus.gd`, `game_manager.gd`, `save_manager.gd`, `audio_manager.gd`, `input_manager.gd`, `chapter_progression.gd`, `performance_optimizer.gd`.
- **Character Controllers:** `puppy_base.gd`, `bruno.gd`, `milo.gd`.
- **Camera & UI:** `split_screen_manager.gd`, `puppy_camera.gd`, `hud.gd`, `pause_menu.gd`, `chapter_select_menu.gd`, `controller_glyphs.gd`, `objective_beacon.gd`.
- **Environment & Puzzles:** `lawn_grass_scatter.gd`, `puzzle_base.gd`, `puzzle_1_sunken_crate.gd`, `puzzle_2_scent_maze.gd`, `puzzle_3_sprinkler_bridge.gd`, `squeaky_ball_fetch.gd`, `dig_mound.gd`, `crawl_tunnel.gd`, `pressure_plate.gd`, `checkpoint.gd`.
- **Boss AI & Combat:** `enemy_base.gd`, `boss_mechanical_sprinkler.gd`, `boss_garden_cat.gd`, `boss_appliance_golem.gd`, `boss_corvus_crow.gd`, `boss_river_bullfrog.gd`, `boss_clockwork_titan.gd`, `boss_mole_king.gd`, `boss_mountain_guardian.gd`.
- **QA Suites:** 12 automated test suites in `tests/`.
