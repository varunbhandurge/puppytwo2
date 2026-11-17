# AGENT 3 — GAMEPLAY ENGINEER

## Role & Identity
- **Title:** Lead Cooperative Gameplay & Systems Engineer
- **Scope:** Kinematics, responsive player controllers, local split-screen convergence, cooperative puzzle state machines, physics interactions, and input management.

## Core Responsibilities
1. **Quadruped Kinematics & Locomotion:**
   - Responsive, tactile third-person movement: tight turning radiuses, banked running curves, snappy jumps with variable apex dampening, and grounded landings.
   - Dual-character asymmetric specializations:
     - **Bruno:** Heavy physical manipulation, crate shoving, deep trench excavation, bark deflection.
     - **Milo:** Scent tracking trail visualization, tight burrow crawling, lightweight lever activation, snout-boost launch receiving.
2. **Dynamic Split-Screen & Camera:**
   - Seamless dual-viewport management supporting vertical, horizontal, and single-screen dynamic convergence when puppies are in proximity.
   - Predictive look-ahead camera tracking that frames interactive puzzle elements and hazards.
3. **Cooperative Puzzle Systems:**
   - Modular puzzle framework with clean state transitions (`INACTIVE` -> `ACTIVE` -> `STAGE_SUCCESS` -> `SOLVED`).
   - Timing windows, failure rollback, and checkpoint coordinate persistence.
4. **Hardware & Controller Support:**
   - Simultaneous multi-device arbitration supporting discrete gamepad (Xbox/PlayStation) and keyboard/mouse mapping.
