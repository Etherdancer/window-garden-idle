import re

raw_table = """
| 1 | Sweet Basil | *Ocimum basilicum* | Lamiaceae | Anti-inflammatory, pesto, Mediterranean cuisine |
| 2 | Holy Basil (Tulsi) | *Ocimum tenuiflorum* | Lamiaceae | Adaptogenic tea, Ayurvedic medicine |
| 3 | Thai Basil | *Ocimum basilicum* var. *thyrsiflora* | Lamiaceae | Southeast Asian cuisine, digestive aid |
| 4 | Rosemary | *Salvia rosmarinus* | Lamiaceae | Memory & cognition, roasted dishes |
| 5 | Common Thyme | *Thymus vulgaris* | Lamiaceae | Antimicrobial, soups, respiratory health |
| 6 | Lemon Thyme | *Thymus citriodorus* | Lamiaceae | Vitamin C, fish dishes, herbal tea |
| 7 | Oregano | *Origanum vulgare* | Lamiaceae | Carvacrol (antioxidant), Italian cuisine |
| 8 | Peppermint | *Mentha × piperita* | Lamiaceae | Digestive aid, IBS relief, teas |
| 9 | Spearmint | *Mentha spicata* | Lamiaceae | Hormonal balance, cooling drinks |
| 10 | Cilantro / Coriander | *Coriandrum sativum* | Apiaceae | Heavy metal detox claims, global cuisine |
| 11 | Dill | *Anethum graveolens* | Apiaceae | Digestive, pickling, Scandinavian cuisine |
| 12 | Flat-Leaf Parsley | *Petroselinum crispum* | Apiaceae | Iron & Vitamin K, chimichurri, tabbouleh |
| 13 | Curly Parsley | *Petroselinum crispum* var. *crispum* | Apiaceae | Garnish, breath freshener, antioxidant |
| 14 | Common Sage | *Salvia officinalis* | Lamiaceae | Memory, sore throat gargle, stuffings |
| 15 | Chives | *Allium schoenoprasum* | Amaryllidaceae | Allicin (heart health), garnish |
| 16 | Garlic Chives | *Allium tuberosum* | Amaryllidaceae | Asian dumplings, cardiovascular health |
| 17 | French Tarragon | *Artemisia dracunculus* | Asteraceae | Béarnaise sauce, appetite stimulant |
| 18 | Lemongrass | *Cymbopogon citratus* | Poaceae | Citral (antifungal), Thai soups, herbal tea |
| 19 | Bay Laurel | *Laurus nobilis* | Lauraceae | Stews, blood sugar regulation |
| 20 | Sweet Marjoram | *Origanum majorana* | Lamiaceae | Calming herb, sausages, digestive |
| 21 | Fennel | *Foeniculum vulgare* | Apiaceae | Bloating relief, Italian sausage, lactation |
| 22 | Lovage | *Levisticum officinale* | Apiaceae | Diuretic, European soups, celery substitute |
| 23 | Chervil | *Anthriscus cerefolium* | Apiaceae | French fines herbes, mild anise flavor |
| 24 | Summer Savory | *Satureja hortensis* | Lamiaceae | Bean dishes, digestive, German cuisine |
| 25 | Sorrel | *Rumex acetosa* | Polygonaceae | Vitamin C, French soups, tangy salads |
| 26 | Lemon Balm | *Melissa officinalis* | Lamiaceae | Anxiety relief, sleep aid, herbal tea |
| 27 | Stevia | *Stevia rebaudiana* | Asteraceae | Zero-calorie sweetener, sugar alternative |
| 28 | Watercress | *Nasturtium officinale* | Brassicaceae | Superfood, vitamin K, peppery salads |
| 29 | Shiso / Perilla | *Perilla frutescens* | Lamiaceae | Japanese cuisine, omega-3, anti-allergenic |
| 30 | Vietnamese Coriander | *Persicaria odorata* | Polygonaceae | Pho garnish, appetite suppressant claims |
| 31 | Chamomile | *Matricaria chamomilla* | Asteraceae | Calming tea, sleep, skin soothing |
| 32 | English Lavender | *Lavandula angustifolia* | Lamiaceae | Stress relief, aromatherapy, baking |
| 33 | Echinacea | *Echinacea purpurea* | Asteraceae | Immune support supplement |
| 34 | Valerian | *Valeriana officinalis* | Caprifoliaceae | Sleep aid supplement, anxiety |
| 35 | St. John's Wort | *Hypericum perforatum* | Hypericaceae | Mood support supplement |
| 36 | Milk Thistle | *Silybum marianum* | Asteraceae | Liver support (silymarin) |
| 37 | Calendula | *Calendula officinalis* | Asteraceae | Skin healing, anti-inflammatory salves |
| 38 | Feverfew | *Tanacetum parthenium* | Asteraceae | Migraine prevention supplement |
| 39 | Lemon Verbena | *Aloysia citrodora* | Verbenaceae | Digestive tea, joint health |
| 40 | Passionflower | *Passiflora incarnata* | Passifloraceae | Anxiety & sleep supplement |
| 41 | Skullcap | *Scutellaria lateriflora* | Lamiaceae | Nervine, stress relief tea |
| 42 | Yarrow | *Achillea millefolium* | Asteraceae | Wound healing, fever reducer |
| 43 | Marshmallow | *Althaea officinalis* | Malvaceae | Sore throat, mucilage root |
| 44 | Borage | *Borago officinalis* | Boraginaceae | GLA oil supplement, edible flowers |
| 45 | Hyssop | *Hyssopus officinalis* | Lamiaceae | Respiratory, biblical herb, liqueurs |
| 46 | Catnip | *Nepeta cataria* | Lamiaceae | Human calming tea, digestive |
| 47 | Bee Balm | *Monarda didyma* | Lamiaceae | Oswego tea, antiseptic, pollinators |
| 48 | Angelica | *Angelica archangelica* | Apiaceae | Gin botanical, digestive bitters |
| 49 | Evening Primrose | *Oenothera biennis* | Onagraceae | GLA oil supplement, hormonal balance |
| 50 | Mullein | *Verbascum thapsus* | Scrophulariaceae | Respiratory tea, ear oil |
| 51 | Plantain | *Plantago major* | Plantaginaceae | Psyllium relative, wound herb |
| 52 | Comfrey | *Symphytum officinale* | Boraginaceae | Topical bone/joint salve |
| 53 | Motherwort | *Leonurus cardiaca* | Lamiaceae | Heart tonic, women's health |
| 54 | White Horehound | *Marrubium vulgare* | Lamiaceae | Cough drops, bitter tonic |
| 55 | Elecampane | *Inula helenium* | Asteraceae | Respiratory, prebiotic inulin |
| 56 | Wood Betony | *Betonica officinalis* | Lamiaceae | Headache, nervine tea |
| 57 | Agrimony | *Agrimonia eupatoria* | Rosaceae | Sore throat gargle, digestive |
| 58 | Clary Sage | *Salvia sclarea* | Lamiaceae | Hormonal balance, aromatherapy |
| 59 | Meadowsweet | *Filipendula ulmaria* | Rosaceae | Natural salicylates (aspirin origin) |
| 60 | Anise Hyssop | *Agastache foeniculum* | Lamiaceae | Licorice-flavored tea, cough relief |
| 61 | Moringa | *Moringa oleifera* | Moringaceae | "Miracle tree," nutrient-dense powder |
| 62 | Turmeric | *Curcuma longa* | Zingiberaceae | Curcumin anti-inflammatory, golden milk |
| 63 | Ginger | *Zingiber officinale* | Zingiberaceae | Nausea relief, anti-inflammatory |
| 64 | Ashwagandha | *Withania somnifera* | Solanaceae | Adaptogen, stress/cortisol supplement |
| 65 | Gotu Kola | *Centella asiatica* | Apiaceae | Brain tonic, skin collagen |
| 66 | Rhodiola | *Rhodiola rosea* | Crassulaceae | Adaptogen, endurance, altitude |
| 67 | Brahmi | *Bacopa monnieri* | Plantaginaceae | Memory supplement, Ayurvedic |
| 68 | Goji Berry | *Lycium barbarum* | Solanaceae | Antioxidant superfood berries |
| 69 | Wheatgrass | *Triticum aestivum* | Poaceae | Chlorophyll juice shots |
| 70 | Barley Grass | *Hordeum vulgare* | Poaceae | Green juice powder, detox |
| 71 | Aloe Vera | *Aloe barbadensis* | Asphodelaceae | Gel for skin, digestive juice |
| 72 | Chia | *Salvia hispanica* | Lamiaceae | Omega-3 seeds, puddings |
| 73 | Flax | *Linum usitatissimum* | Linaceae | Omega-3 oil, fiber supplement |
| 74 | Amaranth | *Amaranthus cruentus* | Amaranthaceae | Complete protein grain, microgreens |
| 75 | Maca | *Lepidium meyenii* | Brassicaceae | Energy & fertility supplement |
| 76 | Schisandra | *Schisandra chinensis* | Schisandraceae | Five-flavor adaptogen berry |
| 77 | Jiaogulan | *Gynostemma pentaphyllum* | Cucurbitaceae | "Immortality herb," adaptogenic tea |
| 78 | Astragalus | *Astragalus membranaceus* | Fabaceae | Immune tonic, TCM staple |
| 79 | Licorice | *Glycyrrhiza glabra* | Fabaceae | Adrenal support, throat soothing |
| 80 | Korean Ginseng | *Panax ginseng* | Araliaceae | Energy, cognitive supplement |
| 81 | Tea Plant (Green/White) | *Camellia sinensis* | Theaceae | Green tea, matcha, L-theanine |
| 82 | Hibiscus | *Hibiscus sabdariffa* | Malvaceae | Blood pressure tea, agua fresca |
| 83 | Butterfly Pea | *Clitoria ternatea* | Fabaceae | Blue tea, natural food coloring |
| 84 | Yerba Mate | *Ilex paraguariensis* | Aquifoliaceae | South American caffeine, mate ritual |
| 85 | Rooibos | *Aspalathus linearis* | Fabaceae | Caffeine-free antioxidant tea |
| 86 | Roselle | *Hibiscus acetosella* | Malvaceae | Cranberry-like juice, jams |
| 87 | Guayusa | *Ilex guayusa* | Aquifoliaceae | Amazonian caffeine, smooth energy |
| 88 | Honeybush | *Cyclopia intermedia* | Fabaceae | South African sweet tea, antioxidant |
| 89 | Cat's Whiskers | *Orthosiphon aristatus* | Lamiaceae | "Java Tea," kidney health |
| 90 | Chrysanthemum | *Chrysanthemum morifolium* | Asteraceae | Chinese cooling tea, eye health |
| 91 | Pandan | *Pandanus amaryllifolius* | Pandanaceae | SE Asian vanilla, fragrant desserts |
| 92 | Linden / Lime Flower | *Tilia cordata* | Malvaceae | Calming European tea, honey source |
| 93 | Black Pepper | *Piper nigrum* | Piperaceae | "King of spices," piperine absorption |
| 94 | Ceylon Cinnamon | *Cinnamomum verum* | Lauraceae | Blood sugar, anti-inflammatory |
| 95 | Cardamom | *Elettaria cardamomum* | Zingiberaceae | Chai spice, digestive |
| 96 | Vanilla Orchid | *Vanilla planifolia* | Orchidaceae | Extract, aromatherapy, baking |
| 97 | Saffron Crocus | *Crocus sativus* | Iridaceae | Most precious spice, mood support |
| 98 | Fenugreek | *Trigonella foenum-graecum* | Fabaceae | Lactation, curry, blood sugar |
| 99 | Mustard | *Sinapis alba* | Brassicaceae | Condiment, microgreens, poultice |
| 100 | Cumin | *Cuminum cyminum* | Apiaceae | Digestive, global spice staple |
| 101 | Szechuan Pepper | *Zanthoxylum piperitum* | Rutaceae | Numbing spice, Chinese cuisine |
| 102 | Nigella / Black Seed | *Nigella sativa* | Ranunculaceae | "Seed of blessing," thymoquinone |
| 103 | Annatto | *Bixa orellana* | Bixaceae | Natural orange colorant, Latin cuisine |
| 104 | Sumac | *Rhus coriaria* | Anacardiaceae | Lemony spice, Middle Eastern za'atar |
| 105 | Long Pepper | *Piper longum* | Piperaceae | Ayurvedic, bioavailability enhancer |
| 106 | Wasabi | *Eutrema japonicum* | Brassicaceae | Japanese condiment, antimicrobial |
| 107 | Galangal | *Alpinia galanga* | Zingiberaceae | Thai curry paste, digestive |
| 108 | Curry Leaf | *Murraya koenigii* | Rutaceae | Indian cuisine, hair health |
| 109 | Kaffir Lime | *Citrus hystrix* | Rutaceae | Thai cooking, aromatic leaves |
| 110 | Epazote | *Dysphania ambrosioides* | Amaranthaceae | Mexican bean herb, carminative |
| 111 | Nasturtium | *Tropaeolum majus* | Tropaeolaceae | Peppery salads, vitamin C |
| 112 | Viola / Wild Pansy | *Viola tricolor* | Violaceae | Cake decoration, skin tea |
| 113 | Damask Rose | *Rosa damascena* | Rosaceae | Rose water, Turkish delight |
| 114 | Arabian Jasmine | *Jasminum sambac* | Oleaceae | Jasmine tea, perfumery |
| 115 | Dandelion | *Taraxacum officinale* | Asteraceae | Liver tonic, salad greens, root coffee |
| 116 | Sunflower (Dwarf) | *Helianthus annuus* | Asteraceae | Seeds, microgreens, vitamin E |
| 117 | Cornflower | *Centaurea cyanus* | Asteraceae | Tea blend, natural food dye |
| 118 | Red Clover | *Trifolium pratense* | Fabaceae | Isoflavones, women's supplement |
| 119 | Safflower | *Carthamus tinctorius* | Asteraceae | Oil, natural dye, TCM |
| 120 | Dianthus / Clove Pink | *Dianthus caryophyllus* | Caryophyllaceae | Spiced wine, liqueurs |
| 121 | Cherry Tomato | *Solanum lycopersicum* | Solanaceae | Lycopene, snacking, salads |
| 122 | Chili Pepper | *Capsicum annuum* | Solanaceae | Capsaicin metabolism boost |
| 123 | Habanero | *Capsicum chinense* | Solanaceae | Extreme capsaicin, hot sauces |
| 124 | Dwarf Bell Pepper | *Capsicum annuum* (sweet) | Solanaceae | Vitamin C, crunchy snacking |
| 125 | Lettuce | *Lactuca sativa* | Asteraceae | Salad staple, low-calorie |
| 126 | Spinach | *Spinacia oleracea* | Amaranthaceae | Iron, folate, smoothies |
| 127 | Kale | *Brassica oleracea* var. *sabellica* | Brassicaceae | Superfood, chips, smoothies |
| 128 | Swiss Chard | *Beta vulgaris* subsp. *vulgaris* | Amaranthaceae | Rainbow stems, magnesium |
| 129 | Radish | *Raphanus sativus* | Brassicaceae | Fast-growing, digestive enzyme |
| 130 | Green Onion / Scallion | *Allium fistulosum* | Amaryllidaceae | Regrows from scraps, quercetin |
| 131 | Strawberry (Alpine) | *Fragaria vesca* | Rosaceae | Tiny sweet berries, vitamin C |
| 132 | Dwarf Lemon | *Citrus limon* | Rutaceae | Vitamin C, lemon water |
| 133 | Dwarf Lime | *Citrus aurantiifolia* | Rutaceae | Cocktails, ceviche, vitamin C |
| 134 | Dwarf Pomegranate | *Punica granatum* 'Nana' | Lythraceae | Antioxidant arils, juice |
| 135 | Microgreens (Broccoli) | *Brassica oleracea* var. *italica* | Brassicaceae | Sulforaphane concentrate |
| 136 | Purslane | *Portulaca oleracea* | Portulacaceae | Omega-3 succulent green |
| 137 | New Zealand Spinach | *Tetragonia tetragonioides* | Aizoaceae | Heat-tolerant green, oxalic acid free |
| 138 | Malabar Spinach | *Basella alba* | Basellaceae | Tropical vine green, mucilaginous |
| 139 | Neem | *Azadirachta indica* | Meliaceae | Ayurvedic cleansing, dental, skin |
| 140 | Dong Quai | *Angelica sinensis* | Apiaceae | "Female ginseng," TCM blood tonic |
| 141 | Ginkgo (Bonsai) | *Ginkgo biloba* | Ginkgoaceae | Memory supplement, ancient species |
| 142 | Mugwort | *Artemisia vulgaris* | Asteraceae | Dream herb, moxibustion, digestive |
| 143 | Wormwood | *Artemisia absinthium* | Asteraceae | Absinthe, digestive bitters |
| 144 | Shatavari | *Asparagus racemosus* | Asparagaceae | Ayurvedic women's tonic |
| 145 | Guduchi / Giloy | *Tinospora cordifolia* | Menispermaceae | Ayurvedic immune modulator |
| 146 | Katuk | *Sauropus androgynus* | Phyllanthaceae | "Star gooseberry" leaf vegetable rich in vitamins, popular in Southeast Asian cuisine. |
| 147 | Cat's Claw | *Uncaria tomentosa* | Rubiaceae | Amazonian immune herb |
| 148 | Spilanthes / Toothache Plant | *Acmella oleracea* | Asteraceae | Numbing flowers, dental, cocktails |
| 149 | Stinging Nettle | *Urtica dioica* | Urticaceae | Iron, allergy relief, pesto |
| 150 | Elderberry | *Sambucus nigra* | Adoxaceae | Immune syrup, cold/flu supplement |
| 151 | Lemon Myrtle | *Backhousia citriodora* | Myrtaceae | Australian citral, antibacterial |
| 152 | Tulsi Rama | *Ocimum tenuiflorum* 'Rama' | Lamiaceae | Milder tulsi variety, daily tea |
| 153 | Spider Plant | *Chlorophytum comosum* | Asparagaceae | NASA air purifier, easy care |
| 154 | Peace Lily | *Spathiphyllum wallisii* | Araceae | Air purifier, low-light beauty |
| 155 | Jade Plant | *Crassula ovata* | Crassulaceae | Feng shui prosperity, succulent |
"""

def get_category(index):
    if index <= 30: return "Culinary Herbs"
    if index <= 60: return "Medicinal & Supplement Herbs"
    if index <= 80: return "Superfoods & Adaptogens"
    if index <= 92: return "Tea & Beverage Plants"
    if index <= 110: return "Spice Plants"
    if index <= 120: return "Edible Flowers & Garnish"
    if index <= 138: return "Windowsill Edibles"
    return "Traditional Medicine & Wellness"

def escape_string(s):
    return s.replace("'", "\\'")

dart_code = '''class PlantSpecies {
  final String id;
  final String name;
  final String scientificName;
  final String family;
  final String category;
  final double waterNeed;
  final double lightNeed;
  final double growthRate;
  final List<String> facts;

  const PlantSpecies({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.family,
    required this.category,
    required this.waterNeed,
    required this.lightNeed,
    required this.growthRate,
    required this.facts,
  });
}

const List<PlantSpecies> plantSpeciesList = [
'''

for line in raw_table.split('\\n'):
    if not line.strip() or not line.startswith('|'):
        continue
    
    parts = [p.strip() for p in line.split('|')[1:-1]]
    if len(parts) < 5: continue
    
    try:
        index = int(parts[0])
    except ValueError:
        continue
        
    name = parts[1]
    scientific_name = parts[2].replace('*', '')
    family = parts[3]
    uses = parts[4]
    
    category = get_category(index)
    
    # Generate some semi-random but plausible care needs based on index to give variety
    water = 0.3 + (index % 6) * 0.1
    light = 0.4 + (index % 5) * 0.1
    growth = 0.3 + (index % 7) * 0.1
    
    # Split uses into 3 facts if possible, or just create 3 facts
    uses_list = [u.strip() for u in uses.split(',')]
    if len(uses_list) < 3:
        uses_list.append(f'Belongs to the {family} family.')
    if len(uses_list) < 3:
        uses_list.append('Highly valued in natural health and culinary arts.')
    
    fact1 = escape_string(uses_list[0])
    fact2 = escape_string(uses_list[1])
    fact3 = escape_string(uses_list[2])

    dart_code += f"""  PlantSpecies(
    id: 'plant_{index}',
    name: '{escape_string(name)}',
    scientificName: '{escape_string(scientific_name)}',
    family: '{escape_string(family)}',
    category: '{category}',
    waterNeed: {water:.1f},
    lightNeed: {light:.1f},
    growthRate: {growth:.1f},
    facts: [
      '{fact1}',
      '{fact2}',
      '{fact3}',
    ],
  ),
"""

dart_code += "];\n"

with open('C:/Window Garden Idle/lib/models/species.dart', 'w', encoding='utf-8') as f:
    f.write(dart_code)

print("Generated and written successfully.")
