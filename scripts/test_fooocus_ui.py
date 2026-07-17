import asyncio
import os
from playwright.async_api import async_playwright

async def run():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        await page.goto("http://127.0.0.1:7865/")
        await page.wait_for_selector("text=Generate", timeout=10000)
        
        print("Initial state")
        await page.screenshot(path="debug_01_initial.png")
        
        # Click "Input Image" checkbox at the bottom
        await page.locator('label:has-text("Input Image")').click()
        await page.wait_for_timeout(1000) # Wait for animation
        await page.screenshot(path="debug_02_input_image_checked.png")
        
        # Click "Image Prompt" tab
        # Gradio tabs usually have text inside a button
        await page.locator('button', has_text="Image Prompt").click()
        await page.wait_for_timeout(1000)
        await page.screenshot(path="debug_03_image_prompt_tab.png")
        
        # Click "Advanced" checkbox INSIDE the Image Prompt tab
        # It's usually a checkbox labeled "Advanced"
        # We need to distinguish it from the main "Advanced" checkbox at the bottom
        # Let's just click it if it's visible inside the Image Prompt area.
        # Actually, let's just find all labels with "Advanced" and click the last one (which is usually the Image Prompt one)
        advanced_labels = await page.locator('label:has-text("Advanced")').all()
        if len(advanced_labels) > 1:
            await advanced_labels[-1].click()
        await page.wait_for_timeout(1000)
        await page.screenshot(path="debug_04_advanced_checked.png")

        # Now select "PyraCanny" instead of "ImagePrompt"
        # Usually it's a radio button or dropdown
        # Let's try to click PyraCanny label
        pyracanny_label = page.locator('label', has_text="PyraCanny")
        if await pyracanny_label.count() > 0:
            await pyracanny_label.first.click()
            
        await page.wait_for_timeout(1000)
        await page.screenshot(path="debug_05_pyracanny_selected.png")
        
        print("Check the debug screenshots!")
        await browser.close()

if __name__ == "__main__":
    asyncio.run(run())
