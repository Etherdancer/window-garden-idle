import requests
import json
import base64
import os
import time

def encode_image(filepath):
    with open(filepath, "rb") as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode('utf-8')

def generate_fooocus_image(prompt, template_path, output_path):
    print(f"Generating image for {prompt} using template {template_path}...")
    url = "http://127.0.0.1:7865/run/predict"
    
    # We attempt to construct the massive 120-element array for Fooocus fn_index=67.
    # This is highly fragile and dependent on the exact version of Fooocus.
    # A much better alternative is the Fooocus-API fork (port 8888).
    
    # Placeholder array filled with Nones. We inject the prompt and image where typical.
    payload = {
        "fn_index": 67,
        "data": [
            False, # generate_image_grid_for_each_batch
            prompt, # prompt
            "", # negative_prompt
            [], # selected_styles
            "Speed", # performance
            "1024x1024", # aspect_ratios
            1, # image_number
            "png", # output_format
            -1, # seed
            False, # read_wildcards_in_order
            2.0, # image_sharpness
            7.0, # guidance_scale
            False, # base_model_sdxl_only
            "None", # refiner_sdxl_or_sd_15
            0.5, # refiner_switch_at
            False, "None", 1.0, # lora 1
            False, "None", 1.0, # lora 2
            False, "None", 1.0, # lora 3
            False, "None", 1.0, # lora 4
            False, "None", 1.0, # lora 5
            None, # input_image
            "", # parameter_212
            "Disabled", # upscale_or_variation
            None, # image
            "Left", # outpaint_direction
            None, # image
            "", # inpaint_additional_prompt
            None, # mask_upload
            False, False, False, False, 
            1.5, 0.8, 0.3, True, 0, "dpmpp_2m_sde_gpu", "karras", "Default (model)", 
            -1, -1, -1, -1, -1, -1, False, False, False, False, 100, 200, "None", 0.25, 
            False, 1.0, 1.5, 0.5, 0.5, False, False, "None", 1.0, 1.0, False, False, 0, False, False, "fooocus",
            # Image Prompt section (PyraCanny)
            encode_image(template_path), 1.0, 1.0, "ImagePrompt", # image 1
            None, 0.5, 0.6, "ImagePrompt", # image 2
            None, 0.5, 0.6, "ImagePrompt", # image 3
            None, 0.5, 0.6, "ImagePrompt", # image 4
            False, 0, False, None, False, "Disabled", "ImagePrompt, VAE Encode, Generate", "", False, "", "", "", "u2net", "full", "vit_b", 0.5, 0.5, 0, False, "None", 1.0, 1.0, 0, False, False, "", "", "", "u2net", "full", "vit_b", 0.5, 0.5, 0, False, "None", 1.0, 1.0, 0, False, False, "", "", "", "u2net", "full", "vit_b", 0.5, 0.5, 0, False, "None", 1.0, 1.0, 0, False
        ]
    }

    try:
        response = requests.post(url, json=payload, timeout=600)
        response.raise_for_status()
        
        # In a real scenario we'd parse the SSE stream or wait for the websocket.
        # Since we use the internal /run/predict, it might block until done.
        result = response.json()
        print("Generation successful. Check Fooocus outputs directory.")
        # Actual implementation requires copying from Fooocus outputs to output_path.
    except Exception as e:
        print(f"Failed to generate image via Gradio REST API: {e}")

if __name__ == '__main__':
    generate_fooocus_image("a beautiful traditional kyoto wooden window frame beam, high quality, isolated on white background", "../assets/templates/beam.png", "../assets/images/frames/kyoto_beam_raw.png")
    generate_fooocus_image("a beautiful traditional kyoto wooden window sill bench, high quality, isolated on white background", "../assets/templates/bench.png", "../assets/images/frames/kyoto_bench_raw.png")
