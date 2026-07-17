import asyncio
from playwright.async_api import async_playwright

async def run():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        await page.goto("http://127.0.0.1:7865/")
        await page.wait_for_timeout(2000)
        await page.screenshot(path="fooocus_current_state.png")
        print("Screenshot saved to fooocus_current_state.png")
        await browser.close()

if __name__ == "__main__":
    asyncio.run(run())
