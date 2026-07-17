import json
info = json.load(open("../info.json", encoding="utf-8"))
defaults = json.load(open("../defaults.json", encoding="utf-8"))
# Find which endpoint has param length over 100
for k, ep in info.get("unnamed_endpoints", {}).items():
    params = ep.get("parameters", [])
    if len(params) > 100:
        print(f"Endpoint {k} has {len(params)} parameters")
        with open("api_params.txt", "w", encoding="utf-8") as f:
            for i, p in enumerate(params):
                label = p.get("parameter_name") or p.get("label", f"param_{i}")
                default_val = defaults[i][1] if i < len(defaults) else None
                f.write(f"Index {i}: {label} = {default_val}\n")
        break
