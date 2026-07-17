import asyncio
from playwright.async_api import async_playwright

async def get_driver():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        print("Navigating to Nvidia...")
        await page.goto("https://www.nvidia.com/Download/index.aspx", timeout=60000)
        
        print("Waiting for product type...")
        await page.wait_for_selector("#selProductSeriesType")
        await page.select_option("#selProductSeriesType", label="Data Center / Tesla")
        await asyncio.sleep(1)
        
        print("Selecting P-Series...")
        await page.select_option("#selProductSeries", label="P-Series")
        await asyncio.sleep(1)
        
        print("Selecting Tesla P4...")
        await page.select_option("#selProductFamily", label="Tesla P4")
        await asyncio.sleep(1)
        
        print("Selecting Windows 11...")
        await page.select_option("#selOperatingSystem", label="Windows 11")
        await asyncio.sleep(1)
        
        print("Clicking Search...")
        await page.click("a.btn-search")
        
        print("Waiting for results...")
        await page.wait_for_selector("#lnkDwnldBtn")
        href = await page.get_attribute("#lnkDwnldBtn", "href")
        print(f"DOWNLOAD_LINK: {href}")
        
        await browser.close()

if __name__ == "__main__":
    asyncio.run(get_driver())
