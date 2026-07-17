from gradio_client import Client, file
import json
import os
import asyncio
import sys
sys.stdout.reconfigure(encoding='utf-8')

TEMPLATES_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "assets", "templates"))
OUTPUT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "assets", "images", "frames"))

def generate_via_client(location, prompt):
    client = Client("http://127.0.0.1:7865/")
    
    # Load defaults
    defaults = json.load(open(os.path.join(os.path.dirname(__file__), "..", "defaults.json"), encoding="utf-8"))
    
    # The API endpoint is unnamed endpoint 67 (or whichever accepts 152 params)
    # Actually, gradio_client uses fn_index
    args = [d[1] for d in defaults]
    
    # Override prompt (Index 1)
    args[1] = prompt
    
    # Override Image Prompt inputs for PyraCanny
    # Index 80: Image
    # Index 81: StopAt
    # Index 82: Weight
    # Index 83: Type
    args[80] = os.path.join(TEMPLATES_DIR, "beam.png")
    args[81] = 0.5 # StopAt
    args[82] = 1.0 # Weight
    args[83] = "PyraCanny" # Type
    
    # Checkbox for mixing image prompt
    args[56] = True # Mixing Image Prompt and Vary/Upscale
    args[57] = True # Mixing Image Prompt and Inpaint
    args[30] = True # Input Image checkbox
    
    # Wait, the number of args might be 152.
    print(f"Calling Fooocus for {location} with {len(args)} parameters...")
    try:
        result = client.predict(*args, fn_index=67)
        print(f"Result: {result}")
    except Exception as e:
        import traceback
        traceback.print_exc()
        print(f"Error: {e}")

if __name__ == "__main__":
    generate_via_client("tokyo", "a beautiful traditional tokyo wooden window frame beam")
