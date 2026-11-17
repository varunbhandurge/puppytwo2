"""
Two Puppies: The Great Adventure — Automated Stylized 3D Asset Generator
Runs inside Blender 5.3 to sculpt, texture, and export game-ready .glb models.
Features smooth shading, rich PBR materials, and AAA stylized cartoon proportions.
Forward direction is +Y in Blender (maps to glTF -Z forward in Godot).
"""

import bpy
import bmesh
import math
import os
from mathutils import Vector, Matrix, Euler

OUTPUT_DIR = os.path.abspath("src/assets/models")
os.makedirs(OUTPUT_DIR, exist_ok=True)

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    for block in list(bpy.data.meshes):
        bpy.data.meshes.remove(block)
    for block in list(bpy.data.materials):
        bpy.data.materials.remove(block)

def create_pbr_material(name, base_color, roughness=0.7, metallic=0.0, emission=None, emission_strength=1.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs['Base Color'].default_value = base_color
        bsdf.inputs['Roughness'].default_value = roughness
        bsdf.inputs['Metallic'].default_value = metallic
        if emission:
            bsdf.inputs['Emission Color'].default_value = emission
            if 'Emission Strength' in bsdf.inputs:
                bsdf.inputs['Emission Strength'].default_value = emission_strength
    return mat

def export_glb(filename):
    filepath = os.path.join(OUTPUT_DIR, filename)
    bpy.ops.object.select_all(action='SELECT')
    for obj in bpy.context.selected_objects:
        if obj.type == 'MESH':
            bpy.context.view_layer.objects.active = obj
            bpy.ops.object.shade_smooth()
    bpy.ops.export_scene.gltf(
        filepath=filepath,
        export_format='GLB',
        use_selection=False,
        export_apply=True
    )
    print(f"[EXPORT] Successfully generated {filepath}")

# ==============================================================================
# 1. STYLIZED ANCIENT OAK TREE
# ==============================================================================
def build_ancient_oak():
    clear_scene()
    mat_bark = create_pbr_material("Mat_Bark", (0.28, 0.17, 0.10, 1.0), roughness=0.88)
    mat_leaves = create_pbr_material("Mat_Leaves", (0.16, 0.44, 0.12, 1.0), roughness=0.62)

    bm = bmesh.new()
    segments = 14
    height_steps = [
        (0.0, 2.4, 0.0),
        (1.0, 1.6, 0.05),
        (3.5, 1.3, -0.1),
        (6.0, 1.1, 0.15),
        (8.5, 0.85, 0.0)
    ]
    
    prev_verts = []
    for h, radius, offset_x in height_steps:
        ring = []
        for i in range(segments):
            angle = i * (2.0 * math.pi / segments)
            r = radius
            if h == 0.0 and i % 3 == 0:
                r *= 1.45
            x = math.cos(angle) * r + offset_x
            y = math.sin(angle) * r
            v = bm.verts.new((x, y, h))
            ring.append(v)
        if prev_verts:
            for i in range(segments):
                i_next = (i + 1) % segments
                bm.faces.new([prev_verts[i], prev_verts[i_next], ring[i_next], ring[i]])
        prev_verts = ring

    mesh_trunk = bpy.data.meshes.new("OakTrunkMesh")
    bm.to_mesh(mesh_trunk)
    bm.free()
    obj_trunk = bpy.data.objects.new("OakTrunk", mesh_trunk)
    obj_trunk.data.materials.append(mat_bark)
    bpy.context.collection.objects.link(obj_trunk)

    foliage_positions = [
        (0.0, 0.0, 10.5, 3.8, 3.2),
        (2.6, 1.8, 9.0, 2.8, 2.5),
        (-2.4, 2.0, 8.8, 2.7, 2.4),
        (-1.8, -2.2, 9.2, 2.9, 2.6),
        (2.2, -1.9, 8.9, 2.8, 2.5),
        (0.0, 0.0, 12.8, 2.6, 2.2),
    ]
    for x, y, z, rx, rz in foliage_positions:
        bpy.ops.mesh.primitive_uv_sphere_add(segments=18, ring_count=14, radius=1.0, location=(x, y, z))
        sphere = bpy.context.active_object
        sphere.scale = (rx, rx * 0.95, rz)
        sphere.data.materials.append(mat_leaves)

    export_glb("stylized_ancient_oak.glb")

# ==============================================================================
# 2. STYLIZED MOUNTAIN PINE TREE
# ==============================================================================
def build_mountain_pine():
    clear_scene()
    mat_bark = create_pbr_material("Mat_PineBark", (0.24, 0.15, 0.10, 1.0), roughness=0.9)
    mat_needles = create_pbr_material("Mat_PineNeedles", (0.09, 0.32, 0.14, 1.0), roughness=0.68)

    bpy.ops.mesh.primitive_cylinder_add(radius=0.45, depth=12.0, vertices=16, location=(0, 0, 6.0))
    trunk = bpy.context.active_object
    trunk.data.materials.append(mat_bark)

    tiers = [
        (3.0, 3.8, 2.4),
        (5.2, 3.2, 2.2),
        (7.2, 2.6, 2.0),
        (9.0, 2.0, 1.8),
        (10.6, 1.3, 1.6)
    ]
    for z, radius, depth in tiers:
        bpy.ops.mesh.primitive_cone_add(radius1=radius, radius2=0.1, depth=depth, vertices=16, location=(0, 0, z))
        cone = bpy.context.active_object
        cone.data.materials.append(mat_needles)

    export_glb("stylized_mountain_pine.glb")

# ==============================================================================
# 3. STYLIZED RIVER BOULDERS & STEPPING STONES
# ==============================================================================
def build_river_boulders():
    clear_scene()
    mat_stone = create_pbr_material("Mat_RiverStone", (0.24, 0.26, 0.23, 1.0), roughness=0.55)
    mat_moss = create_pbr_material("Mat_StoneMoss", (0.16, 0.44, 0.12, 1.0), roughness=0.78)

    bpy.ops.mesh.primitive_uv_sphere_add(segments=22, ring_count=16, radius=1.6, location=(0, 0, 0.75))
    rock = bpy.context.active_object
    rock.scale = (1.5, 1.15, 0.70)
    rock.data.materials.append(mat_stone)

    bpy.ops.mesh.primitive_uv_sphere_add(segments=20, ring_count=14, radius=1.35, location=(0, 0, 0.95))
    moss_cap = bpy.context.active_object
    moss_cap.scale = (1.4, 1.05, 0.55)
    moss_cap.data.materials.append(mat_moss)

    bpy.ops.mesh.primitive_cylinder_add(radius=0.9, depth=0.45, vertices=20, location=(3.4, 0.0, 0.22))
    step1 = bpy.context.active_object
    step1.scale = (1.2, 0.95, 1.0)
    step1.data.materials.append(mat_stone)

    bpy.ops.mesh.primitive_cylinder_add(radius=0.75, depth=0.4, vertices=20, location=(-3.2, 0.3, 0.20))
    step2 = bpy.context.active_object
    step2.scale = (1.1, 1.0, 1.0)
    step2.data.materials.append(mat_stone)

    export_glb("stylized_river_boulders.glb")

# ==============================================================================
# 4. STYLIZED HOLLOW FALLEN LOG BRIDGE
# ==============================================================================
def build_hollow_log():
    clear_scene()
    mat_bark = create_pbr_material("Mat_LogBark", (0.32, 0.20, 0.12, 1.0), roughness=0.88)
    mat_fungi = create_pbr_material("Mat_Fungi", (0.88, 0.62, 0.22, 1.0), roughness=0.4)

    r_outer = 1.1
    length = 10.0
    bpy.ops.mesh.primitive_cylinder_add(radius=r_outer, depth=length, vertices=20, location=(0, 0, 0))
    outer_cyl = bpy.context.active_object
    outer_cyl.rotation_euler = (0, math.pi * 0.5, 0)
    outer_cyl.data.materials.append(mat_bark)

    fungi_spots = [
        (-2.2, 0.85, 0.4, 0.45),
        (1.5, -0.75, 0.35, 0.4),
        (3.0, 0.70, 0.45, 0.5)
    ]
    for fx, fy, fz, fr in fungi_spots:
        bpy.ops.mesh.primitive_cylinder_add(radius=fr, depth=0.08, vertices=12, location=(fx, fy, fz))
        fungus = bpy.context.active_object
        fungus.rotation_euler = (0.3, 0.2, 0.4)
        fungus.data.materials.append(mat_fungi)

    export_glb("stylized_hollow_log.glb")

# ==============================================================================
# 5. STYLIZED HERO PUPPY — BRUNO (GOLDEN RETRIEVER)
# - Forward is +Y in Blender -> Maps to -Z in Godot (Forward into the scene)
# ==============================================================================
def build_bruno_hero():
    clear_scene()
    mat_gold = create_pbr_material("Mat_BrunoGold", (0.92, 0.66, 0.30, 1.0), roughness=0.80)
    mat_cream = create_pbr_material("Mat_BrunoCream", (0.96, 0.88, 0.72, 1.0), roughness=0.75)
    mat_nose = create_pbr_material("Mat_BrunoNose", (0.10, 0.09, 0.09, 1.0), roughness=0.15)
    mat_collar = create_pbr_material("Mat_BrunoCollar", (0.88, 0.18, 0.18, 1.0), roughness=0.35)
    mat_tag = create_pbr_material("Mat_BrunoTag", (1.0, 0.85, 0.25, 1.0), roughness=0.18, metallic=0.95)
    mat_eye = create_pbr_material("Mat_BrunoEye", (0.06, 0.05, 0.05, 1.0), roughness=0.08)
    mat_white = create_pbr_material("Mat_EyeWhite", (0.98, 0.98, 0.98, 1.0), roughness=0.1)

    # 1. Main Golden Torso
    bpy.ops.mesh.primitive_uv_sphere_add(segments=18, ring_count=14, radius=0.25, location=(0, 0.05, 0.44))
    torso = bpy.context.active_object
    torso.scale = (1.0, 1.35, 0.95)
    torso.data.materials.append(mat_gold)

    # Cream chest bib (front)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=0.20, location=(0, 0.22, 0.42))
    chest = bpy.context.active_object
    chest.scale = (0.85, 0.85, 0.9)
    chest.data.materials.append(mat_cream)

    # 2. Friendly Anatomical Head (forward)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=18, ring_count=14, radius=0.22, location=(0, 0.32, 0.65))
    head = bpy.context.active_object
    head.scale = (1.0, 1.05, 1.0)
    head.data.materials.append(mat_gold)

    # Snout / Muzzle (smooth, rounded, forward)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=0.12, location=(0, 0.48, 0.62))
    snout = bpy.context.active_object
    snout.scale = (1.0, 1.3, 0.85)
    snout.data.materials.append(mat_cream)

    # Wet black button nose
    bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=10, radius=0.045, location=(0, 0.62, 0.64))
    nose = bpy.context.active_object
    nose.data.materials.append(mat_nose)

    # Expressive Dark Eyes with cute specular highlight spheres
    for side in [-1, 1]:
        bpy.ops.mesh.primitive_uv_sphere_add(segments=14, ring_count=10, radius=0.04, location=(side * 0.10, 0.44, 0.71))
        eye = bpy.context.active_object
        eye.data.materials.append(mat_eye)
        bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=6, radius=0.012, location=(side * 0.09, 0.47, 0.73))
        glint = bpy.context.active_object
        glint.data.materials.append(mat_white)

    # Floppy Golden Retriever Drop-Ears
    for side in [-1, 1]:
        bpy.ops.mesh.primitive_uv_sphere_add(segments=14, ring_count=10, radius=0.10, location=(side * 0.22, 0.28, 0.60))
        ear = bpy.context.active_object
        ear.scale = (0.45, 0.9, 1.6)
        ear.rotation_euler = (-0.3, side * 0.2, side * 0.3)
        ear.data.materials.append(mat_gold)

    # 3. Four Quadruped Legs with Rounded Paws & Sock Markings
    leg_coords = [
        (-0.14, 0.22, 0.22, 0.42), # Front Left
        (0.14, 0.22, 0.22, 0.42),  # Front Right
        (-0.15, -0.16, 0.22, 0.40), # Back Left
        (0.15, -0.16, 0.22, 0.40),  # Back Right
    ]
    for lx, ly, lz, lh in leg_coords:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.065, depth=lh, vertices=14, location=(lx, ly, lz))
        leg = bpy.context.active_object
        leg.data.materials.append(mat_gold)
        # Rounded Paw
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=10, radius=0.075, location=(lx, ly + 0.03, 0.05))
        paw = bpy.context.active_object
        paw.scale = (1.0, 1.25, 0.6)
        paw.data.materials.append(mat_cream)

    # 4. Plumy Golden Retriever Tail (curves up at back, -Y)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.05, depth=0.34, vertices=12, location=(0, -0.26, 0.54))
    tail = bpy.context.active_object
    tail.rotation_euler = (0.85, 0, 0)
    tail.data.materials.append(mat_gold)

    # 5. Red Collar & Golden Dog Tag
    bpy.ops.mesh.primitive_torus_add(major_radius=0.18, minor_radius=0.025, location=(0, 0.22, 0.54))
    collar = bpy.context.active_object
    collar.data.materials.append(mat_collar)

    bpy.ops.mesh.primitive_cylinder_add(radius=0.04, depth=0.015, vertices=16, location=(0, 0.38, 0.48))
    tag = bpy.context.active_object
    tag.rotation_euler = (math.pi * 0.5, 0, 0)
    tag.data.materials.append(mat_tag)

    export_glb("stylized_bruno_hero.glb")

# ==============================================================================
# 6. STYLIZED HERO PUPPY — MILO (WELSH CORGI)
# - Forward is +Y in Blender -> Maps to -Z in Godot
# ==============================================================================
def build_milo_hero():
    clear_scene()
    mat_sable = create_pbr_material("Mat_MiloSable", (0.86, 0.50, 0.20, 1.0), roughness=0.78)
    mat_white = create_pbr_material("Mat_MiloWhite", (0.98, 0.96, 0.92, 1.0), roughness=0.72)
    mat_pink = create_pbr_material("Mat_MiloInnerEar", (0.95, 0.72, 0.68, 1.0), roughness=0.65)
    mat_nose = create_pbr_material("Mat_MiloNose", (0.08, 0.08, 0.08, 1.0), roughness=0.15)
    mat_collar = create_pbr_material("Mat_MiloCollar", (0.18, 0.52, 0.92, 1.0), roughness=0.35)
    mat_tag = create_pbr_material("Mat_MiloTag", (0.88, 0.90, 0.94, 1.0), roughness=0.18, metallic=0.95)
    mat_eye = create_pbr_material("Mat_MiloEye", (0.05, 0.05, 0.05, 1.0), roughness=0.08)

    # 1. Low-Riding Barrel Torso
    bpy.ops.mesh.primitive_uv_sphere_add(segments=18, ring_count=14, radius=0.22, location=(0, 0.06, 0.32))
    torso = bpy.context.active_object
    torso.scale = (0.92, 1.5, 0.85)
    torso.data.materials.append(mat_sable)

    # White belly & chest bib
    bpy.ops.mesh.primitive_uv_sphere_add(segments=14, ring_count=10, radius=0.16, location=(0, 0.18, 0.28))
    chest_bib = bpy.context.active_object
    chest_bib.scale = (0.8, 0.75, 0.9)
    chest_bib.data.materials.append(mat_white)

    # 2. Alert Foxy Head
    bpy.ops.mesh.primitive_uv_sphere_add(segments=18, ring_count=14, radius=0.19, location=(0, 0.28, 0.48))
    head = bpy.context.active_object
    head.scale = (0.95, 1.0, 0.95)
    head.data.materials.append(mat_sable)

    # White Snout
    bpy.ops.mesh.primitive_uv_sphere_add(segments=14, ring_count=10, radius=0.10, location=(0, 0.42, 0.46))
    snout = bpy.context.active_object
    snout.scale = (0.88, 1.25, 0.75)
    snout.data.materials.append(mat_white)

    # Black Button Nose
    bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=10, radius=0.038, location=(0, 0.54, 0.48))
    nose = bpy.context.active_object
    nose.data.materials.append(mat_nose)

    # Alert Inquisitive Eyes with glint
    for side in [-1, 1]:
        bpy.ops.mesh.primitive_uv_sphere_add(segments=14, ring_count=10, radius=0.035, location=(side * 0.09, 0.38, 0.54))
        eye = bpy.context.active_object
        eye.data.materials.append(mat_eye)
        bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=6, radius=0.010, location=(side * 0.08, 0.41, 0.56))
        glint = bpy.context.active_object
        glint.data.materials.append(mat_white)

    # Tall Upright Fox Ears with Peach Inner Ear Fluff
    for side in [-1, 1]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.09, radius2=0.01, depth=0.22, vertices=16, location=(side * 0.16, 0.22, 0.65))
        ear = bpy.context.active_object
        ear.scale = (0.8, 0.4, 1.1)
        ear.rotation_euler = (-0.1, side * 0.35, -side * 0.15)
        ear.data.materials.append(mat_sable)

        # Peach Inner ear
        bpy.ops.mesh.primitive_cone_add(radius1=0.06, radius2=0.01, depth=0.16, vertices=12, location=(side * 0.15, 0.23, 0.65))
        inner_ear = bpy.context.active_object
        inner_ear.scale = (0.6, 0.25, 0.9)
        inner_ear.rotation_euler = (-0.1, side * 0.35, -side * 0.15)
        inner_ear.data.materials.append(mat_pink)

    # 3. Short Sturdy Corgi Legs with White Socks
    leg_coords = [
        (-0.12, 0.20, 0.14, 0.24), # Front Left
        (0.12, 0.20, 0.14, 0.24),  # Front Right
        (-0.13, -0.12, 0.14, 0.22), # Back Left
        (0.13, -0.12, 0.14, 0.22),  # Back Right
    ]
    for lx, ly, lz, lh in leg_coords:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.055, depth=lh, vertices=14, location=(lx, ly, lz))
        leg = bpy.context.active_object
        leg.data.materials.append(mat_sable)
        # White paw sock
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=10, radius=0.065, location=(lx, ly + 0.02, 0.04))
        paw = bpy.context.active_object
        paw.scale = (1.0, 1.2, 0.6)
        paw.data.materials.append(mat_white)

    # 4. Cute Plumy Tail (at back, -Y)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=10, radius=0.07, location=(0, -0.22, 0.38))
    tail = bpy.context.active_object
    tail.scale = (0.9, 1.1, 1.3)
    tail.data.materials.append(mat_white)

    # 5. Blue Collar & Silver Medallion
    bpy.ops.mesh.primitive_torus_add(major_radius=0.15, minor_radius=0.02, location=(0, 0.18, 0.40))
    collar = bpy.context.active_object
    collar.data.materials.append(mat_collar)

    bpy.ops.mesh.primitive_cylinder_add(radius=0.035, depth=0.012, vertices=14, location=(0, 0.32, 0.35))
    tag = bpy.context.active_object
    tag.rotation_euler = (math.pi * 0.5, 0, 0)
    tag.data.materials.append(mat_tag)

    export_glb("stylized_milo_hero.glb")

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================
if __name__ == "__main__":
    print("===================================================================")
    print("  BLENDER 5.3 STYLIZED ASSET GENERATION STARTED")
    print("===================================================================")
    build_ancient_oak()
    build_mountain_pine()
    build_river_boulders()
    build_hollow_log()
    build_bruno_hero()
    build_milo_hero()
    print("===================================================================")
    print("  ALL 6 GAME-READY STYLIZED ASSETS GENERATED SUCCESSFULLY!")
    print("===================================================================")
