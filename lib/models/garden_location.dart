import 'package:flutter/material.dart';

class GardenLocation {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final String windowImagePath;
  final Color accentPrimary;
  final Color accentSecondary;
  final Color surfaceColor;
  final String emoji;
  final String timeZone;

  const GardenLocation({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.windowImagePath,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.surfaceColor,
    required this.emoji,
    required this.timeZone,
  });

  static const List<GardenLocation> registry = [
    // Asia & Oceania
    GardenLocation(
      id: 'tokyo',
      name: 'Tokyo, Japan',
      tagline: 'Neon & Cherry Blossoms',
      description: 'Rooftop at dusk, cherry tree, skyline glow.',
      windowImagePath: 'assets/images/locations/tokyo.png',
      accentPrimary: Color(0xFFFFB7C5), // Sakura pink
      accentSecondary: Color(0xFF3F51B5), // Soft indigo
      surfaceColor: Color(0xFF2C2C3E),
      emoji: '🌸',
      timeZone: 'Asia/Tokyo',
    ),
    GardenLocation(
      id: 'kyoto',
      name: 'Kyoto, Japan',
      tagline: 'Zen Tranquility',
      description: 'Temple garden, red maple, koi pond.',
      windowImagePath: 'assets/images/locations/kyoto.png',
      accentPrimary: Color(0xFF8A9A5B), // Moss green
      accentSecondary: Color(0xFFA9A9A9), // Warm stone
      surfaceColor: Color(0xFFF4F1EA),
      emoji: '⛩️',
      timeZone: 'Asia/Tokyo',
    ),
    GardenLocation(
      id: 'seoul',
      name: 'Seoul, South Korea',
      tagline: 'Hanok Charm & City Lights',
      description: 'Traditional hanok courtyard, distant Namsan tower.',
      windowImagePath: 'assets/images/locations/seoul.png',
      accentPrimary: Color(0xFFACE1AF), // Celadon green
      accentSecondary: Color(0xFF8B5A2B), // Hanok brown
      surfaceColor: Color(0xFFF8F9FA),
      emoji: '🏯',
      timeZone: 'Asia/Seoul',
    ),
    GardenLocation(
      id: 'bali',
      name: 'Bali, Indonesia',
      tagline: 'Tropical Serenity',
      description: 'Rice terraces, frangipani, misty volcano.',
      windowImagePath: 'assets/images/locations/bali.png',
      accentPrimary: Color(0xFF50C878), // Emerald
      accentSecondary: Color(0xFFFFD700), // Gold
      surfaceColor: Color(0xFFF5F5DC),
      emoji: '🌴',
      timeZone: 'Asia/Makassar',
    ),
    GardenLocation(
      id: 'chiang_mai',
      name: 'Chiang Mai, Thailand',
      tagline: 'Lanterns & Temple Gold',
      description: 'Temple spires, floating lanterns, tropical canopy.',
      windowImagePath: 'assets/images/locations/chiang_mai.png',
      accentPrimary: Color(0xFFDAA520), // Temple gold
      accentSecondary: Color(0xFF2E8B57), // Jungle green
      surfaceColor: Color(0xFFFFF8DC),
      emoji: '🏮',
      timeZone: 'Asia/Bangkok',
    ),
    GardenLocation(
      id: 'hanoi',
      name: 'Hanoi, Vietnam',
      tagline: 'Old Quarter Warmth',
      description: 'Old quarter alley, hanging lanterns, Hoan Kiem Lake.',
      windowImagePath: 'assets/images/locations/hanoi.png',
      accentPrimary: Color(0xFFFFBF00), // Lantern amber
      accentSecondary: Color(0xFF00A86B), // Jade green
      surfaceColor: Color(0xFFFDF5E6),
      emoji: '🛵',
      timeZone: 'Asia/Ho_Chi_Minh',
    ),
    GardenLocation(
      id: 'jaipur',
      name: 'Jaipur, India',
      tagline: 'The Pink City',
      description: 'Hawa Mahal facade, bustling bazaar, kites.',
      windowImagePath: 'assets/images/locations/jaipur.png',
      accentPrimary: Color(0xFFD67268), // Sandstone pink
      accentSecondary: Color(0xFFEAA221), // Marigold gold
      surfaceColor: Color(0xFFFAEBD7),
      emoji: '🛕',
      timeZone: 'Asia/Kolkata',
    ),
    GardenLocation(
      id: 'melbourne',
      name: 'Melbourne, Australia',
      tagline: 'Street Art & Coffee',
      description: 'Laneway street art, café tables, eucalyptus.',
      windowImagePath: 'assets/images/locations/melbourne.png',
      accentPrimary: Color(0xFF008080), // Graffiti teal
      accentSecondary: Color(0xFF4B3621), // Espresso brown
      surfaceColor: Color(0xFFE0E0E0),
      emoji: '☕',
      timeZone: 'Australia/Melbourne',
    ),
    GardenLocation(
      id: 'queenstown',
      name: 'Queenstown, New Zealand',
      tagline: 'Mountain Lake Calm',
      description: 'Lake Wakatipu, Remarkables mountains, clear sky.',
      windowImagePath: 'assets/images/locations/queenstown.png',
      accentPrimary: Color(0xFFA2C3E0), // Alpine blue
      accentSecondary: Color(0xFF01796F), // Pine green
      surfaceColor: Color(0xFFFFFFFF),
      emoji: '🏔️',
      timeZone: 'Pacific/Auckland',
    ),
    // Europe
    GardenLocation(
      id: 'paris',
      name: 'Paris, France',
      tagline: 'Romantic Morning Light',
      description: 'Mansard rooftops, Eiffel Tower in mist.',
      windowImagePath: 'assets/images/locations/paris.png',
      accentPrimary: Color(0xFFDCAE96), // Dusty rose
      accentSecondary: Color(0xFF808080), // Warm grey
      surfaceColor: Color(0xFFF8F4E6),
      emoji: '🥐',
      timeZone: 'Europe/Paris',
    ),
    GardenLocation(
      id: 'santorini',
      name: 'Santorini, Greece',
      tagline: 'Azure & Whitewash',
      description: 'Blue domes, sparkling Mediterranean.',
      windowImagePath: 'assets/images/locations/santorini.png',
      accentPrimary: Color(0xFF1C39BB), // Aegean blue
      accentSecondary: Color(0xFFFFFFFF), // White
      surfaceColor: Color(0xFFF0F8FF),
      emoji: '🧿',
      timeZone: 'Europe/Athens',
    ),
    GardenLocation(
      id: 'amsterdam',
      name: 'Amsterdam, Netherlands',
      tagline: 'Canal House Cozy',
      description: 'Canal houses, bicycles on a bridge, tulips.',
      windowImagePath: 'assets/images/locations/amsterdam.png',
      accentPrimary: Color(0xFFFFBF00), // Warm amber
      accentSecondary: Color(0xFFAA4A44), // Brick red
      surfaceColor: Color(0xFFF5DEB3),
      emoji: '🚲',
      timeZone: 'Europe/Amsterdam',
    ),
    GardenLocation(
      id: 'lisbon',
      name: 'Lisbon, Portugal',
      tagline: 'Tiled Golden Hour',
      description: 'Alfama rooftops, tram, Tagus river.',
      windowImagePath: 'assets/images/locations/lisbon.png',
      accentPrimary: Color(0xFF005E82), // Azulejo blue
      accentSecondary: Color(0xFFE2725B), // Terracotta
      surfaceColor: Color(0xFFFFFACD),
      emoji: '🚋',
      timeZone: 'Europe/Lisbon',
    ),
    GardenLocation(
      id: 'tuscany',
      name: 'Tuscany, Italy',
      tagline: 'Rolling Hills & Cypress',
      description: 'Cypress-lined hills, vineyard, golden sunset.',
      windowImagePath: 'assets/images/locations/tuscany.png',
      accentPrimary: Color(0xFF556B2F), // Olive green
      accentSecondary: Color(0xFFFFC512), // Sunflower gold
      surfaceColor: Color(0xFFFDF5E6),
      emoji: '🍷',
      timeZone: 'Europe/Rome',
    ),
    GardenLocation(
      id: 'amalfi_coast',
      name: 'Amalfi Coast, Italy',
      tagline: 'Cliffside Lemon Groves',
      description: 'Pastel cliffside houses, lemon trees, sea.',
      windowImagePath: 'assets/images/locations/amalfi_coast.png',
      accentPrimary: Color(0xFFFFF44F), // Lemon yellow
      accentSecondary: Color(0xFF007BA7), // Cerulean
      surfaceColor: Color(0xFFE0FFFF),
      emoji: '🍋',
      timeZone: 'Europe/Rome',
    ),
    GardenLocation(
      id: 'edinburgh',
      name: 'Edinburgh, Scotland',
      tagline: 'Misty Castle Charm',
      description: 'Castle on the hill, cobblestone, soft fog.',
      windowImagePath: 'assets/images/locations/edinburgh.png',
      accentPrimary: Color(0xFF9E7BB5), // Heather purple
      accentSecondary: Color(0xFF9C9C9C), // Warm stone
      surfaceColor: Color(0xFFD3D3D3),
      emoji: '🏰',
      timeZone: 'Europe/London',
    ),
    GardenLocation(
      id: 'prague',
      name: 'Prague, Czech Republic',
      tagline: 'Gothic Gold',
      description: 'Spires, Charles Bridge, Vltava river glow.',
      windowImagePath: 'assets/images/locations/prague.png',
      accentPrimary: Color(0xFFD4AF37), // Baroque gold
      accentSecondary: Color(0xFF6A5ACD), // Slate blue
      surfaceColor: Color(0xFFF5F5DC),
      emoji: '🕰️',
      timeZone: 'Europe/Prague',
    ),
    GardenLocation(
      id: 'bergen',
      name: 'Bergen, Norway',
      tagline: 'Fjord Town Colors',
      description: 'Bryggen wooden houses, fjord, mountains.',
      windowImagePath: 'assets/images/locations/bergen.png',
      accentPrimary: Color(0xFF1E3F66), // Nordic blue
      accentSecondary: Color(0xFFA2231D), // Painted-house red
      surfaceColor: Color(0xFFE6E6FA),
      emoji: '🛥️',
      timeZone: 'Europe/Oslo',
    ),
    GardenLocation(
      id: 'reykjavik',
      name: 'Reykjavik, Iceland',
      tagline: 'Northern Lights Glow',
      description: 'Colorful houses, northern lights, volcanic hills.',
      windowImagePath: 'assets/images/locations/reykjavik.png',
      accentPrimary: Color(0xFF00FF7F), // Aurora green
      accentSecondary: Color(0xFFFFBF00), // Candlelight amber
      surfaceColor: Color(0xFF191970),
      emoji: '🌌',
      timeZone: 'Atlantic/Reykjavik',
    ),
    GardenLocation(
      id: 'dubrovnik',
      name: 'Dubrovnik, Croatia',
      tagline: 'Adriatic Fortress',
      description: 'Red rooftops, fortress walls, Adriatic sea.',
      windowImagePath: 'assets/images/locations/dubrovnik.png',
      accentPrimary: Color(0xFFE2725B), // Terracotta
      accentSecondary: Color(0xFF007FFF), // Deep azure
      surfaceColor: Color(0xFFFFF5EE),
      emoji: '🧱',
      timeZone: 'Europe/Zagreb',
    ),
    // Americas
    GardenLocation(
      id: 'new_york',
      name: 'New York, USA',
      tagline: 'Brownstone & Skyline',
      description: 'Brooklyn rooftop, Manhattan skyline, golden hour.',
      windowImagePath: 'assets/images/locations/new_york.png',
      accentPrimary: Color(0xFF9C2A00), // Warm brick
      accentSecondary: Color(0xFF228B22), // Forest green
      surfaceColor: Color(0xFFF0F0F0),
      emoji: '🍎',
      timeZone: 'America/New_York',
    ),
    GardenLocation(
      id: 'havana',
      name: 'Havana, Cuba',
      tagline: 'Colonial Color & Warmth',
      description: 'Colorful facades, vintage cars, palm trees.',
      windowImagePath: 'assets/images/locations/havana.png',
      accentPrimary: Color(0xFFFF7F50), // Coral
      accentSecondary: Color(0xFF40E0D0), // Turquoise
      surfaceColor: Color(0xFFFFFFE0),
      emoji: '🚗',
      timeZone: 'America/Havana',
    ),
    GardenLocation(
      id: 'buenos_aires',
      name: 'Buenos Aires, Argentina',
      tagline: 'Tango & La Boca',
      description: 'La Boca painted houses, wrought-iron balconies.',
      windowImagePath: 'assets/images/locations/buenos_aires.png',
      accentPrimary: Color(0xFFE32636), // Passion red
      accentSecondary: Color(0xFF0047AB), // Cobalt blue
      surfaceColor: Color(0xFFF5FFFA),
      emoji: '💃',
      timeZone: 'America/Argentina/Buenos_Aires',
    ),
    GardenLocation(
      id: 'oaxaca',
      name: 'Oaxaca, Mexico',
      tagline: 'Indigenous Art & Markets',
      description: 'Colorful market stalls, colonial arches, agave.',
      windowImagePath: 'assets/images/locations/oaxaca.png',
      accentPrimary: Color(0xFFFF00FF), // Magenta
      accentSecondary: Color(0xFFCC5500), // Burnt orange
      surfaceColor: Color(0xFFFFE4B5),
      emoji: '🌵',
      timeZone: 'America/Mexico_City',
    ),
    GardenLocation(
      id: 'medellin',
      name: 'Medellín, Colombia',
      tagline: 'Eternal Spring',
      description: 'Flower-covered hillside, city in the valley.',
      windowImagePath: 'assets/images/locations/medellin.png',
      accentPrimary: Color(0xFFDA70D6), // Orchid purple
      accentSecondary: Color(0xFF00FF00), // Fresh green
      surfaceColor: Color(0xFFE0EEE0),
      emoji: '🌺',
      timeZone: 'America/Bogota',
    ),
    GardenLocation(
      id: 'vancouver',
      name: 'Vancouver, Canada',
      tagline: 'Mountains Meet Ocean',
      description: 'Stanley Park, snow-capped mountains, harbor.',
      windowImagePath: 'assets/images/locations/vancouver.png',
      accentPrimary: Color(0xFF008B8B), // Pacific teal
      accentSecondary: Color(0xFF4A5D23), // Cedar green
      surfaceColor: Color(0xFFF0FFFF),
      emoji: '🌲',
      timeZone: 'America/Vancouver',
    ),
    // Africa & Middle East
    GardenLocation(
      id: 'cape_town',
      name: 'Cape Town, South Africa',
      tagline: 'Dramatic Nature',
      description: 'Table Mountain, ocean, protea flowers.',
      windowImagePath: 'assets/images/locations/cape_town.png',
      accentPrimary: Color(0xFF008080), // Ocean teal
      accentSecondary: Color(0xFFB57EDC), // Fynbos lavender
      surfaceColor: Color(0xFFFDF5E6),
      emoji: '⛰️',
      timeZone: 'Africa/Johannesburg',
    ),
    GardenLocation(
      id: 'zanzibar',
      name: 'Zanzibar, Tanzania',
      tagline: 'Spice Island Breeze',
      description: 'Stone Town rooftops, turquoise water, dhow boats.',
      windowImagePath: 'assets/images/locations/zanzibar.png',
      accentPrimary: Color(0xFF40E0D0), // Turquoise
      accentSecondary: Color(0xFF8B4513), // Spice brown
      surfaceColor: Color(0xFFFFF0F5),
      emoji: '⛵',
      timeZone: 'Africa/Dar_es_Salaam',
    ),
    GardenLocation(
      id: 'marrakech',
      name: 'Marrakech, Morocco',
      tagline: 'Warm Spice & Mosaic',
      description: 'Riad courtyard, orange trees, mosaic fountain.',
      windowImagePath: 'assets/images/locations/marrakech.png',
      accentPrimary: Color(0xFFF4C430), // Saffron
      accentSecondary: Color(0xFF008080), // Teal
      surfaceColor: Color(0xFFFAF0E6),
      emoji: '🕌',
      timeZone: 'Africa/Casablanca',
    ),
    GardenLocation(
      id: 'petra',
      name: 'Petra, Jordan',
      tagline: 'Rose-Red Ancient Wonder',
      description: 'Carved rock facades, desert canyon, warm sky.',
      windowImagePath: 'assets/images/locations/petra.png',
      accentPrimary: Color(0xFFC29285), // Sandstone rose
      accentSecondary: Color(0xFFEDC9AF), // Desert gold
      surfaceColor: Color(0xFFFFE4C4),
      emoji: '🏜️',
      timeZone: 'Asia/Amman',
    ),
  ];

  static GardenLocation? getById(String id) {
    try {
      return registry.firstWhere((loc) => loc.id == id);
    } catch (e) {
      return null;
    }
  }
}
