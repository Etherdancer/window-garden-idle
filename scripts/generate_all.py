import asyncio
import os
import shutil
import base64
from playwright.async_api import async_playwright

LOCATIONS = [
    "tokyo"
]

ASSETS_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "assets", "images", "frames"))
TEMPLATES_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "assets", "templates"))

async def generate_asset(page, location, asset_type, template_name, prompt):
    print(f"Generating {asset_type} for {location}...")
    
    # 1. Setup UI state for PyraCanny (only needed once per run, but we can do it safely here)
    try:
        # Check if Input Image is already checked
        is_checked = await page.locator('input[type="checkbox"]').first.is_checked()
        if not is_checked:
            await page.locator('label:has-text("Input Image")').click()
            await page.wait_for_timeout(500)
            await page.locator('button', has_text="Image Prompt").click()
            await page.wait_for_timeout(500)
            advanced_labels = await page.locator('label:has-text("Advanced")').all()
            if len(advanced_labels) > 1:
                await advanced_labels[-1].click()
            await page.wait_for_timeout(500)
            
            pyracanny_label = page.locator('label', has_text="PyraCanny")
            if await pyracanny_label.count() > 0:
                await pyracanny_label.first.click()
            await page.wait_for_timeout(500)
    except Exception as e:
        print("UI Setup error (maybe already set up):", e)

    # 2. Fill Prompt
    await page.fill('textarea[data-testid="textbox"]', prompt)
    
    # 3. Upload template image
    # For Fooocus, we can just locate all file inputs and set them all.
    file_inputs = await page.locator('input[type="file"]').element_handles()
    for fi in file_inputs:
        try:
            await fi.set_input_files(os.path.join(TEMPLATES_DIR, template_name))
        except Exception as e:
            print("Failed to upload to an input:", e)
    await page.wait_for_timeout(2000)

    # 3. Click Generate
    print("Clicking Generate...")
    await page.locator('#generate_button').click()
    
    # 4. Wait for generation to finish. 
    print("Waiting for generation to finish...")
    
    # First, wait for the generation to actually start. 
    # Fooocus disables the #generate_button and shows a Stop button. 
    # Wait until the 'Generate' text is no longer visible OR the button has class 'hidden'
    try:
        await page.wait_for_selector('button:has-text("Stop")', timeout=5000)
    except:
        pass
        
    # Now, wait until the Generate button becomes visible and has the word Generate
    # Since Fooocus might replace the DOM element, we wait for a button with id 'generate_button' that does not have 'hidden' class
    print("Waiting for Generate button to reappear...")
    try:
        await page.wait_for_function('''
            () => {
                const btn = document.querySelector('#generate_button');
                return btn && !btn.classList.contains('hidden') && btn.innerText.includes('Generate') && !btn.disabled;
            }
        ''', timeout=180000)
    except Exception as e:
        print(f"Timeout waiting for Generate! Taking screenshot...")
        await page.screenshot(path=f"debug_timeout_{location}.png")
        raise e
    
    # 5. Extract image.
    print("Extracting image...")
    # Wait a bit for the gallery to update
    await page.wait_for_timeout(2000)
    img_element = page.locator('div[data-testid="image"] img').last
    await img_element.wait_for(state="visible", timeout=10000)
    
    # Get the image blob URL or base64
    src = await img_element.get_attribute('src')
    
    # Playwright can't directly download blob:// easily, but we can evaluate a fetch script, or just use the local path if it's a file path
    # Fooocus returns something like /file=outputs/...
    
    output_path = os.path.join(ASSETS_DIR, f"{location}_{asset_type}_raw.png")
    
    if src.startswith('http') or src.startswith('/'):
        # It's an HTTP URL served by Gradio. We can fetch it.
        url = src if src.startswith('http') else f"http://127.0.0.1:7865{src}"
        # We can use requests or page.evaluate to fetch
        js_fetch = f"""
        async () => {{
            const resp = await fetch('{url}');
            const blob = await resp.blob();
            const buffer = await blob.arrayBuffer();
            return Array.from(new Uint8Array(buffer));
        }}
        """
        img_bytes = await page.evaluate(js_fetch)
        with open(output_path, "wb") as f:
            f.write(bytearray(img_bytes))
    else:
        # Base64
        data = src.split(',')[1]
        with open(output_path, "wb") as f:
            f.write(base64.b64decode(data))
            
    print(f"Saved {output_path}")

async def run():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        
        print("Navigating to Fooocus...")
        await page.goto("http://127.0.0.1:7865/")
        await page.wait_for_selector("text=Generate", timeout=10000)
        
        # Setup the UI state ONCE
        print("Setting up UI state...")
        # 1. Click Input Image checkbox
        await page.locator('label:has-text("Input Image")').click()
        await page.wait_for_timeout(500)
        
        # 2. Click Image Prompt tab
        await page.locator('button:has-text("Image Prompt")').click()
        await page.wait_for_timeout(500)
        
        # 3. Click Advanced (might be multiple, so we pick the second one which is usually for Image Prompt)
        # Actually, let's just click the checkbox label for Advanced inside the Image Prompt area.
        # It says "Advanced"
        advanced_labels = await page.locator('label:has-text("Advanced")').all()
        if len(advanced_labels) > 1:
            await advanced_labels[1].click()
        else:
            await advanced_labels[0].click()
        await page.wait_for_timeout(500)
        
        # 4. We need to set PyraCanny.
        # It's a radio button or dropdown. "ImagePrompt" is default. "PyraCanny", "CPDI", "FaceSwap".
        # In Fooocus it's radio buttons or dropdown. Let's assume it's a dropdown or radio.
        # Wait, if we don't set PyraCanny, the default ImagePrompt might still work well enough for a frame!
        # But let's try to set it.
        pyracanny_radio = page.locator('label:has-text("PyraCanny")')
        if await pyracanny_radio.count() > 0:
            await pyracanny_radio.first.click()
            
        # Optional: Set Aspect Ratio, etc? The template is 1024x1024. Fooocus default is 1152x896.
        # Let's set the aspect ratio to 1024x1024 if possible, or leave default.
        
        # Loop over locations
        for loc in LOCATIONS:
            prompt_beam = f"a beautiful traditional {loc} wooden window frame beam, high quality, isolated on white background"
            await generate_asset(page, loc, "beam", "beam.png", prompt_beam)
            
            prompt_bench = f"a beautiful traditional {loc} wooden window sill bench, high quality, isolated on white background"
            await generate_asset(page, loc, "bench", "bench.png", prompt_bench)

        await browser.close()

if __name__ == "__main__":
    asyncio.run(run())
