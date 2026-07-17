import json

info = json.load(open("../info.json", encoding="utf-8"))
defaults = json.load(open("../defaults.json", encoding="utf-8"))

# Find the generate endpoint in named_endpoints or unnamed_endpoints
endpoint = info.get("named_endpoints", {}).get("/generate_image_grid_for_each_batch")
if not endpoint:
    endpoint = info.get("unnamed_endpoints", {}).get("68") # Usually it's index 68 or so

if endpoint:
    params = endpoint.get("parameters", [])
    for i, p in enumerate(params):
        label = p.get("parameter_name") or p.get("label", f"param_{i}")
        default_val = defaults[i][1] if i < len(defaults) else None
        print(f"Index {i}: {label} = {default_val}")
else:
    print("Endpoint not found")
