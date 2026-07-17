import '../models/species.dart';
import '../models/buff.dart';

const List<PlantSpecies> bulbPlants = [
  PlantSpecies(
    id: 'bulb_1',
    name: 'Paperwhite Narcissus',
    scientificName: 'Narcissus papyraceus',
    family: 'Amaryllidaceae',
    category: 'The Spring Sleepers',
    waterNeed: 0.6,
    lightNeed: 0.8,
    growthRate: 1.0,
    pressedBuff: const PlantBuff(type: BuffType.growthSpeed, value: 0.10),
    journalData: PlantJournalData(
      description: 'A wildly fast-growing bulb that shoots up tall, elegant green stems topped with clusters of pure white, incredibly fragrant, star-shaped flowers.',
      botanicalDetails: 'Unlike most bulbs which require a chilling period (winter) to bloom, Paperwhites are native to the Mediterranean and will grow and bloom indoors simply by adding water to the bulb. They are geophytes, storing all the energy they need to bloom tightly packed inside the bulb scales.',
      curiosities: 'The fragrance of a Paperwhite is highly polarizing. Due to a biochemical compound called indole—which is also found in jasmine, but also in coal tar and animal waste—some people think they smell like sweet perfume, while others think they smell like a dirty litter box.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/Narcissus_papyraceus_2.jpg/320px-Narcissus_papyraceus_2.jpg',
      useTitle: 'Stunting with Alcohol',
      useBody: 'Because they grow so fast indoors, they often become top-heavy and flop over. Botanists discovered that if you water them with a 5% alcohol solution (like diluted vodka) once they sprout, it stunts the stem growth by 30% but leaves the flowers full size, preventing them from falling over.',
    ),
  ),
  PlantSpecies(
    id: 'bulb_2',
    name: 'Amaryllis',
    scientificName: 'Hippeastrum',
    family: 'Amaryllidaceae',
    category: 'The Spring Sleepers',
    waterNeed: 0.5,
    lightNeed: 0.8,
    growthRate: 0.8,
    pressedBuff: const PlantBuff(type: BuffType.resilience, value: 0.05),
    journalData: PlantJournalData(
      description: 'A massive, onion-like bulb that produces thick, hollow stalks culminating in absolutely gigantic, velvet-like trumpet flowers that can be up to 8 inches across.',
      botanicalDetails: 'Amaryllis bulbs have a highly specialized contractile root system. As the bulb grows and pushes upward, the thick roots literally flex and pull the bulb back down deeper into the soil to anchor it against the massive weight of the giant flowers.',
      curiosities: 'The true Amaryllis genus contains only two species from South Africa (like the Belladonna Lily). The giant holiday bulbs sold worldwide are actually from the Hippeastrum genus, native to South America. The names were confused by botanists in the 1800s and the mistake stuck forever.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Hippeastrum_Apple_Blossom_01.JPG/320px-Hippeastrum_Apple_Blossom_01.JPG',
      useTitle: 'Forcing the Bloom',
      useBody: 'To get an Amaryllis to bloom again the following year, you must cut off the dead flower, let the leaves grow all summer, and then put the bulb in a cold, dark closet with zero water for 8 weeks to simulate winter dormancy.',
    ),
  ),
];
