import sys
import time
import os
import glob
import base64
import json
import requests
from playwright.sync_api import sync_playwright
from PIL import Image
from rembg import remove

OLLAMA_URL = "http://localhost:11434/api/generate"
OUTPUTS_DIR = r"C:\Fooocus\Fooocus_win64_2-5-0\Fooocus\outputs"
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

base_prompt = "A breathtaking, realistic anime visual style illustration of {desc}, Studio Ghibli, Makoto Shinkai style, highly detailed foliage, beautiful cinematic lighting, soft warm colors, completely isolated on white background, high quality, masterpiece."
negative_prompt = "pot, planter, vase, container, dirt, soil, ground, floor, roots, shadow, drop shadow, base, stand, box, block, background, environment, scenery, table, surface"

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
            ans = res.json().get("response", "").strip().lower()
            return ans
        return "error"
    except Exception as e:
        return f"error: {e}"

def get_clean_botanical_desc(plant_name):
    prompt = f"You are a strict data-to-text converter. Output NOTHING but the physical description of the leaves and stem of {plant_name}. Limit to 10 words. Do not use quotes. Begin exactly with 'plant with '."
    try:
        res = requests.post(OLLAMA_URL, json={
            "model": "llama3:latest",
            "prompt": prompt,
            "stream": False
        })
        if res.status_code == 200:
            ans = res.json().get("response", "").strip()
            # Clean up potential chatty prefixes if the model ignores instructions
            if ":" in ans:
                ans = ans.split(":")[-1].strip()
            ans = ans.replace('"', '').replace("'", "")
            if not ans.startswith("plant with"):
                ans = f"plant with {ans}"
            return ans
        return f"plant with leaves like {plant_name}"
    except Exception:
        return f"plant with leaves like {plant_name}"

def process_sprite(input_image_path, out_path):
    try:
        input_image = Image.open(input_image_path)
        output_image = remove(input_image)
        bbox = output_image.getbbox()
        if bbox:
            output_image = output_image.crop(bbox)
        output_image.thumbnail((512, 512), Image.Resampling.LANCZOS)
        output_image.save(out_path, "PNG")
        return True
    except Exception as e:
        print(f"Failed to process {input_image_path}: {e}")
        return False

def run():
    with open("all_plants.json", "r") as f:
        plants = json.load(f)
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        
        try:
            page.goto("http://127.0.0.1:7865", timeout=60000)
            page.wait_for_selector('textarea')
        except Exception:
            print("Failed to connect to Fooocus")
            return
            
        try:
            cb = page.get_by_role("checkbox", name="Advanced").first
            if not cb.is_checked():
                cb.check(force=True)
                time.sleep(0.5)
        except:
            pass
            
        prompt_box = page.locator("textarea[placeholder='Type prompt here or paste parameters.']").first
        neg_prompt_box = page.locator("textarea[placeholder='Type prompt here.']").first
        generate_btn = page.locator("button:has-text('Generate')").first
        
        for plant_name in plants:
            plant_name = plant_name.replace("\\", "")
            plant_id = plant_name.replace(" ", "").replace("/", "").replace("(", "").replace(")", "")
            print(f"--- Processing {plant_name} ---")
            
            visual_desc = get_clean_botanical_desc(plant_name)
            print(f"Botanical description: {visual_desc}")
            
            for s_name, s_desc in stages.items():
                key = f"{plant_id}_{s_name}"
                out_path = os.path.join(SPRITES_DIR, f"{key}.png")
                
                if os.path.exists(out_path):
                    continue
                    
                desc = s_desc.format(plant=visual_desc)
                full_prompt = base_prompt.format(desc=desc)
                
                attempts = 0
                success = False
                
                while not success and attempts < 5:
                    attempts += 1
                    print(f"[{key}] Generating Attempt {attempts}...")
                    prompt_box.fill("")
                    neg_prompt_box.fill("")
                    time.sleep(0.5)
                    prompt_box.fill(full_prompt)
                    neg_prompt_box.fill(negative_prompt)
                    time.sleep(0.5)
                    
                    existing_files = set(glob.glob(os.path.join(OUTPUTS_DIR, "*", "*.png")))
                    
                    page.locator("button#generate_button:not([disabled])").wait_for(timeout=360000, state="visible")
                    generate_btn.click()
                    time.sleep(2)
                    try:
                        page.locator("button#generate_button:not([disabled])").wait_for(timeout=360000, state="visible")
                    except:
                        pass
                    time.sleep(10) # wait for flush
                    
                    current_files = set(glob.glob(os.path.join(OUTPUTS_DIR, "*", "*.png")))
                    new_files = current_files - existing_files
                    
                    if not new_files:
                        print("No file generated.")
                        continue
                        
                    raw_img = sorted(list(new_files), key=os.path.getmtime)[-1]
                    
                    print(f"[{key}] LLava checking raw image for art direction...")
                    art_director_prompt = (
                        f"You are checking an AI generated image of a plant. "
                        f"Your ONLY job is to detect unwanted artifacts like pots, planters, vases, ground dirt, watermarks, or text. "
                        f"Answer ONLY 'yes' if the image is just a plant/foliage with NONE of those bad elements. "
                        f"Answer 'no' if you see a pot, a vase, text, a watermark, or ground dirt."
                    )
                    raw_check = check_with_llava(raw_img, art_director_prompt)
                    print(f"[{key}] LLaVA raw check: {raw_check}")
                    
                    if not raw_check.startswith("yes"):
                        print(f"[{key}] Rejected by Art Director LLava. Retrying...")
                        try:
                            os.remove(raw_img)
                        except:
                            pass
                        continue
                        
                    print(f"[{key}] Cropping image...")
                    if not process_sprite(raw_img, out_path):
                        continue
                        
                    print(f"[{key}] LLava checking final sprite...")
                    sprite_check = check_with_llava(out_path, "Answer ONLY 'yes' or 'no'. Is this image a perfectly isolated, transparent plant sprite with NO floating artifacts, NO pieces of a pot, and NO dirt?")
                    print(f"[{key}] LLaVA sprite check: {sprite_check}")
                    
                    if not sprite_check.startswith("yes"):
                        print(f"[{key}] Rejected by LLava (Artifacts in sprite). Retrying...")
                        try:
                            os.remove(out_path)
                            os.remove(raw_img)
                        except:
                            pass
                        continue
                        
                    print(f"[{key}] PASSED! Saved final sprite.")
                    success = True
                    
        browser.close()

if __name__ == "__main__":
    run()
