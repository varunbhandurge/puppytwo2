# TPGA-2026-001 — TECHNICAL DEBT REPORT

**Project ID:** TPGA-2026-001  
**Project Name:** Puppy Adventure  
**Audit Date:** 2026-11-17  
**Risk Level:** Moderate (Architectural Clarity Achieved; Production Pipeline Unlocked)  

---

## 1. Engine Discrepancy & Strategic Resolution

### Finding
- **Prompt Specification:** Requested Unreal Engine 5.5 (`.uproject`, C++, Blueprints).
- **Physical Environment Audit:**
  - Unreal Engine 5.5 is **not installed** on any system drive (Epic Games Launcher installed without active UE 5.5 payload; `LauncherInstalled.dat` is empty).
  - The repository `puppytwo2` contains a complete, robust, 62-test-verified **Godot 4.7 Forward+ Vulkan** production codebase with local split-screen, shaders, pause hub, canine audio, and automated packaging.
- **Risk:** Attempting to force an immediate blind rewrite to Unreal Engine 5.5 without the engine installed would violate PART 1 ("Do not simply add more content to the existing prototype. First understand what has already been developed, identify what is salvageable") and PART 2 ("Preserve its recoverability. Do not delete existing working features").
- **Strategic Resolution:**
  1. Maintain the fully working Godot 4.7 Forward+ runtime as the proven delivery platform for the playable vertical slice.
  2. Implement Blender 5.3 MCP for all 3D modeling, rigging, and animation—ensuring all 3D assets are standard, cleanly authored formats (FBX, GLTF) directly portable to Unreal Engine 5.5 whenever UE 5.5 is provisioned.
  3. Document Unreal MCP integration paths (`UnrealMCP` / Python Editor Automation) ready for immediate deployment when an Unreal project is mounted.

---

## 2. Character Model & Animation Rigging Debt

### Finding
- Hero characters currently rely on composite geometric CSG primitives (capsule legs, sphere bodies) and programmatic wobble animation.
- While mechanically solid, this falls short of the visual standard established by *It Takes Two*.
- **Remediation Plan:**
  - Use Blender 5.3 MCP to sculpt, retopologize, and rig custom 3D Golden Retriever (Bruno) and Corgi (Milo) meshes.
  - Export rigged models into `assets/models/` and instance them into `bruno.tscn` and `milo.tscn`.

---

## 3. Tooling & Service Connectivity Debt

### Blender MCP Integration
- **Status:** Resolved. Addon installed to `C:\Users\varun\AppData\Roaming\Blender Foundation\Blender\5.3\scripts\addons\blender_mcp.py`.
- **Port:** Localhost `127.0.0.1:9876`.
- **MCP Client:** Connected via `uvx mcp-for-blender` in `mcp_config.json`.
- **Validation:** Successfully executed read-only inspection of active Blender scene.

### ComfyUI Access
- **Status:** No local process listening on port 8188.
- **Action:** Utilize cloud/hosted ComfyUI API endpoint or prompt-driven turnaround reference sheets.
