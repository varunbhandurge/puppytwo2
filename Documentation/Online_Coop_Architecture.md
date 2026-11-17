# ONLINE CO-OPERATIVE NETWORKING ARCHITECTURE & FRIEND'S PASS BLUEPRINT
# TWO PUPPIES: THE GREAT ADVENTURE

**Document Version:** 1.0.0  
**Networking Model:** Peer-to-Peer (P2P) Authoritative Host with Client Prediction  
**Transport Layers:** Godot 4.7 High-Level Multiplayer (ENet) & Steamworks P2P (SteamNetworkingSockets)  
**Target Performance Budget:** Rock-solid sync up to 150 ms Round-Trip Time (RTT) and 5% packet loss  
**Distribution Innovation:** Friend's Pass System (Zero-Cost Co-op Client)

---

## 1. ARCHITECTURAL OVERVIEW & DESIGN PRINCIPLES

While local two-player split-screen forms the foundation of *Two Puppies: The Great Adventure*, online co-op expands the game to friends playing across different machines. 

### Core Design Rules for Online Co-op:
1. **Zero Input Latency for Both Puppies:** Neither player should feel sluggish controls. The local puppy immediately executes movement, jumping, and barking based on client-side prediction, while remote state is reconciled with authoritative snapshots.
2. **P2P Authoritative Host Model:** Player 1 (Bruno's machine) acts as the simulation Host, authoring dynamic physics objects, enemy/boss AI, and world state. Player 2 (Milo's machine) acts as the Guest Client, streaming verified `PuppyCommand` packets and predicting Milo's kinematics.
3. **Friend's Pass Access:** Following the gold standard established by *It Takes Two*, only one player needs to own the full game. A free downloadable "Friend's Pass" client allows Player 2 to join any host session and play through the entire campaign.

---

## 2. NETWORK TOPOLOGY & COMMUNICATION PIPELINE

```
+-------------------------------------------------------------------------------+
|                             STEAM P2P / NAT PUNCHING                           |
|                         (SteamNetworkingSockets API)                          |
+---------------------------------------+---------------------------------------+
                                        |
         +------------------------------+------------------------------+
         | (Encrypted UDP Stream)                                      |
         v                                                             v
+----------------------------------+          +----------------------------------+
|      HOST CLIENT (Player 1)      |          |      GUEST CLIENT (Player 2)     |
|             [Bruno]              |          |              [Milo]              |
+----------------------------------+          +----------------------------------+
| - Authoritative GodotPhysics3D   |          | - Client-Side Milo Prediction    |
| - AI & Boss Logic Execution      |          | - Smooth Bruno Interpolation     |
| - Broadcasts World Snapshots     |          | - Transmits PuppyCommand Packets |
|   (20 Hz compressed delta)       |          |   (60 Hz unbuffered UDP)         |
| - Validates Milo Inputs          |          | - Jitter Buffer (30-50ms window) |
+----------------------------------+          +----------------------------------+
```

---

## 3. PACKET PROTOCOL & SERIALIZATION

### 3.1 Input Command Stream (`PuppyCommandPacket`)
Sent by both peers every physical tick (60 Hz) over unbuffered, unreliable-sequenced UDP channel:
```
[Header: 4 Bytes]
  - Sequence ID: uint32 (Monotonically increasing)
[Timestamp: 4 Bytes]
  - Client Simulation Time: float32
[Input Payload: 4 Bytes]
  - Move Vector X: int8 (-127 to +127, normalized)
  - Move Vector Y: int8 (-127 to +127, normalized)
  - Button Bitmask: uint16
      * Bit 0: Jump Just Pressed
      * Bit 1: Interact Just Pressed
      * Bit 2: Interact Held
      * Bit 3: Bark Just Pressed
      * Bit 4: Special (Dig/Scent) Just Pressed
      * Bit 5: Special Held
      * Bit 6: Sprint Held
      * Bits 7-15: Reserved
Total Packet Size: 12 Bytes (Extremely lightweight bandwidth: < 1.0 KB/s per player).
```

### 3.2 Authoritative World Snapshot (`WorldSnapshotPacket`)
Broadcast by Host at 20 Hz (every 3 physical ticks) over reliable-ordered UDP channel:
```
[Header: 6 Bytes]
  - Snapshot Tick: uint32
  - Active Chapter ID: uint8
  - Active Beat ID: uint8
[Bruno State: 24 Bytes]
  - Position: Vector3 (3x float32 = 12 Bytes)
  - Velocity: Vector3 (3x float32 = 12 Bytes)
[Milo Authoritative Correction: 24 Bytes]
  - Position: Vector3 (3x float32 = 12 Bytes)
  - Velocity: Vector3 (3x float32 = 12 Bytes)
[Dynamic Physics Props: Variable Bytes]
  - Pushed Blocks / Crates / Boss Position / Trigger Flags
[Checksum: 2 Bytes]
  - CRC16 Checksum
```

---

## 4. CLIENT-SIDE PREDICTION, RECONCILIATION & SMOOTHING

### 4.1 Prediction Workflow for Guest (Milo)
1. When Player 2 presses `Jump`, Milo executes jump kinematics immediately on frame 0.
2. The input packet is tagged with `tick_id = T` and transmitted to Host.
3. The guest stores the local position and velocity in a rolling history circular buffer (120 frames).
4. When Host returns an authoritative snapshot for tick `T`, the guest compares:
   $$\Delta_{\text{pos}} = \| \mathbf{P}_{\text{guest}}(T) - \mathbf{P}_{\text{host}}(T) \|$$
5. If $\Delta_{\text{pos}} < 0.08\text{ m}$ (threshold for acceptable divergence), no correction occurs.
6. If $\Delta_{\text{pos}} \ge 0.08\text{ m}$ (e.g. Bruno bumped Milo or an obstacle blocked him on the host):
   - Milo snaps to $\mathbf{P}_{\text{host}}(T)$.
   - All subsequent unacknowledged inputs from $T+1$ to current tick are fast-forwarded re-simulated.
   - A visual render transform smoothly lerps the puppy mesh over 3 frames to avoid visual snapping.

### 4.2 Jitter Buffer & Latency Compensation
- A dynamic jitter buffer scales between 30 ms (on low latency LAN/fiber) and 90 ms (on high-jitter mobile/Wi-Fi).
- Remote puppy positions are Hermite-spline interpolated between snapshot $S_{k-1}$ and $S_k$, providing silky 120 FPS visual fluidity even with 20 Hz network snapshot intervals.

---

## 5. FRIEND'S PASS MONETIZATION & INVITATION MODEL

```
+-------------------------------------------------------------------------------+
|                      FRIEND'S PASS USER EXPERIENCE FLOW                       |
+-------------------------------------------------------------------------------+
| 1. Player A purchases "Two Puppies: The Great Adventure" on Steam/Console.   |
| 2. Player B downloads the free "Two Puppies: Friend's Pass" app.              |
| 3. Player A selects "Play Online Co-op" -> "Invite Friend via Steam/Console". |
| 4. Player B accepts invite overlay. The Friend's Pass client connects to      |
|    Player A's lobby via Steam P2P encrypted socket.                           |
| 5. Player A's host transmits the active chapter & progression state.          |
| 6. Both players experience the full 15-hour campaign together with zero caps! |
+-------------------------------------------------------------------------------+
```

---

## 6. DISCONNECT HANDLING & SESSION RECOVERY

- **Host Disconnect:** If Host connection drops, the guest pauses with prompt: *"Lost connection to Bruno. Reconnecting... (30s timeout)"*. If timeout expires, save state is mirrored locally.
- **Guest Disconnect:** If Milo disconnects, game immediately pauses for Bruno: *"Milo disconnected. Waiting for partner or switch to Local Split-Screen"*. Bruno can seamlessly plug in a second controller and continue locally without returning to the main menu.
- **Heartbeat & Keepalive:** Pings dispatched every 500 ms. If no packet arrives within 4.0 seconds, connection enters graceful reconnect state.

---

## 7. AUTOMATED VERIFICATION MATRIX

| Metric / Scenario | Operational Requirement | Architectural Implementation |
| :--- | :--- | :--- |
| **Input Bandwidth** | $\le 2.0\text{ KB/s}$ upstream | 12-byte packed binary `PuppyCommand` packets |
| **Snapshot Bandwidth** | $\le 12.0\text{ KB/s}$ downstream | 20 Hz delta-compressed world updates |
| **Prediction Error** | Zero noticeable stutter under 100ms | Hermite interpolation + 3-frame mesh reconciliation |
| **Packet Loss Handling** | Seamless play under 5% packet loss | UDP packet redundancy & sliding window ack |
| **Split-Screen Fallback** | Instantaneous offline transition | `NetworkManager.fallback_to_local_splitscreen()` |

This networking architecture delivers AAA-tier responsiveness, enabling Bruno and Milo to conquer their epic journey across the globe with unmatched reliability.
