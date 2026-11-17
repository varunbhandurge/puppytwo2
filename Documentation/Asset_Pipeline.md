# ASSET PIPELINE & CONTENT STANDARDS
# TWO PUPPIES: THE GREAT ADVENTURE

**Document Version:** 1.0.0  
**Asset Formats:** GLTF 2.0 / GLB (3D Meshes), PNG / WebP (Textures), OGG Vorbis / WAV (Audio)  
**Authoring Tools:** Blender 4.x / 5.x, Substance Painter / Material Maker, Godot Shader Language  

---

## 1. 3D ASSET STANDARDS & METRICS

### 1.1 Scale & Coordinates
- **Unit Scale:** 1 Godot Unit = 1 Real-World Meter (1.0 = 1.0m).
- **Coordinate System:** Y-Up, -Z Forward (Standard Godot / OpenGL convention).
- **Character Metrics:**
  - Bruno: Shoulder height = 0.38m; Body length = 0.55m; Weight = 14 kg.
  - Milo: Shoulder height = 0.24m; Body length = 0.42m; Weight = 8 kg.
- **Environment Metrics:**
  - Standard Garden Fence: Height = 2.0m (a massive fortress wall to a puppy).
  - Kitchen Counter: Height = 0.90m.
  - Stepping Stone: Radius = 0.25m, Height = 0.08m.

### 1.2 Topology & Polygon Budgets
- **Protagonists (Bruno / Milo):** 25,000 – 35,000 triangles max.
- **Major Boss Characters (Whiskers, Mole King):** 30,000 – 50,000 triangles.
- **Minor Enemies / Critters:** 3,000 – 8,000 triangles.
- **Key Environment Props (Wheelbarrow, Sprinkler):** 4,000 – 12,000 triangles.
- **Background Foliage & Scenery Props:** 200 – 1,500 triangles with LOD0, LOD1 (50%), and LOD2 (20%).

---

## 2. TEXTURE & MATERIAL PIPELINE

### 2.1 Texture Maps & Compaction
To minimize VRAM overhead during simultaneous dual-viewport rendering:
- **Albedo / Base Color:** sRGB 8-bit PNG / WebP (2048x2048 for characters, 1024x1024 for props).
- **Normal Map:** Tangent space Normal (DirectX/OpenGL convention, Y+).
- **ORM Packed Map (Linear RGB):**
  - **Red Channel:** Ambient Occlusion (AO).
  - **Green Channel:** Roughness (0.0 = Glossy, 1.0 = Matte).
  - **Blue Channel:** Metallic (0.0 = Dielectric, 1.0 = Pure Metal).
- **Emission Map:** Used for bioluminescent mushrooms, fireflies, and ancient runes.

### 2.2 Stylized Shading Guidelines
- Emphasize soft hand-painted gradients, warm edge wear, subtle painterly brushstroke normal maps, and vibrant saturated albedos.
- Avoid noisy micro-details or gritty photoreal photographic noise that causes aliasing in split-screen resolutions.

---

## 3. AUDIO PIPELINE & STANDARDS

### 3.1 Audio Specifications
- **Music (BGM):** 48 kHz, 16-bit, Stereo, OGG Vorbis (160–192 kbps). Loop points configured via Godot import metadata.
- **Sound Effects (SFX):** 44.1 / 48 kHz, 16-bit, Mono / Stereo, uncompressed WAV for zero-latency instant response (barks, footstep taps, impacts).
- **Dialogue / Vocalizations:** 48 kHz, 24-bit, Mono WAV.

### 3.2 Dynamic Audio Mixing Architecture
Audio is routed through 6 dedicated mixer buses in `default_bus_layout.tres`:
1. `Master`: Final output limiter (-0.1 dB ceiling).
2. `BGM`: Music ducking automatically (-4 dB) when important barks or dialogue occur.
3. `SFX_P1`: Sound effects localized to Player 1 (Camera 1 listener).
4. `SFX_P2`: Sound effects localized to Player 2 (Camera 2 listener).
5. `Ambience`: Wind, water trickle, rustling leaves, birds chirping.
6. `UI`: Menu clicks, puzzle chimes, checkpoint jingles.

---

## 4. CENTRAL ASSET REGISTER TEMPLATE

All assets used in the production must be logged in this standardized format:

| Asset ID | Asset Name | Category | Source / Creator | License | Format | Target Resolution / Polycount | Import Path |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `CHR_BRUNO_01` | Bruno Master Mesh | Character | In-House Studio | Proprietary (Original) | `.glb` | 28,400 Tris | `res://assets/models/characters/bruno.glb` |
| `CHR_MILO_01` | Milo Master Mesh | Character | In-House Studio | Proprietary (Original) | `.glb` | 26,100 Tris | `res://assets/models/characters/milo.glb` |
| `ENV_GARDEN_01`| Garden Kit Pieces | Environment | In-House Studio | Proprietary (Original) | `.glb` | 45,000 Tris total | `res://assets/models/environment/garden_kit.glb`|
| `SFX_BARK_BRUNO`| Bruno Deep Bark | Audio | In-House Studio | Proprietary (Original) | `.wav` | 48kHz Mono | `res://assets/audio/sfx/bark_bruno.wav` |
| `SFX_YIP_MILO` | Milo High Yip | Audio | In-House Studio | Proprietary (Original) | `.wav` | 48kHz Mono | `res://assets/audio/sfx/yip_milo.wav` |
| `BGM_BACKYARD` | Backyard Morning | Music | In-House Studio | Proprietary (Original) | `.ogg` | 48kHz Stereo | `res://assets/audio/music/backyard_morning.ogg` |
