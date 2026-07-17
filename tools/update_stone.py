import re

with open('lib/models/garden_location.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Introduce enum and replace isUrban with frameType
if 'enum WindowFrameType' not in content:
    content = 'enum WindowFrameType { traditional, modern, stone }\n\n' + content

# Replace fields
content = content.replace('final bool isUrban;', 'final WindowFrameType frameType;')
content = content.replace('this.isUrban = false,', 'this.frameType = WindowFrameType.traditional,')

# Replace existing isUrban: true
content = content.replace('isUrban: true', 'frameType: WindowFrameType.modern')

# Locations to become stone
stone_ids = [
    'santorini', 'dubrovnik', 'edinburgh', 'prague', 
    'tuscany', 'marrakech', 'petra', 'havana', 'amalfi_coast'
]

for uid in stone_ids:
    # Check if the block has frameType: WindowFrameType.modern
    block_pattern = r"(id:\s*'" + uid + r"'.*?frameType:\s*WindowFrameType\.modern,)"
    if re.search(block_pattern, content, flags=re.DOTALL):
        # It's modern, change to stone
        content = re.sub(
            r"(id:\s*'" + uid + r"'.*?)frameType:\s*WindowFrameType\.modern,", 
            r'\1frameType: WindowFrameType.stone,', 
            content, flags=re.DOTALL
        )
    else:
        # It's traditional, insert stone
        # Find longitude line and insert after it
        content = re.sub(
            r"(id:\s*'" + uid + r"'.*?longitude:\s*-?\d+\.\d+,)", 
            r'\1\n      frameType: WindowFrameType.stone,', 
            content, flags=re.DOTALL
        )

with open('lib/models/garden_location.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('Updated garden_location.dart with stone frameType')
