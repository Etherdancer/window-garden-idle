import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/audio_service.dart';
import 'services/cloud_sync_service.dart';
import 'state/garden_notifier.dart';
import 'ui/main_game_screen.dart';
import 'ui/welcome_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tz.initializeTimeZones();

  // 1. Allow both Portrait and Landscape orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // 2. Initialize Hive local database (registers both PlantAdapter & GardenAdapter)
  final storage = StorageService();
  await storage.init();

  // 3. Initialize Local Notifications
  final notifications = NotificationService();
  await notifications.init();
  await notifications.requestPermissions();

  // 4. Initialize Audio Service and start Background Music
  final audioService = AudioService();
  await audioService.init();
  audioService.playBackgroundMusic();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
        notificationServiceProvider.overrideWithValue(notifications),
        audioServiceProvider.overrideWithValue(audioService),
      ],
      child: const WindowGardenApp(),
    ),
  );
}

class WindowGardenApp extends StatelessWidget {
  const WindowGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Window Garden Idle',
      debugShowCheckedModeBanner: false,

      // Cozy, warm, premium theme setup
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D7A68), // Forest green seed
          primary: const Color(0xFF5D7A68),
          secondary: const Color(0xFFD67C52), // Terracotta clay accent
          surface: const Color(0xFFF3EFE9), // Creamy soft white
        ),

        // Define global text themes using Google Fonts
        textTheme: GoogleFonts.openSansTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.playfairDisplay(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.playfairDisplay(
            textStyle: Theme.of(context).textTheme.titleLarge,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: GoogleFonts.openSans(
            textStyle: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),

      home: const RootScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// RootScreen — routes to WelcomeScreen or MainGameScreen based on save data
// ---------------------------------------------------------------------------

class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({super.key});

  @override
  ConsumerState<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<RootScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final audioService = ref.read(audioServiceProvider);
    final cloudSync = ref.read(cloudSyncServiceProvider);
    
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
      audioService.pauseBackgroundMusic();
      cloudSync.syncToCloud(ref.read(gardenListProvider));
    } else if (state == AppLifecycleState.resumed) {
      audioService.resumeBackgroundMusic();
      cloudSync.syncFromCloud().then((gardens) {
        if (gardens != null) {
          ref.read(gardenListProvider.notifier).loadFromCloud(gardens);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gardens = ref.watch(gardenListProvider);

    if (gardens.isEmpty) {
      return const WelcomeScreen();
    }

    return const MainGameScreen();
  }
}


