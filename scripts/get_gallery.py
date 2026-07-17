import asyncio
from playwright.async_api import async_playwright

async def run():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        await page.goto("http://127.0.0.1:7865/")
        await page.wait_for_selector("text=Generate", timeout=10000)
        
        # Click gallery image to see if any are there
        imgs = await page.locator('div[data-testid="image"] img').all()
        for i, img in enumerate(imgs):
            src = await img.get_attribute("src")
            print(f"Image {i}: {src[:100]}...")
            
        await browser.close()

if __name__ == "__main__":
    asyncio.run(run())
