# Window Garden Idle 🌿🪟

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![State Management](https://img.shields.io/badge/State-Riverpod_2-0D47A1?style=for-the-badge)](https://riverpod.dev)
[![Storage](https://img.shields.io/badge/Storage-Hive_NoSQL-FFA000?style=for-the-badge)](https://docs.hivedb.dev/)
[![Firebase](https://img.shields.io/badge/Cloud-Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

> **Window Garden Idle** is a cozy, offline-first botanical simulation and idle game built with Flutter and Dart. Designed to gently teach real-world botany, phototropism, and species care mechanics, it combines procedural environmental rendering with an asynchronous idle growth engine.

---

## 🌻 The Concept

Transform your digital windowsill into a thriving botanical conservatory. Unlike standard idle games with arbitrary multipliers, **Window Garden Idle** models growth on authentic botanical principles:

- **Photoperiodism & Sunlight Math**: Simulates diurnal sunlight trajectories and window orientation (North, South, East, West) affecting photosynthesis rates.
- **Dynamic Weather & Microclimates**: Real-time atmospheric particle effects (gentle rain, snowfall, overcast gloom) that alter ambient humidity and watering depletion rates.
- **Deep Taxonomy & Field Guide**: Over 10 distinct botanical classes with species-specific care requirements (Bonsai, Medicinal, Culinary, Ornamental, Superfoods, Bog, Aquatic, Ferns, Bulbs, and Tea Herbs).

---

## 🛠️ Software Architecture

```mermaid
flowchart TD
    User["Player Input"] --> UI["UI Layer (Widgets & CustomPaint)"]
    
    subgraph Presentation ["Presentation Layer"]
        UI --> WindowCanvas["Procedural Window Frame & Canvas Particles"]
        UI --> PlantVisualizer["Dynamic Plant Sprite Renderer"]
        UI --> JournalSheet["Botanical Encyclopedia / Journal"]
    end
    
    subgraph StateManagement ["State & Domain Layer (Riverpod)"]
        UI --> Notifiers["GardenNotifier / PlantNotifier / ProfileNotifier"]
        Notifiers --> Engine["Simulation Engine"]
        Engine --> SunlightCalc["Sunlight & Phototropism Service"]
        Engine --> WeatherEngine["Weather & Particle Particle System"]
        Engine --> TimeManager["Offline Growth Catch-Up & Idle Math"]
    end
    
    subgraph DataAccess ["Data & Persistence"]
        Notifiers --> HiveDB[("Hive Local NoSQL DB\n(Fast Binary Storage)")]
        Notifiers -.-> CloudSync["Optional Cloud Sync (Firebase Firestore)"]
    end
```

---

## 🚀 Key Engineering Features

- **Reactive State Management with Riverpod**: Complete decoupling of UI widgets from game logic. Uses `ChangeNotifierProvider` and state selectors to minimize rebuild cycles.
- **Sub-Millisecond NoSQL Storage via Hive**: Pure-Dart key-value storage engine storing plant instances, unlocked species, garden locations, and journal progress with minimal CPU and memory overhead.
- **Procedural Canvas Rendering (`CustomPainter`)**:
  - Procedural wooden/stone window frames dynamically adapting to aspect ratios.
  - GPU-accelerated particle systems rendering animated raindrops, snowflakes, dust motes, and sunlight rays.
- **Adaptive Audio Engine**: Ambient background soundscapes and gentle interactive sound cues using `audioplayers`.
- **Offline Idle Simulation**: Robust time-manager algorithm calculating water consumption, soil drying, and plant growth progression during background or closed-app sessions.
- **Multiplatform Target Support**: First-class compilation profiles for Android, Web (PWA), iOS, and Linux desktop.

---

## 📂 Repository Structure

```text
├── lib/
│   ├── data/           # Botanical taxonomy, species configs, and plant traits
│   ├── models/         # Strongly-typed data models (Plant, Garden, Buff, Weather)
│   ├── services/       # Sunlight calculation, audio, notifications, weather engine
│   ├── state/          # Riverpod notifiers managing app-wide reactive state
│   ├── ui/             # Flutter screens, dialogs, and custom Canvas visualizers
│   └── main.dart       # Application entry point & Hive initialization
├── assets/
│   ├── audio/          # Ambient soundtracks, water splashes, and chimes
│   └── images/         # Hand-crafted pot textures, backgrounds, and frames
├── scripts/            # Asset generation and automation tools
├── test/               # Unit and simulation tests
└── pubspec.yaml        # Flutter manifest, dependencies, and asset definitions
```

---

## 🚦 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0.0 or higher)
- Android SDK (for mobile builds) or Chrome (for web builds)

### Installation & Local Run
```bash
# Clone the repository
git clone https://github.com/Etherdancer/window-garden-idle.git

# Navigate into project directory
cd window-garden-idle

# Fetch pub dependencies
flutter pub get

# Run on Web (Chrome)
flutter run -d chrome

# Or run on connected Android device / emulator
flutter run -d android
```

### Building Releases
```bash
# Compile optimized Android App Bundle (AAB)
flutter build appbundle --release

# Compile optimized Web PWA
flutter build web --release
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
