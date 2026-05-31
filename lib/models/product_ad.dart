

class ProductAd {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String externalLink;
  final List<String> recommendedForSpecies;

  const ProductAd({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.externalLink,
    required this.recommendedForSpecies,
  });

  static const List<ProductAd> mockAds = [
    ProductAd(
      id: 'premium_soil',
      title: 'Premium Aroid Soil Mix',
      description: 'Super chunky, well-draining soil mix designed specifically for Pothos, Monsteras, and Philodendrons to prevent root rot.',
      imageUrl: 'assets/images/aroid_soil.png',
      externalLink: 'https://www.google.com/search?q=premium+aroid+soil+mix',
      recommendedForSpecies: ['pothos', 'monstera', 'philodendron'],
    ),
    ProductAd(
      id: 'brass_can',
      title: 'Brass Long-Spout Watering Can',
      description: 'Elegant copper-coated brass watering can with a long, thin neck for precise watering directly to the roots without wetting leaves.',
      imageUrl: 'assets/images/brass_can.png',
      externalLink: 'https://www.google.com/search?q=brass+long+spout+watering+can',
      recommendedForSpecies: ['pothos', 'boston_fern', 'snake_plant'],
    ),
    ProductAd(
      id: 'moisture_meter',
      title: '3-in-1 Soil Moisture Meter',
      description: 'Instantly measure soil moisture levels. A must-have tool to prevent overwatering your drought-loving Snake Plants.',
      imageUrl: 'assets/images/moisture_meter.png',
      externalLink: 'https://www.google.com/search?q=soil+moisture+meter',
      recommendedForSpecies: ['snake_plant', 'zz_plant', 'succulent'],
    ),
    ProductAd(
      id: 'grow_light',
      title: 'Full Spectrum LED Grow Light',
      description: 'Provide optimal lighting for your indoor plants during winter months. Perfect for high-light species.',
      imageUrl: 'assets/images/grow_light.png',
      externalLink: 'https://www.google.com/search?q=full+spectrum+led+grow+light',
      recommendedForSpecies: ['ficus', 'succulent', 'cactus'],
    ),
  ];

  static List<ProductAd> getRecommendationsFor(String speciesId) {
    return mockAds.where((ad) => ad.recommendedForSpecies.contains(speciesId)).toList();
  }
}
