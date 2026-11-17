# TPGA-2026-001 — GRAPHICS AUDIT

**Project ID:** TPGA-2026-001  
**Project Name:** Puppy Adventure  
**Audit Scope:** 3D Art, Shaders, Materials, Lighting, and Visual Consistency  
**Visual Reference:** *It Takes Two* (Hazelight) with original animated-film aesthetic  
**Target Hardware:** NVIDIA GeForce RTX 3060 12GB VRAM  

---

## 1. Character Visual Quality

### Current State
- Bruno and Milo are composed of geometric CSG/Primitive meshes (ellipsoids for head/body, capsules for legs, cones for ears).
- Texturing relies on solid diffuse albedo with clamped rim-fluff shaders (`fur_rim_fluff.gdshader`) and cartoon eye spheres (`cartoon_eye.gdshader`).
- Distinct color coding: Bruno is golden amber with red collar; Milo is tri-color corgi brown/white with blue collar.

### Deficiencies vs. *It Takes Two* Standard
1. **Geometric Topology:** Bodies lack sculpted organic musculature, paw pad definition, snout creases, and expressive eyelid edge loops.
2. **Hair & Fur Tactility:** While the newly clamped rim shader gives a cartoon halo, the characters lack strand depth, tufted cheek fur, and soft tail plume geometry.
3. **Facial Rigging:** Eyes are static spheres with pupil panning rather than 3D deformation sockets with brows and muzzle squashing.

### Improvement Strategy (Blender 5.3 MCP)
- Sculpt high-resolution character sculpts in Blender 5.3 via MCP automation.
- Retopologize to clean, lightweight quad meshes (~8,000–12,000 tris per character).
- Texture bake ambient occlusion and stylized fur grain into normal/roughness maps.

---

## 2. Environment & Foliage Quality

### Current State
- Chapter 1 features a fully procedural lawn ground shader (`stylized_lawn_ground.gdshader`) with manicured mowing stripes, micro-fiber normal bump mapping, and worn dirt pathways.
- GPU-instanced 3D Star-Tuft grass system (`realistic_stylized_grass.gdshader`, `lawn_grass_scatter.gd`) scattering 2,400+ swaying 3D blade tufts, 280+ wildflowers, 80+ autumn leaves, and canine play props in a single draw call.
- Atmospheric volumetric fog with subtle sunbeams and directional soft shadows.

### Deficiencies for *The Whispering Forest*
1. **Canopy & Tree Density:** The existing project lacks towering stylized mossy oak trees with twisted branches and canopy leaf cards.
2. **Organic Forest Ground Cover:** The forest floor requires damp leaf litter, hollow rotting logs with fungal shelves, patch moss, and river rock clusters.
3. **Interactive Water Shader:** The stream crossing puzzle requires dynamic flowing water with shore foam lines, depth refraction, and interactive water ripples when paws step in.

---

## 3. Lighting & Post-Processing Pipeline

### Current State
- Vulkan Forward+ clustered renderer.
- WorldEnvironment configured with `tonemap_mode = 2` (Filmic/ACES), SSAO, SSIL, soft Bloom (`glow_intensity = 0.25`), and Volumetric Fog (`density = 0.006`).
- Directional sun with soft penumbra blur (`shadow_blur = 1.5`).

### Performance Telemetry on RTX 3060
- **Frame Time:** ~2.1ms (comfortably sustaining 120 FPS in split-screen mode).
- **VRAM Utilization:** ~1.4 GB / 12 GB available.
- **Draw Calls:** < 180 total across both split-screen viewports.
