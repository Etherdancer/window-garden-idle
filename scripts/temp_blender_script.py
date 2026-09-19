import bpy
import random
import math

for obj in bpy.data.objects:
    if obj.type == 'MESH':
        bpy.data.objects.remove(obj, do_unlink=True)

scene = bpy.context.scene
try:
    scene.render.engine = 'BLENDER_EEVEE_NEXT'
except:
    scene.render.engine = 'BLENDER_EEVEE'
scene.render.resolution_x = 512
scene.render.resolution_y = 512
scene.render.film_transparent = True
scene.render.image_settings.color_mode = 'RGBA'

bpy.ops.object.camera_add(location=(10, -10, 10), rotation=(0.959931, 0, 0.785398))
cam = bpy.context.object
cam.data.type = 'ORTHO'
cam.data.ortho_scale = 8.0
scene.camera = cam

bpy.ops.object.light_add(type='SUN', location=(5, -5, 10))
bpy.context.object.data.energy = 3.0
bpy.ops.object.light_add(type='AREA', location=(-5, 5, 5))
bpy.context.object.data.energy = 100.0

# --- LLM CODE ---
bpy.ops.mesh.primitive_cylinder_add(location=(0, 0, 0), radius=1.5, depth=3)
bpy.ops.mesh.primitive_sphere_add(location=(-2, 0, 0), radius=1)
bpy.ops.mesh.primitive_cube_add(location=(0, -2, 0), size=1.5)
bpy.ops.mesh.extrude_region()
bpy.ops.transform.rotate(value=math.pi/6, center=(0, 0, 0))
bpy.ops.transform.translate(location=(-2, 0, 0))
bpy.ops.mesh.primitive_cylinder_add(location=(0, 0, 0), radius=1.5, depth=3)
bpy.ops.mesh.primitive_sphere_add(location=(0, -2, 0), radius=1)
bpy.ops.transform.rotate(value=-math.pi/6, center=(0, 0, 0))
bpy.ops.mesh.dissolve()
# --- END LLM ---
scene.render.filepath = r'c:\Users\Tomek\.gemini\antigravity\scratch\window-garden-idle\assets\generated_sprites\plants\africanviolet_mature.png'
bpy.ops.render.render(write_still=True)
