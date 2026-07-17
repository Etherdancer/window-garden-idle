import asyncio
from playwright.async_api import async_playwright

async def run():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        
        print("Navigating to 551.78 driver page...")
        await page.goto("https://www.nvidia.com/download/driverResults.aspx/222350/en-us/")
        
        # Click the download button to go to the agreement page
        await page.click("#btnDwnld")
        await page.wait_for_load_state("networkidle")
        
        # Now get the actual download button href
        btn = await page.locator("#btnDwnld").get_attribute("href")
        
        if btn and btn.startswith("//"):
            btn = "https:" + btn
        
        print(f"Download URL: {btn}")
        await browser.close()

if __name__ == "__main__":
    asyncio.run(run())
