import asyncio
from playwright.async_api import async_playwright

async def run():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        await page.goto("http://127.0.0.1:7865/")
        await page.wait_for_selector("text=Generate", timeout=10000)
        
        print("Filling prompt...")
        await page.fill('textarea[data-testid="textbox"]', "A simple test image of a cat")
        
        print("Clicking Generate...")
        await page.locator('#generate_button').click()
        
        print("Waiting for generation to finish...")
        await page.wait_for_selector('#generate_button:not(.hidden)', timeout=120000)
        print("Generation finished!")
        
        await browser.close()

if __name__ == "__main__":
    asyncio.run(run())
