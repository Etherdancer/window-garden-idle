import os
import re
from PIL import Image

src_dir = r'C:\Users\Tomek\.gemini\antigravity\brain\005cc227-116e-4686-9de5-fdc952c7fa21'
dest_dir = r'C:\Users\Tomek\.gemini\antigravity\scratch\window-garden-idle\assets\images'

img = Image.open(os.path.join(src_dir, 'window_frame_modern_front_1782038176520.png'))
img.save(os.path.join(dest_dir, 'window_frame_modern.png'))
print('Front modern window frame copied')

# Update garden_location.dart
dart_file = r'C:\Users\Tomek\.gemini\antigravity\scratch\window-garden-idle\lib\models\garden_location.dart'
with open(dart_file, 'r', encoding='utf-8') as f:
    content = f.read()

if 'final bool isUrban;' not in content:
    content = content.replace('final double longitude;', 'final double longitude;\n  final bool isUrban;')
    content = content.replace('required this.longitude,', 'required this.longitude,\n    this.isUrban = false,')

urban_ids = [
    'tokyo', 'seoul', 'hanoi', 'jaipur', 'melbourne', 
    'paris', 'amsterdam', 'lisbon', 'edinburgh', 'prague', 
    'bergen', 'reykjavik', 'dubrovnik', 'new_york', 'havana', 
    'buenos_aires', 'medellin', 'marrakech'
]

for uid in urban_ids:
    if f"isUrban: true" not in content.split(f"id: '{uid}'")[1].split('),')[0]:
        pattern = r"(id:\s*'" + uid + r"',.*?longitude:\s*-?\d+\.\d+,)(\n\s*\),)"
        content = re.sub(pattern, r'\1\n      isUrban: true,\2', content, flags=re.DOTALL)

with open(dart_file, 'w', encoding='utf-8') as f:
    f.write(content)
print('Updated garden_location.dart')
