import os
from rembg import remove
from PIL import Image

def process_images():
    input_dir = '../assets/images/frames'
    output_dir = '../assets/images/frames'
    os.makedirs(output_dir, exist_ok=True)
    
    # We expect the user to have generated kyoto_beam_raw.png and kyoto_bench_raw.png
    files_to_process = [
        'kyoto_beam_raw.png',
        'kyoto_bench_raw.png'
    ]
    
    for filename in files_to_process:
        input_path = os.path.join(input_dir, filename)
        if not os.path.exists(input_path):
            print(f"File not found: {input_path}")
            continue
            
        print(f"Processing {filename}...")
        try:
            with open(input_path, 'rb') as i:
                input_data = i.read()
                
            output_data = remove(input_data)
            
            output_filename = filename.replace('_raw', '')
            output_path = os.path.join(output_dir, output_filename)
            
            with open(output_path, 'wb') as o:
                o.write(output_data)
                
            print(f"Saved transparent image to {output_path}")
        except Exception as e:
            print(f"Failed to process {filename}: {e}")

if __name__ == '__main__':
    process_images()
