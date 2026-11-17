"""
Two Puppies: The Great Adventure — Stylized Forest Terrain & Monolith Generator
Generates sculpted terrain with natural riverbed, ravine, and cliff terraces, plus canine monoliths.
"""

import bpy
import bmesh
import math
import os

OUTPUT_DIR = os.path.abspath("src/assets/models")
os.makedirs(OUTPUT_DIR, exist_ok=True)

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    for block in bpy.data.meshes:
        bpy.data.meshes.remove(block)
    for block in bpy.data.materials:
        bpy.data.materials.remove(block)

def create_pbr_material(name, base_color, roughness=0.7, metallic=0.0, emission=None, emission_strength=1.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
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
# 1. SCULPTED ORGANIC FOREST TERRAIN
# ==============================================================================
def build_forest_terrain():
    clear_scene()
    mat_terrain = create_pbr_material("Mat_TerrainLoam", (0.22, 0.16, 0.10, 1.0), roughness=0.88)

    bm = bmesh.new()
    
    # Grid dimensions
    nx = 36  # X resolution
    nz = 54  # Z resolution
    x_min, x_max = -26.0, 26.0
    z_min, z_max = -48.0, 36.0

    verts_grid = []
    for j in range(nz):
        row = []
        tz = j / (nz - 1)
        z = z_min + tz * (z_max - z_min)
        
        for i in range(nx):
            tx = i / (nx - 1)
            x = x_min + tx * (x_max - x_min)
            
            # Base height calculation
            y = 0.0
            
            # 1. Valley Ridge walls on Left and Right (natural visual barriers)
            edge_dist = abs(x)
            if edge_dist > 14.0:
                y += ((edge_dist - 14.0) / 12.0) ** 1.8 * 6.5
                
            # 2. Mountain Stream Depression (z around 0.0)
            if abs(z) < 4.5:
                stream_factor = 1.0 - (abs(z) / 4.5)
                y -= stream_factor * 0.75
                
            # 3. Ravine Chasm (z around -16.0)
            if abs(z - (-16.0)) < 3.2:
                ravine_factor = 1.0 - (abs(z - (-16.0)) / 3.2)
                # Chasm is deeper in the center path
                if abs(x) < 8.0:
                    y -= ravine_factor * 2.8
                    
            # 4. Cliff Terrace Ascent (z from -26.0 to -34.0)
            if z < -24.0:
                climb_factor = min(1.0, (-24.0 - z) / 8.0)
                y += climb_factor * 3.2
                
            # 5. Ancient Shrine Plateau (z < -34.0)
            if z <= -34.0:
                y = 3.4
                if edge_dist > 12.0:
                    y += ((edge_dist - 12.0) / 14.0) * 4.0
                    
            # Add soft natural undulations
            undulation = math.sin(x * 0.4) * math.cos(z * 0.3) * 0.22
            y += undulation
            
            v = bm.verts.new((x, z, y))
            row.append(v)
        verts_grid.append(row)
        
    # Build quad faces
    for j in range(nz - 1):
        for i in range(nx - 1):
            v0 = verts_grid[j][i]
            v1 = verts_grid[j][i+1]
            v2 = verts_grid[j+1][i+1]
            v3 = verts_grid[j+1][i]
            bm.faces.new([v0, v1, v2, v3])
            
    bm.normal_update()
    
    mesh_terrain = bpy.data.meshes.new("TerrainMesh")
    bm.to_mesh(mesh_terrain)
    bm.free()
    
    obj_terrain = bpy.data.objects.new("ForestTerrain", mesh_terrain)
    # Convert Z-up to Godot coordinates (Blender Z -> Godot Y)
    # In Blender, vertices were built as (x, z, y) where z is along Godot Z, and y is height
    obj_terrain.data.materials.append(mat_terrain)
    bpy.context.collection.objects.link(obj_terrain)
    
    export_glb("stylized_forest_terrain.glb")

# ==============================================================================
# 2. STYLIZED CANINE SHRINE MONOLITH
# ==============================================================================
def build_canine_monolith():
    clear_scene()
    mat_stone = create_pbr_material("Mat_AncientStone", (0.35, 0.38, 0.35, 1.0), roughness=0.82)
    mat_rune = create_pbr_material("Mat_CanineRuneGlow", (0.2, 0.85, 1.0, 1.0), roughness=0.2, emission=(0.2, 0.85, 1.0, 1.0), emission_strength=4.0)

    # Monolith pillar base
    bpy.ops.mesh.primitive_cylinder_add(radius=0.9, depth=5.5, location=(0, 0, 2.75))
    pillar = bpy.context.active_object
    pillar.scale = (0.9, 1.2, 1.0)
    pillar.data.materials.append(mat_stone)

    # Stylized Canine Paw / Bone Carved Crest on Top
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.6, location=(0, 0, 5.8))
    crest = bpy.context.active_object
    crest.scale = (1.2, 0.7, 0.9)
    crest.data.materials.append(mat_stone)

    # Glowing Rune Crystal inlaid in the center
    bpy.ops.mesh.primitive_cube_add(size=0.6, location=(0, -0.65, 3.2))
    crystal = bpy.context.active_object
    crystal.scale = (0.7, 0.3, 1.5)
    crystal.rotation_euler = (0, 0, math.pi * 0.25)
    crystal.data.materials.append(mat_rune)

    export_glb("stylized_canine_monolith.glb")

if __name__ == "__main__":
    print("===================================================================")
    print("  BLENDER 5.3 TERRAIN & MONOLITH GENERATION STARTED")
    print("===================================================================")
    build_forest_terrain()
    build_canine_monolith()
    print("===================================================================")
    print("  TERRAIN & MONOLITH EXPORTED SUCCESSFULLY!")
    print("===================================================================")
