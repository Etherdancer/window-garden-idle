import sys
import time
import os
import json
import base64
import requests
import random
import glob
from PIL import Image
from rembg import remove

OLLAMA_URL = "http://localhost:11434/api/generate"
COMFY_URL = "http://127.0.0.1:8188/prompt"
OUTPUTS_DIR = r"C:\ComfyUI\output"
SPRITES_DIR = os.path.join(OUTPUTS_DIR, "Sprites")

if not os.path.exists(SPRITES_DIR):
    os.makedirs(SPRITES_DIR)

stages = {
    "1": "a tiny newly sprouted {plant} seedling with just two small leaves",
    "2": "a young {plant} with a few small leaves",
    "3": "a cut leafy branch of a medium-sized, bushy {plant} with actively growing foliage. The branch is visibly severed at the bottom, just a bare green stem floating in empty space. ONLY FOLIAGE. NO SOIL, NO PLANTER",
    "4": "a colossal cut leafy branch of a massive {plant} specimen with incredibly lush sprawling foliage. The branch is visibly severed at the bottom, just a bare green stem floating in empty space. ONLY FOLIAGE. NO SOIL, NO PLANTER",
    "5": "an impossibly giant, dense cut leafy branch of an overgrown {plant}. The branch is visibly severed at the bottom, just a bare green stem floating in empty space. ONLY FOLIAGE. NO SOIL, NO PLANTER"
}

base_prompt = "A breathtaking, realistic anime visual style illustration of {desc}, Studio Ghibli, Makoto Shinkai style, highly detailed foliage, beautiful cinematic lighting, soft warm colors, completely isolated on solid white background, high quality, masterpiece."
negative_prompt = "pot, planter, vase, container, dirt, soil, ground, floor, roots, shadow, drop shadow, base, stand, box, block, background, environment, scenery, table, surface, watermark, text"

def get_comfy_workflow(prompt, neg_prompt):
    return {
      "3": {"class_type": "KSampler", "inputs": {"seed": random.randint(1, 1000000000), "steps": 25, "cfg": 7, "sampler_name": "euler_ancestral", "scheduler": "normal", "denoise": 1, "model": ["4", 0], "positive": ["6", 0], "negative": ["7", 0], "latent_image": ["5", 0]}},
      "4": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": "juggernautXL_v8Rundiffusion.safetensors"}},
      "5": {"class_type": "EmptyLatentImage", "inputs": {"width": 1024, "height": 1024, "batch_size": 1}},
      "6": {"class_type": "CLIPTextEncode", "inputs": {"text": prompt, "clip": ["4", 1]}},
      "7": {"class_type": "CLIPTextEncode", "inputs": {"text": neg_prompt, "clip": ["4", 1]}},
      "8": {"class_type": "VAEDecode", "inputs": {"samples": ["3", 0], "vae": ["4", 2]}},
      "9": {"class_type": "SaveImage", "inputs": {"filename_prefix": "plant_gen", "images": ["8", 0]}}
    }

def generate_image_comfy(prompt, neg_prompt):
    workflow = get_comfy_workflow(prompt, neg_prompt)
    try:
        res = requests.post(COMFY_URL, json={"prompt": workflow})
        if res.status_code == 200:
            prompt_id = res.json().get("prompt_id")
            # Poll for completion
            while True:
                time.sleep(2)
                hist_res = requests.get(f"http://127.0.0.1:8188/history/{prompt_id}")
                hist = hist_res.json()
                if prompt_id in hist:
                    outputs = hist[prompt_id].get("outputs", {})
                    for k, v in outputs.items():
                        if "images" in v:
                            filename = v["images"][0]["filename"]
                            return os.path.join(OUTPUTS_DIR, filename)
        return None
    except Exception as e:
        print(f"ComfyUI Error: {e}")
        return None

def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

def check_with_llava(image_path, prompt):
    img_b64 = encode_image(image_path)
    try:
        res = requests.post(OLLAMA_URL, json={"model": "llava", "prompt": prompt, "images": [img_b64], "stream": False})
        if res.status_code == 200:
            return res.json().get("response", "").strip().lower()
    except:
        pass
    return "error"

def get_clean_botanical_desc(plant_name):
    try:
        res = requests.post(OLLAMA_URL, json={"model": "llama3:latest", "prompt": f"Output ONLY the physical description of the leaves and stem of {plant_name}. Limit 10 words. Begin exactly with 'plant with '.", "stream": False})
        if res.status_code == 200:
            ans = res.json().get("response", "").strip()
            if ":" in ans: ans = ans.split(":")[-1].strip()
            ans = ans.replace('"', '').replace("'", "")
            if not ans.startswith("plant"): ans = f"plant with {ans}"
            return ans
    except:
        pass
    return f"plant with leaves like {plant_name}"

def process_sprite(input_image_path, out_path):
    try:
        input_image = Image.open(input_image_path)
        output_image = remove(input_image)
        bbox = output_image.getbbox()
        if bbox: output_image = output_image.crop(bbox)
        output_image.thumbnail((512, 512), Image.Resampling.LANCZOS)
        output_image.save(out_path, "PNG")
        return True
    except Exception as e:
        print(f"Process Error: {e}")
        return False

def run():
    with open("all_plants.json", "r") as f: plants = json.load(f)
    
    for plant_name in plants[:1]:
        plant_name = plant_name.replace("\\", "")
        plant_id = plant_name.replace(" ", "").replace("/", "").replace("(", "").replace(")", "")
        print(f"--- Processing {plant_name} ---")
        
        visual_desc = get_clean_botanical_desc(plant_name)
        print(f"Botanical desc: {visual_desc}")
        
        for s_name, s_desc in stages.items():
            key = f"{plant_id}_{s_name}"
            out_path = os.path.join(SPRITES_DIR, f"{key}.png")
            if os.path.exists(out_path): continue
                
            desc = s_desc.format(plant=visual_desc)
            full_prompt = base_prompt.format(desc=desc)
            
            success = False
            attempts = 0
            while not success and attempts < 5:
                attempts += 1
                print(f"[{key}] Generating Attempt {attempts}...")
                
                raw_img = generate_image_comfy(full_prompt, negative_prompt)
                if not raw_img or not os.path.exists(raw_img):
                    continue
                
                print(f"[{key}] LLava checking raw image...")
                art_prompt = "You are an Art Director. Answer ONLY 'yes' or 'no'. Does this beautifully painted plant perfectly match the description? And is it completely isolated on a white background with ZERO pots, planters, dirt, bases, shadows, watermarks or other unwanted objects?"
                raw_check = check_with_llava(raw_img, art_prompt)
                print(f"[{key}] Raw check: {raw_check}")
                
                if not raw_check.startswith("yes"):
                    print(f"[{key}] Rejected. Retrying...")
                    os.remove(raw_img)
                    continue
                    
                print(f"[{key}] Cropping image...")
                if not process_sprite(raw_img, out_path): continue
                    
                print(f"[{key}] LLava checking sprite...")
                sprite_check = check_with_llava(out_path, "Answer ONLY 'yes' or 'no'. Is this image ONLY a perfectly isolated plant sprite with NO floating artifacts, NO pieces of a pot, and NO dirt?")
                print(f"[{key}] Sprite check: {sprite_check}")
                
                if not sprite_check.startswith("yes"):
                    print(f"[{key}] Sprite rejected. Retrying...")
                    os.remove(out_path)
                    os.remove(raw_img)
                    continue
                    
                print(f"[{key}] PASSED! Saved final sprite.")
                success = True

if __name__ == "__main__":
    run()
