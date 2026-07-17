import os
from PIL import Image, ImageDraw

def create_templates():
    os.makedirs('../assets/templates', exist_ok=True)
    
    # 1. Beam template (Vertical, 1024x1024)
    # We want a thick vertical pillar on the left edge.
    img_beam = Image.new('RGB', (1024, 1024), color='white')
    draw_beam = ImageDraw.Draw(img_beam)
    # A beam of width 200 on the left edge
    draw_beam.rectangle([0, 0, 200, 1024], fill='black')
    img_beam.save('../assets/templates/beam.png')
    print("Created assets/templates/beam.png")

    # 2. Bench template (Horizontal, 1024x1024)
    # We want a thick bench block at the bottom
    img_bench = Image.new('RGB', (1024, 1024), color='white')
    draw_bench = ImageDraw.Draw(img_bench)
    # A bench of height 300 at the bottom
    draw_bench.rectangle([0, 1024 - 300, 1024, 1024], fill='black')
    
    # Add a sill lip line (perspective line)
    draw_bench.line([0, 1024 - 300 + 40, 1024, 1024 - 300 + 40], fill='white', width=10)
    
    img_bench.save('../assets/templates/bench.png')
    print("Created assets/templates/bench.png")

if __name__ == '__main__':
    create_templates()
