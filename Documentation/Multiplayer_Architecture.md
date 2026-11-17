# MULTIPLAYER ARCHITECTURE SPECIFICATION
# TWO PUPPIES: THE GREAT ADVENTURE

**Document Version:** 1.0.0  
**Phase 1 Target:** Local Two-Player Split-Screen (Full Commercial Production)  
**Phase 2 Target:** Online Co-Op Readiness (Zero Architectural Debt)  

---

## 1. PHASE 1: LOCAL SPLIT-SCREEN SYSTEM ARCHITECTURE

Local two-player split-screen is the primary multiplayer pillar of the initial Windows PC release.

```
+-------------------------------------------------------------------------+
|                        Godot Engine Root (Window)                       |
|                                                                         |
|  +----------------------------------+--------------------------------+  |
|  | SubViewportContainer 1 (Player 1)| SubViewportContainer 2 (P2)    |  |
|  | +------------------------------+ | +----------------------------+ |  |
|  | | SubViewport 1 (World Shared) | | | SubViewport 2 (World Copy) | |  |
|  | |  - Camera3D (Bruno Orbit)    | | |  - Camera3D (Milo Orbit)   | |  |
|  | |  - AudioListener3D (P1 Ear)  | | |  - AudioListener3D (P2 Ear)| |  |
|  | +------------------------------+ | +----------------------------+ |  |
|  +----------------------------------+--------------------------------+  |
|                       || SplitScreenSeparator ||                        |
|                                                                         |
|               +------------------------------------------+              |
|               | Combined HUD & CanvasLayer Notification  |              |
|               +------------------------------------------+              |
+-------------------------------------------------------------------------+
```

### 1.1 Dual Viewport Orchestration
- **Node Topology:** The main scene instantiates two `SubViewportContainer` nodes inside an `HSplitContainer` (or `VSplitContainer` for horizontal orientation).
- **World Sharing:** `SubViewport2.world_3d = SubViewport1.world_3d`. Both viewports render the exact same physics and visual world instance simultaneously, eliminating asset duplication.
- **Audio Listener Routing:** Each SubViewport contains an independent `AudioListener3D`. Sound effects originated near Bruno are panned and attenuated based on Camera 1's position; sound effects near Milo are routed based on Camera 2.

### 1.2 Viewport Orientation Modes
1. **Vertical Split (Default):**
   - Left half (50% width) assigned to Player 1 (Bruno).
   - Right half (50% width) assigned to Player 2 (Milo).
   - Ideal for horizontal exploration and expansive landscapes.
2. **Horizontal Split:**
   - Top half (50% height) assigned to Player 1 (Bruno).
   - Bottom half (50% height) assigned to Player 2 (Milo).
   - Ideal for vertical platforming chapters (e.g., Mountain of Bones, Giant Kitchen shelves).
3. **Dynamic Viewport Fusion:**
   - When distance between puppies $d \le 4.5\text{ m}$ in an open area, the central dividing bar animates its opacity to 0 over 0.6 seconds.
   - SubViewport 2 is hidden, and Camera 1 smoothly pulls back to frame both puppies in a shared cinematic composition.
   - When $d > 5.5\text{ m}$, the screen smoothly splits again.

### 1.3 Input Multiplexing & Player Assignment
- **Device Arbitration:** Managed by `InputManager.gd`.
- **Supported Configurations:**
  - Config A: Gamepad 0 (P1 Bruno) + Gamepad 1 (P2 Milo).
  - Config B: Keyboard + Mouse (P1 Bruno) + Gamepad 0 (P2 Milo).
  - Config C: Split-Keyboard (WASD + Space for P1; Arrow keys + Numpad for P2).
- Hot-plugging: If a controller is disconnected, the game immediately enters an auto-pause state displaying a "Controller Disconnected" prompt.

### 1.4 Shared Progression & Checkpoint Synchronization
- Both players share a single `GameState` instance.
- Pickups, puzzle states, and unlocked gates are global to the session.
- If either puppy dies or falls into an abyss:
  - Both puppies undergo a 0.8-second fade-to-black.
  - Both puppies respawn side-by-side at the latest activated `Checkpoint3D` with full health and restored puzzle state.

---

## 2. PHASE 2: ONLINE CO-OP READINESS ARCHITECTURE

To ensure seamless future addition of online co-op without requiring a gameplay code rewrite, all Phase 1 systems adhere strictly to the **Simulation / Input Decoupling Pattern**.

```
                        +----------------------+
                        |   Hardware Inputs    |
                        +----------+-----------+
                                   |
                                   v
                        +----------------------+
                        |  PuppyCommand Packet |
                        +----------+-----------+
                                   |
         +-------------------------+-------------------------+
         | (Local Mode)                                      | (Online Mode)
         v                                                   v
+------------------+                              +--------------------+
|  PuppyController |                              | Godot Multiplayer  |
|  (Direct Drive)  |                              | ENet / WebRTC RPC  |
+--------+---------+                              +---------+----------+
         |                                                  |
         +-------------------------+------------------------+
                                   |
                                   v
                        +----------------------+
                        |    PuppyBase.gd      |
                        | (Physics Simulation) |
                        +----------------------+
```

### 2.1 Decoupled Data Contracts
Characters never read `Input.is_action_pressed()` directly. Instead, character movement is driven by standardized, serializable command structs:
```gdscript
class_name PuppyCommand extends RefCounted:
    var tick: int
    var move_vector: Vector2
    var jump_pressed: bool
    var interact_pressed: bool
    var bark_pressed: bool
    var crawl_held: bool
```

### 2.2 Network Synchronization Topology
- **Topology:** Client-Authoritative with Server Arbitration (or Peer-to-Peer Host/Client via Godot ENet / Steamworks P2P).
- **Replication Strategy:**
  - **High-Frequency Replication (30 Hz):** Puppy Transform3D (position, rotation), Linear Velocity, Animation State Index.
  - **Low-Frequency / Reliable RPCs:** Puzzle state transitions, checkpoint unlocks, dialogue triggers, boss phase shifts.
  - **Client-Side Prediction & Interpolation:** The local player moves with 0ms perceived latency; remote partner's transform is smoothly interpolated using Hermite spline curves over a 50ms buffer.

### 2.3 Session Management & Friend's Pass
- Architecture designed to integrate with Steamworks API (`ISteamMatchmaking`) and console session managers.
- Support for "Friend's Pass" where an unowned client can join a host's lobby and receive streamed level assets.
