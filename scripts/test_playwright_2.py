import asyncio
from playwright.async_api import async_playwright

async def run():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        print("Navigating to Fooocus...")
        await page.goto("http://127.0.0.1:7865/")
        print("Waiting for load...")
        await page.wait_for_selector("text=Generate", timeout=10000)
        
        print("Clicking Input Image...")
        await page.locator('label:has-text("Input Image")').click()
        await page.wait_for_timeout(1000)
        
        await page.screenshot(path="fooocus_input_image.png")
        print("Screenshot saved to fooocus_input_image.png")
        await browser.close()

if __name__ == "__main__":
    asyncio.run(run())
