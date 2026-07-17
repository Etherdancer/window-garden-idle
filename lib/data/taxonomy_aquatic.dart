import '../models/species.dart';
import '../models/buff.dart';

const List<PlantSpecies> aquaticPlants = [
  PlantSpecies(
    id: 'aquatic_1',
    name: 'Marimo Moss Ball',
    scientificName: 'Aegagropila linnaei',
    family: 'Pithophoraceae',
    category: 'The Water Bowls',
    waterNeed: 1.0,
    lightNeed: 0.3,
    growthRate: 0.05,
    pressedBuff: const PlantBuff(type: BuffType.growthSpeed, value: 0.03),
    journalData: PlantJournalData(
      description: 'A completely spherical, fuzzy green algae ball that lives entirely submerged in water. It looks like a perfectly round, underwater tennis ball made of velvet.',
      botanicalDetails: 'Marimo are actually not moss at all, but a rare growth form of filamentous green algae. They only form into spheres because of the gentle rolling action of waves at the bottom of a few specific lakes in Japan, Iceland, and Estonia.',
      curiosities: 'In Japan, Marimo are considered a national treasure. They are said to bring good luck, and can live for over 100 years. If cut in half, they will simply heal and slowly roll themselves back into two smaller spheres.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c9/Aegagropila_linnaei.jpg/320px-Aegagropila_linnaei.jpg',
      useTitle: 'Water Changes',
      useBody: 'Because they have no roots to filter toxins, their water must be changed every two weeks. When changing the water, you must take the ball out and gently roll it between your palms to maintain its perfectly spherical shape.',
    ),
  ),
  PlantSpecies(
    id: 'aquatic_2',
    name: 'Dwarf Water Lily',
    scientificName: 'Nymphaea',
    family: 'Nymphaeaceae',
    category: 'The Water Bowls',
    waterNeed: 1.0,
    lightNeed: 0.9,
    growthRate: 0.6,
    pressedBuff: const PlantBuff(type: BuffType.moistureRetention, value: 0.08),
    journalData: PlantJournalData(
      description: 'A stunning miniature aquatic plant that sends perfectly round, floating lily pads to the surface of the water, followed by beautiful, star-shaped flowers that open during the day and close at night.',
      botanicalDetails: 'The plant grows from a submerged tuber buried in mud. The stems are hollow, containing tiny air canals that pump vital oxygen from the floating leaves down to the roots buried in the oxygen-deprived muck.',
      curiosities: 'Water lilies are some of the oldest flowering plants on Earth. Their genetic lineage split off from the rest of the flowering plants over 100 million years ago, long before the dinosaurs went extinct.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/Nymphaea_alba_1.jpg/320px-Nymphaea_alba_1.jpg',
      useTitle: 'Surface Coverage',
      useBody: 'Water lilies block sunlight from hitting the deeper water, which naturally prevents algae blooms from taking over a fish bowl or pond. However, if the pads cover more than 70% of the surface, oxygen exchange will be cut off.',
    ),
  ),
];
