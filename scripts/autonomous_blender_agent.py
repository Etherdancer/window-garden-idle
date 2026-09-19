import os
import json
import base64
import requests
import subprocess
import time

OLLAMA_URL = "http://localhost:11434/api/generate"
BASE_DIR = r"c:\Users\Tomek\.gemini\antigravity\scratch\window-garden-idle"
JSON_PATH = os.path.join(BASE_DIR, "all_plants.json")
PLANTS_DIR = os.path.join(BASE_DIR, "assets", "generated_sprites", "plants")
TEMP_SCRIPT = os.path.join(BASE_DIR, "scripts", "temp_blender_script.py")

BLENDER_EXE = r"C:\Program Files\Blender Foundation\Blender 5.1\blender.exe"

os.makedirs(PLANTS_DIR, exist_ok=True)

def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

def check_with_llava(image_path, prompt):
    img_b64 = encode_image(image_path)
    try:
        res = requests.post(OLLAMA_URL, json={
            "model": "llava",
            "prompt": prompt,
            "images": [img_b64],
            "stream": False
        })
        if res.status_code == 200:
            return res.json().get("response", "").strip().lower()
        return "error"
    except Exception as e:
        return f"error: {e}"

BASE_SCRIPT = """import bpy
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
"""

def generate_blender_code(plant_name, stage, feedback=""):
    prompt = f"""You are an expert Blender Python developer. Write procedurally generated 3D model code for a '{plant_name}' at the '{stage}' growth stage. 
Do not write a function, just write the raw top-level `bpy.ops...` commands. 
Do not use any external files. Use ONLY basic mesh primitives.
CRITICAL: In Blender 5.1, `primitive_cube_add` uses the `size=` keyword argument. It DOES NOT use `radius=`. Only spheres and cylinders use `radius=`.
CRITICAL: You MUST wrap your code between `# START CODE` and `# END CODE`. Do not output markdown formatting like ```python.

{feedback}
"""
    try:
        res = requests.post(OLLAMA_URL, json={
            "model": "llama3:latest",
            "prompt": prompt,
            "stream": False
        })
        if res.status_code == 200:
            raw_text = res.json().get("response", "").strip()
            
            if "# START CODE" in raw_text and "# END CODE" in raw_text:
                code = raw_text.split("# START CODE")[1].split("# END CODE")[0].strip()
            elif "```python" in raw_text:
                code = raw_text.split("```python")[1].split("```")[0].strip()
            elif "```" in raw_text:
                parts = raw_text.split("```")
                if len(parts) >= 3:
                    code = parts[1].strip()
                    if code.startswith("python"):
                        code = code[6:].strip()
            else:
                code = raw_text
                
            return code
        return ""
    except Exception as e:
        print(e)
        return ""

def run():
    with open(JSON_PATH, "r") as f:
        plants = json.load(f)
        
    stages = ["Seed", "Sprout", "Young", "Mature", "Blooming"]
    
    for plant_name in plants:
        safe_name = "".join([c for c in plant_name if c.isalpha() or c.isdigit()]).lower()
        print(f"--- Processing {plant_name} ---")
        
        for stage in stages:
            out_path = os.path.join(PLANTS_DIR, f"{safe_name}_{stage.lower()}.png")
            if os.path.exists(out_path):
                continue
                
            success = False
            attempts = 0
            feedback = ""
            
            while not success and attempts < 3:
                attempts += 1
                print(f"[{plant_name} - {stage}] Attempt {attempts}")
                
                # 1. Ask LLM to write Blender script
                print("Generating Python geometry code...")
                code = generate_blender_code(plant_name, stage, feedback)
                
                if not code:
                    print("Failed to get code from LLM.")
                    continue
                    
                # Assemble full script
                full_code = BASE_SCRIPT + "\n# --- LLM CODE ---\n" + code + f"\n# --- END LLM ---\nscene.render.filepath = r'{out_path}'\nbpy.ops.render.render(write_still=True)\n"
                
                with open(TEMP_SCRIPT, "w", encoding="utf-8") as f:
                    f.write(full_code)
                    
                # 2. Run Blender
                print("Running Blender to render...")
                result = subprocess.run([BLENDER_EXE, "-b", "-P", TEMP_SCRIPT], capture_output=True, text=True)
                
                if not os.path.exists(out_path):
                    print("Blender failed to produce image. Error:")
                    print(result.stderr)
                    feedback = "PREVIOUS SCRIPT FAILED. Error: " + result.stderr[-500:]
                    continue
                    
                # 3. Ask LLaVA to verify
                print("Verifying accuracy with LLaVA...")
                check_prompt = f"Answer strictly 'yes' or 'no'. Does this image clearly and accurately represent the specific real-world plant '{plant_name}' at the '{stage}' stage?"
                
                llava_res = check_with_llava(out_path, check_prompt)
                print(f"LLaVA: {llava_res}")
                
                if "yes" in llava_res[:10]:
                    print("PASSED!")
                    success = True
                else:
                    print("REJECTED. Retrying...")
                    critique_prompt = f"This image failed. What exactly is wrong with the geometry or color to represent a '{plant_name}'?"
                    critique = check_with_llava(out_path, critique_prompt)
                    feedback = "PREVIOUS SCRIPT WAS INACCURATE. The art director said: " + critique
                    try:
                        os.remove(out_path)
                    except:
                        pass
                        
if __name__ == "__main__":
    run()
