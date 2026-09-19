import bpy
import json
import os
import random
import hashlib
import sys

# Paths
BASE_DIR = r"c:\Users\Tomek\.gemini\antigravity\scratch\window-garden-idle"
PLANTS_DIR = os.path.join(BASE_DIR, "assets", "generated_sprites", "plants")
PLANTERS_DIR = os.path.join(BASE_DIR, "assets", "generated_sprites", "planters")

os.makedirs(PLANTS_DIR, exist_ok=True)
os.makedirs(PLANTERS_DIR, exist_ok=True)

# Clear scene safely
for obj in bpy.data.objects:
    bpy.data.objects.remove(obj, do_unlink=True)

scene = bpy.context.scene

try:
    scene.render.engine = 'BLENDER_EEVEE_NEXT'
except Exception:
    scene.render.engine = 'BLENDER_EEVEE'

scene.render.resolution_x = 512
scene.render.resolution_y = 512
scene.render.film_transparent = True
scene.render.image_settings.color_mode = 'RGBA'

# Add Camera (Isometric / Orthographic)
# FIXED: Increased ortho_scale to 12.0 to prevent cropping of tall plants
bpy.ops.object.camera_add(location=(10, -10, 10), rotation=(0.959931, 0, 0.785398))
cam = bpy.context.object
cam.data.type = 'ORTHO'
cam.data.ortho_scale = 12.0
scene.camera = cam

# Add Lighting
bpy.ops.object.light_add(type='SUN', location=(5, -5, 10))
sun = bpy.context.object
sun.data.energy = 3.0
sun.data.angle = 0.5  # Soft shadows

# Add Fill Light
bpy.ops.object.light_add(type='AREA', location=(-5, 5, 5))
fill = bpy.context.object
fill.data.energy = 100.0
fill.data.size = 10.0

def create_material(name, color, roughness=0.85):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
    if bsdf:
        if 'Base Color' in bsdf.inputs:
            bsdf.inputs['Base Color'].default_value = color
        bsdf.inputs['Roughness'].default_value = roughness
        if 'Specular' in bsdf.inputs:
            bsdf.inputs['Specular'].default_value = 0.1
        elif 'Specular IOR Level' in bsdf.inputs:
            bsdf.inputs['Specular IOR Level'].default_value = 0.1
    return mat

mat_dirt = create_material("DirtMaterial", (0.1, 0.05, 0.02, 1.0))

# --- PLANTER GENERATION ---

def generate_planters():
    # 1. Terracotta
    for obj in bpy.data.objects:
        if obj.type == 'MESH': bpy.data.objects.remove(obj, do_unlink=True)
    mat_tc = create_material("Planter_terracotta", (0.7, 0.3, 0.2, 1.0), 0.9)
    # Tapered base
    bpy.ops.mesh.primitive_cone_add(radius1=0.8, radius2=1.2, depth=1.5, location=(0, 0, 0.75))
    base = bpy.context.object
    base.data.materials.append(mat_tc)
    bpy.ops.object.shade_smooth()
    # Thick Rim
    bpy.ops.mesh.primitive_cylinder_add(radius=1.3, depth=0.4, location=(0, 0, 1.5))
    rim = bpy.context.object
    rim.data.materials.append(mat_tc)
    bpy.ops.object.shade_smooth()
    # Dirt (inset)
    bpy.ops.mesh.primitive_cylinder_add(radius=1.15, depth=0.1, location=(0, 0, 1.4))
    dirt = bpy.context.object
    dirt.data.materials.append(mat_dirt)
    scene.render.filepath = os.path.join(PLANTERS_DIR, "planter_terracotta.png")
    bpy.ops.render.render(write_still=True)

    # 2. Ceramic White
    for obj in bpy.data.objects:
        if obj.type == 'MESH': bpy.data.objects.remove(obj, do_unlink=True)
    mat_cw = create_material("Planter_ceramic", (0.9, 0.9, 0.9, 1.0), 0.1) # Shiny
    # Sphere base
    bpy.ops.mesh.primitive_uv_sphere_add(radius=1.3, location=(0, 0, 0.8))
    base = bpy.context.object
    base.scale = (1.0, 1.0, 0.8)
    base.data.materials.append(mat_cw)
    bpy.ops.object.shade_smooth()
    # Dirt
    bpy.ops.mesh.primitive_cylinder_add(radius=1.1, depth=0.1, location=(0, 0, 1.4))
    dirt = bpy.context.object
    dirt.data.materials.append(mat_dirt)
    scene.render.filepath = os.path.join(PLANTERS_DIR, "planter_ceramic_white.png")
    bpy.ops.render.render(write_still=True)

    # 3. Dark Wood
    for obj in bpy.data.objects:
        if obj.type == 'MESH': bpy.data.objects.remove(obj, do_unlink=True)
    mat_dw = create_material("Planter_wood", (0.2, 0.1, 0.05, 1.0), 0.8)
    # Box base
    bpy.ops.mesh.primitive_cube_add(size=2.0, location=(0, 0, 1.0))
    base = bpy.context.object
    base.data.materials.append(mat_dw)
    # Add simple bevel modifier for wood edges
    mod = base.modifiers.new('Bevel', 'BEVEL')
    mod.width = 0.05
    # Dirt
    bpy.ops.mesh.primitive_cube_add(size=1.8, location=(0, 0, 1.95))
    dirt = bpy.context.object
    dirt.scale = (1.0, 1.0, 0.05)
    dirt.data.materials.append(mat_dirt)
    scene.render.filepath = os.path.join(PLANTERS_DIR, "planter_dark_wood.png")
    bpy.ops.render.render(write_still=True)

# --- PLANT GENERATION ---

def hsv_to_rgb(h, s, v):
    if s == 0.0: v*=255; return (v, v, v)
    i = int(h*6.) 
    f = (h*6.)-i; p,q,t = int(255*(v*(1.-s))), int(255*(v*(1.-s*f))), int(255*(v*(1.-s*(1.-f)))); v*=255; i%=6
    if i == 0: return (v, t, p)
    if i == 1: return (q, v, p)
    if i == 2: return (p, v, t)
    if i == 3: return (p, q, v)
    if i == 4: return (t, p, v)
    if i == 5: return (v, p, q)

def get_color(h, s, v):
    r,g,b = hsv_to_rgb(h, s, v)
    return (r/255.0, g/255.0, b/255.0, 1.0)

def generate_plant(seed_string, stage, force_tall=False, force_wide=False, force_bushy=False):
    seed_val = int(hashlib.md5(seed_string.encode()).hexdigest(), 16) % (10**8)
    random.seed(seed_val)
    
    plant_objs = []
    
    # Base params
    hue = random.uniform(0.15, 0.45) 
    sat = random.uniform(0.4, 0.9)
    val = random.uniform(0.2, 0.8)
    color = get_color(hue, sat, val)
    mat_plant = create_material(f"Plant_{seed_string}", color)
    
    num_stems = random.choice([1, 1, 1, 3, 5])
    leaf_shape = random.choice(['cube', 'sphere', 'cone']) 
    leaf_scale_x = random.uniform(0.2, 1.2)
    leaf_scale_y = random.uniform(0.2, 1.2)
    leaf_thickness = random.uniform(0.05, 0.3)
    droop_angle = random.uniform(-0.5, 1.0) 
    max_leaves_per_stem = random.randint(3, 15)
    max_stem_height = random.uniform(0.5, 3.0) # Reduced from 3.5 slightly
    
    # Force extremes for testing
    if force_tall:
        num_stems = 1
        max_stem_height = 4.0
        leaf_shape = 'cube'
        droop_angle = 1.0 # point up
    if force_wide:
        num_stems = 5
        leaf_scale_x = 2.0
        leaf_scale_y = 2.0
        max_stem_height = 1.0
        droop_angle = -0.5 # point out
    if force_bushy:
        num_stems = 7
        max_leaves_per_stem = 25
        leaf_shape = 'sphere'
        leaf_scale_x = 0.5
        leaf_scale_y = 0.5
        max_stem_height = 2.0

    scale_mult = 1.0
    if stage == "Sprout": scale_mult = 0.2; max_leaves_per_stem = max(1, max_leaves_per_stem // 4)
    elif stage == "Young": scale_mult = 0.5; max_leaves_per_stem = max(2, max_leaves_per_stem // 2)
    elif stage == "Mature": scale_mult = 1.0
    elif stage == "Blooming": scale_mult = 1.1

    for stem_idx in range(num_stems):
        stem_height = max_stem_height * scale_mult * random.uniform(0.8, 1.2)
        stem_offset_x = random.uniform(-0.5, 0.5) if num_stems > 1 else 0
        stem_offset_y = random.uniform(-0.5, 0.5) if num_stems > 1 else 0
        
        bpy.ops.mesh.primitive_cylinder_add(radius=0.08 * scale_mult, depth=stem_height, location=(stem_offset_x, stem_offset_y, 1.5 + stem_height/2))
        stem = bpy.context.object
        stem.data.materials.append(mat_plant)
        bpy.ops.object.shade_smooth()
        
        num_leaves = max(1, int(max_leaves_per_stem * random.uniform(0.8, 1.2)))
        
        for i in range(num_leaves):
            z_pos = 1.5 + (stem_height / num_leaves) * (i + 1) * random.uniform(0.8, 1.0)
            angle = random.uniform(0, 6.28)
            loc = (stem_offset_x, stem_offset_y, z_pos)
            
            if leaf_shape == 'cube': bpy.ops.mesh.primitive_cube_add(size=1.0, location=loc)
            elif leaf_shape == 'sphere': bpy.ops.mesh.primitive_uv_sphere_add(radius=0.5, location=loc)
            elif leaf_shape == 'cone': bpy.ops.mesh.primitive_cone_add(radius1=0.5, depth=1.0, location=loc)
                
            leaf = bpy.context.object
            leaf.scale = (leaf_scale_x * scale_mult, leaf_scale_y * scale_mult, leaf_thickness * scale_mult)
            
            dist = leaf_scale_x * scale_mult * 0.5
            leaf.location.x += dist * random.uniform(-1, 1)
            leaf.location.y += dist * random.uniform(-1, 1)
            
            leaf.rotation_euler = (droop_angle, random.uniform(-0.2, 0.2), angle)
            leaf.data.materials.append(mat_plant)
            
            if leaf_shape == 'cube':
                mod = leaf.modifiers.new("Subsurf", 'SUBSURF')
                mod.levels = 2
                
            bpy.context.view_layer.objects.active = leaf
            bpy.ops.object.shade_smooth()
            
            if stage == "Blooming" and i == num_leaves - 1 and random.random() > 0.3:
                bpy.ops.mesh.primitive_uv_sphere_add(radius=0.3 * scale_mult, location=(leaf.location.x, leaf.location.y, leaf.location.z + 0.2))
                flower = bpy.context.object
                mat_flower = create_material(f"Flower_{seed_string}", get_color(random.uniform(0, 1), 0.8, 0.9))
                flower.data.materials.append(mat_flower)
                bpy.ops.object.shade_smooth()
        
    return plant_objs

# Execute
print("Generating upgraded planters...")
generate_planters()

# TEST BATCH
tests = [
    ("test_extreme_tall", {"force_tall": True}),
    ("test_extreme_wide", {"force_wide": True}),
    ("test_extreme_bushy", {"force_bushy": True}),
    ("test_normal_aloe", {}),
    ("test_normal_fern", {})
]

print("Generating test modular plants...")
for name, kwargs in tests:
    # We will just render the 'Mature' stage for tests to check full size bounds
    for obj in bpy.data.objects:
        if obj.type == 'MESH': bpy.data.objects.remove(obj, do_unlink=True)
            
    generate_plant(name, "Mature", **kwargs)
    
    file_path = os.path.join(PLANTS_DIR, f"{name}.png")
    scene.render.filepath = file_path
    bpy.ops.render.render(write_still=True)
    print(f"Rendered test plant: {file_path}")

print("Test batch finished!")
