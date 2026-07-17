import '../models/species.dart';
import '../models/buff.dart';

const List<PlantSpecies> fernPlants = [
  PlantSpecies(
    id: 'fern_1',
    name: 'Boston Fern',
    scientificName: 'Nephrolepis exaltata',
    family: 'Nephrolepidaceae',
    category: 'The Shade Dwellers',
    waterNeed: 0.8,
    lightNeed: 0.4,
    growthRate: 0.7,
    pressedBuff: const PlantBuff(type: BuffType.moistureRetention, value: 0.05),
    journalData: PlantJournalData(
      description: 'A classic Victorian-era houseplant with incredibly lush, arching, sword-shaped fronds that explode outward like a green fountain.',
      botanicalDetails: 'Ferns are ancient plants that do not produce seeds or flowers. Instead, they reproduce via tiny dust-like spores. If you look at the underside of a mature Boston Fern leaf, you will see perfectly aligned rows of brown dots—these are the sori, or spore cases.',
      curiosities: 'During the Victorian "Fern Craze" (Pteridomania) in the 1850s, collecting ferns became such an intense national obsession in England that people built massive glass wardian cases just to keep them alive in the heavily polluted, coal-smoke filled cities.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Nephrolepis_exaltata_002.JPG/320px-Nephrolepis_exaltata_002.JPG',
      useTitle: 'Humidity Indicator',
      useBody: 'If a Boston Fern begins dropping thousands of tiny brown leaflets all over your floor, it is screaming for more humidity. They require constant moisture and regular misting to remain vibrant.',
    ),
  ),
  PlantSpecies(
    id: 'fern_2',
    name: 'Bird\'s Nest Fern',
    scientificName: 'Asplenium nidus',
    family: 'Aspleniaceae',
    category: 'The Shade Dwellers',
    waterNeed: 0.7,
    lightNeed: 0.3,
    growthRate: 0.4,
    pressedBuff: const PlantBuff(type: BuffType.growthSpeed, value: 0.04),
    journalData: PlantJournalData(
      description: 'Unlike typical feathery ferns, the Bird\'s Nest Fern features massive, solid, bright apple-green fronds with wavy edges that unfurl from a central, fuzzy brown rosette that looks exactly like a bird\'s nest.',
      botanicalDetails: 'In the wild, this fern is an epiphyte. It grows high up in the crotches of giant jungle trees. The "nest" shape is an evolutionary funnel designed to catch falling dead leaves and bird droppings, which decompose into a custom compost to feed the fern.',
      curiosities: 'The fuzzy brown center of the fern is incredibly delicate. If water is poured directly into the center of the nest, the new fronds will instantly rot. You must water the soil around the edge of the pot.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Asplenium_nidus_1.jpg/320px-Asplenium_nidus_1.jpg',
      useTitle: 'Bathroom Oasis',
      useBody: 'Because it thrives in very low light and requires intensely high humidity, the Bird\'s Nest Fern is one of the absolute best plants to permanently keep next to a shower.',
    ),
  ),
];
