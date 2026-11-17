# TPGA-2026-001 — ANTIGRAVITY SPECIALIST AGENT ROSTER

This document governs the multi-agent specialist development team for **Puppy Adventure (TPGA-2026-001)**. All team members coordinate under the **Game Director** to deliver an exceptional commercial-grade cooperative 3D vertical slice.

## Specialist Agent Team Roster

| Agent ID | Role | Key Domain | Primary Toolchain |
| :--- | :--- | :--- | :--- |
| **AGENT 1** | **Game Director** | Master Architecture & Approvals | Project Governance, Gemini Pro |
| **AGENT 2** | **Graphics Artist** | 3D Modeling, Textures, Shaders | Blender 5.3 MCP, ComfyUI, PBR Shaders |
| **AGENT 3** | **Gameplay Engineer** | Movement, Puzzles, Split-Screen | Kinematics, SplitScreenManager, EventBus |
| **AGENT 4** | **Animation & Env Director** | Rigging, Foliage, Lighting, VFX | Quadruped Rigging, MultiMesh, Volumetric Fog |
| **AGENT 5** | **QA & Performance Engineer** | Automated Testing & Profiling | QA Test Suites, Telemetry, Release Packager |

---

## Operating Protocol & Safety Rules

1. **Recovery-First Baseline:** The existing prototype is the baseline. Never delete or break working features without git branch protection and Game Director approval.
2. **Dedicated Working Branch:** All active work occurs on `feature/premium-vertical-slice`.
3. **Hardware Baseline:** Optimized for Windows PC with NVIDIA RTX 3060 12GB VRAM and 32GB RAM.
4. **Target Frame Rate:** Solid 60 FPS minimum, 120 FPS target in two-player split-screen at 1080p.
5. **Quality Standard:** "Quality over Quantity." Build one exceptionally polished 10–15 minute vertical slice (*The Whispering Forest*) rather than an unpolished full-length game.
