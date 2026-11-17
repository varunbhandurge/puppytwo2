# PERFORMANCE REQUIREMENTS & PROFILING STANDARDS
# TWO PUPPIES: THE GREAT ADVENTURE

**Document Version:** 1.0.0  
**Baseline Test Hardware:** AMD Ryzen 5 9600X 6-Core (12 Threads), 32 GB RAM, NVIDIA GeForce RTX 3060 12GB  
**Operating System:** Windows 11 Pro 64-bit  

---

## 1. HARDWARE SPECIFICATION TIERS

| Hardware Metric | Minimum Spec (1080p 60 FPS) | Baseline / Recommended (1440p 120 FPS) | High-End Target (4K 60+ FPS) |
| :--- | :--- | :--- | :--- |
| **Operating System** | Windows 10/11 64-bit | Windows 11 64-bit | Windows 11 64-bit |
| **CPU** | Quad-Core 3.0 GHz (Ryzen 3 / Core i3) | AMD Ryzen 5 9600X / Core i5-12600K | Ryzen 7 7800X3D / Core i7-14700K |
| **RAM** | 8 GB System RAM | 16–32 GB System RAM | 32 GB System RAM |
| **GPU** | NVIDIA GTX 1060 (6GB) / RX 580 | NVIDIA GeForce RTX 3060 (12GB) | NVIDIA RTX 4070 / RX 7800 XT |
| **Graphics API** | Vulkan 1.2 / Direct3D 12 | Vulkan 1.3 (Forward+) | Vulkan 1.3 (Forward+) |
| **Disk Storage** | 6 GB available space (SSD recommended) | 6 GB available NVMe SSD space | 6 GB available NVMe SSD space |

---

## 2. DUAL-VIEWPORT PERFORMANCE BUDGETS (PER FRAME)

Because local split-screen renders the 3D scene from **two independent camera viewpoints** simultaneously, GPU vertex processing, culling, and shadow map cascades are evaluated twice per frame.

| Performance Metric | Per Single Viewport Budget | Total Combined Frame Budget | Baseline RTX 3060 Target |
| :--- | :--- | :--- | :--- |
| **Visible Triangle Count** | 350,000 Triangles | 700,000 Triangles Max | 550,000 Triangles Average |
| **Draw Calls** | $\le 600$ Calls | $\le 1,200$ Calls | $\le 850$ Calls |
| **Shadow-Casting Lights** | 1 Directional (Sun) + 2 Local Lights | 1 Sun (Shared) + 4 Local Lights | 1 Sun + 2 Spotlights |
| **VRAM Consumption** | 1.0 GB Textures & Geometry | 2.5 GB Combined Buffer Pool | $\le 3.0$ GB on 12GB VRAM |
| **CPU Frame Time** | $\le 3.5\text{ ms}$ | $\le 7.0\text{ ms}$ | $\le 4.2\text{ ms}$ (Ryzen 5 9600X) |
| **GPU Frame Time** | $\le 4.0\text{ ms}$ (at 1440p) | $\le 8.0\text{ ms}$ (120 FPS Target) | $\le 7.2\text{ ms}$ Average |

---

## 3. ENGINE OPTIMIZATION GUIDELINES

1. **Occlusion Culling & Room/Portal System:**
   - Occlusion culling meshes (`OccluderInstance3D`) are baked into all dense environmental structures (garden fences, kitchen cabinets, cavern walls) to cull non-visible geometry in both viewports instantly.
2. **Mesh LOD & Shadow LOD:**
   - High-detail props automatically transition to LOD1 at 12 meters distance and LOD2 at 25 meters.
   - Small props (grass blades, dandelions, pebbles) cast no real-time shadows; shadows are reserved for large structural geometry and characters.
3. **Texture Streaming & Compaction:**
   - All environment textures use VRAM compression (Basis Universal / BC7), slashing memory footprint by 75% compared to raw uncompressed bitmaps.
4. **Zero-Allocation Game Loop:**
   - Standard gameplay code avoids allocating new objects, Arrays, or Dictionaries inside `_process()` and `_physics_process()`. Reusable scratch vectors and cached node references are mandatory.
