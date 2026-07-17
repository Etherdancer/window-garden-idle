import '../models/species.dart';
import '../models/buff.dart';

const List<PlantSpecies> bogPlants = [
  PlantSpecies(
    id: 'bog_1',
    name: 'Venus Flytrap',
    scientificName: 'Dionaea muscipula',
    family: 'Droseraceae',
    category: 'The Bog Hunters',
    waterNeed: 1.0,
    lightNeed: 1.0,
    growthRate: 0.3,
    pressedBuff: const PlantBuff(type: BuffType.resilience, value: 0.15),
    journalData: PlantJournalData(
      description: 'The most famous carnivorous plant in the world, featuring hinged jaw-like leaves with sharp teeth that snap shut to trap live insects.',
      botanicalDetails: 'The trap only closes if an insect triggers two different microscopic hairs within 20 seconds. This complex memory mechanism prevents the plant from wasting massive amounts of energy snapping shut on false alarms like falling leaves or raindrops.',
      curiosities: 'Despite being sold as tropical exotic novelties worldwide, the Venus Flytrap is incredibly rare in the wild and only exists natively in a tiny 60-mile radius of nitrogen-poor bogs in North and South Carolina.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Venus_Flytrap_showing_trigger_hairs.jpg/320px-Venus_Flytrap_showing_trigger_hairs.jpg',
      useTitle: 'Distilled Water Only',
      useBody: 'Because they evolved in bogs with zero nutrients, their roots act like sponges. If you give them tap water or fertilizer, the minerals will burn their roots and kill them instantly. They must only drink pure distilled water or rainwater.',
    ),
  ),
  PlantSpecies(
    id: 'bog_2',
    name: 'Cape Sundew',
    scientificName: 'Drosera capensis',
    family: 'Droseraceae',
    category: 'The Bog Hunters',
    waterNeed: 1.0,
    lightNeed: 0.8,
    growthRate: 0.6,
    pressedBuff: const PlantBuff(type: BuffType.resilience, value: 0.10),
    journalData: PlantJournalData(
      description: 'An alien-looking plant with long, tentacle-like leaves covered in bright red hairs. Each hair secretes a drop of sticky, sugary nectar that sparkles like morning dew.',
      botanicalDetails: 'When a fungus gnat lands to drink the dew, it gets hopelessly stuck. The tentacles detect the struggling insect and slowly curl around it, wrapping the bug in a tight cocoon while secreting powerful digestive enzymes.',
      curiosities: 'The digestive enzymes of the sundew are so strong they can completely dissolve the soft tissues of a mosquito into a nutrient soup within 24 hours, leaving only the empty chitin exoskeleton behind to blow away in the wind.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Drosera_capensis_bend.jpg/320px-Drosera_capensis_bend.jpg',
      useTitle: 'Fungus Gnat Annihilator',
      useBody: 'The Cape Sundew is the ultimate biological weapon against fungus gnats. Placing one next to your other houseplants will passively eradicate all flying pests without the need for toxic chemical sprays.',
    ),
  ),
];
