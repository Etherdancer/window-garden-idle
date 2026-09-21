import 'dart:io';

void main() {
  final file = File('lib/data/species_ornamental.dart');
  var content = file.readAsStringSync();
  
  final Map<String, String> mappings = {
    'Calathea (Prayer Plant)': 'The Tropical Canopy',
    'String of Pearls': 'The Arid Survivors',
    'Chinese Money Plant': 'The Tropical Canopy',
    'Living Stones': 'The Arid Survivors',
    'Venus Flytrap': 'DELETE', 
    'Air Plant': 'The Epiphytes',
    'Monstera (Swiss Cheese Plant)': 'The Tropical Canopy',
    'Golden Pothos': 'The Tropical Canopy',
    'Snake Plant': 'The Arid Survivors',
    'Peace Lily': 'The Tropical Canopy',
    'ZZ Plant': 'The Arid Survivors',
    'Fiddle Leaf Fig': 'The Tropical Canopy',
    'Jade Plant': 'The Arid Survivors',
    'Spider Plant': 'The Tropical Canopy',
    'African Violet': 'The Balcony Bloomers',
    'Moth Orchid': 'The Epiphytes',
    'Inch Plant (Wandering Dude)': 'The Tropical Canopy',
    'Polka Dot Begonia': 'The Balcony Bloomers',
  };

  mappings.forEach((name, category) {
    if (category == 'DELETE') {
       // do nothing
    } else {
       // match the whole PlantSpecies block or just find name: 'name', \n ... category: 'Ornamental Houseplants',
       // Since the structure is fixed, we can do a regex replace
       var escapedName = RegExp.escape(name);
       var regExp = RegExp(r"(name:\s*'" + escapedName + r"',[\s\S]*?category:\s*)'Ornamental Houseplants'");
       content = content.replaceAllMapped(regExp, (match) {
         return "${match.group(1)}'$category'";
       });
    }
  });

  file.writeAsStringSync(content);
}
