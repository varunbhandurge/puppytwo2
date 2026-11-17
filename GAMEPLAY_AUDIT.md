# TPGA-2026-001 — GAMEPLAY AUDIT

**Project ID:** TPGA-2026-001  
**Project Name:** Puppy Adventure  
**Audit Scope:** Kinematics, Split-Screen Camera, Asymmetric Co-op, and Level Puzzles  
**Reference Benchmark:** *It Takes Two* (Hazelight)  

---

## 1. Kinematics & Locomotion

### Current Mechanics
- **Base Controller:** `puppy_base.gd` CharacterBody3D architecture with separate ground friction, sprint multiplier (1.45x), variable-height jump impulse, and terminal gravity.
- **Bruno Specifics:** Heavy mass modifier, pushing force, deep trench excavation (`dig()`), defensive vocal bark with physics deflection cone.
- **Milo Specifics:** Agile locomotion, low crawl collision compression (`capsule_height = 0.25m`), Scent-o-Vision tracking trail toggle (`scent_vision_toggled`), and snout-boost launch receiver.

### Gameplay Evaluation
- **Strengths:** Highly responsive, zero physics jitter, clean acceleration curves, verified by automated unit tests `TC-CHR-001` through `TC-CHR-006`.
- **Deficiencies:**
  - Lacks root-motion or procedural foot IK for uneven forest terrain.
  - Jumping lacks anticipatory squash-and-stretch anticipation on crouch and landing.
  - Wall sliding or ledge-mantle grab for small pups is currently missing.

---

## 2. Dynamic Split-Screen & Camera

### Current Mechanics
- `split_screen_manager.gd` manages two `SubViewport` nodes sharing one `World3D`.
- Dynamic orientation switching: Shifts between vertical split (side-by-side) and horizontal split based on viewport aspect ratio.
- Predictive camera offset: Smoothly looks ahead in the direction of puppy velocity.

### Gameplay Evaluation
- **Strengths:** Rock solid, tested via `TC-CAM-001` through `TC-CAM-003`.
- **Deficiencies:**
  - Viewports remain split even when puppies stand next to each other.
  - In *It Takes Two*, cameras converge seamlessly into a single cinematic viewport when players are within close proximity (< 4 meters) and diverge into split-screen when they separate.

---

## 3. Cooperative Mechanics & Puzzles

### Current Mechanics
- State machine framework (`puzzle_base.gd`) with 3 implemented puzzles in Vertical Slice Lab and Chapter 1 (Sunken Crate, Bramble Scent Maze, Sprinkler Bridge).
- High interdependence: puzzles cannot be solved by a single character.

### Deficiencies for *The Whispering Forest*
- Need dedicated nature-themed physical cooperative interactions:
  1. **Stream Crossing:** Bruno pushes a waterlogged fallen log into the rapids; Milo crawls across and trips a vine release mechanism.
  2. **See-Saw Log Balance:** Both puppies must balance on a mossy log fulcrum to reach an elevated cliff ledge.
  3. **Burrow & Scent Trail:** Milo crawls through a root tunnel under ancient briars to unlatch a canopy vine bridge for Bruno.
