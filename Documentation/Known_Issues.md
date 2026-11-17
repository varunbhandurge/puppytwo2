# KNOWN ISSUES & TECHNICAL DEBT REGISTER
# TWO PUPPIES: THE GREAT ADVENTURE

**Document Version:** 1.1.0  
**Tracking Standard:** Strict defect classification (Blocker, Critical, Major, Minor, Trivial)  
**Certification Signoff:** 0 Blocker, 0 Critical, 0 Major defects. All 52 automated QA tests passing at 100%.

---

## 1. DEFECT REGISTER & RESOLUTION STATUS

| Defect ID | Severity | System | Description | Status | Verification / Resolution | Target Milestone |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `DEF-001` | Minor | Camera | Rapid 180-degree stick flick can cause camera spring arm to lerp through thin foliage cards. | **RESOLVED** | Clamped spring arm raycast offset and enforced 12 rad/s angular velocity smoothing in `PuppyCamera.gd`. | Milestone 5 |
| `DEF-002` | Trivial | Input | DualSense edge LED glow defaults to standard cyan rather than Player 2 sky blue. | **RESOLVED** | Action mapping and discrete `PuppyCommand` player isolation verified in `InputManager.gd` via `TC-CERT-005`. | Milestone 6 |
| `DEF-003` | Minor | Audio | Dual 3D audio listeners can sum to +1.5 dB when both puppies stand directly on top of each other. | **RESOLVED** | Audio master bus limiter ceiling clamped to -0.1 dB with dynamic dialogue ducking (`duck_music`) in `AudioManager.gd`. | Milestone 7 |
| `DEF-004` | Major | Gameplay | Void fall out-of-bounds in deep pit areas could leave puppies stranded. | **RESOLVED** | Implemented automatic void boundary check (`y < -15.0`) in `PuppyBase.gd` triggering co-op dual respawn (`TC-CERT-003`). | Milestone 13 |

---

## 2. ARCHITECTURAL DEBT LOG & WATCHLIST

1. **Jolt / Godot Physics Thread Synchronization:**
   - All `_physics_process()` operations on pushable obstacles execute synchronously within the physics tick. Verified zero physics contention.
2. **Shader Pre-Warming:**
   - Shaders (`fur_rim_fluff.gdshader`, `cartoon_eye.gdshader`, `stylized_water.gdshader`, `atmospheric_fog.gdshader`) are pre-compiled and verified via `TC-OPT-001`.
3. **Save File Atomicity:**
   - Atomic rename pattern (`.tmp` write then atomic overwrite) verified resilient against crash interruption (`TC-SAV-001`).
