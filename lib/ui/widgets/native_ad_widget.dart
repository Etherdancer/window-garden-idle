import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/product_ad.dart';
import '../../state/plant_notifier.dart';

class NativeAdWidget extends ConsumerStatefulWidget {
  final ProductAd ad;

  const NativeAdWidget({super.key, required this.ad});

  @override
  ConsumerState<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends ConsumerState<NativeAdWidget> with WidgetsBindingObserver {
  bool _launchedAd = false;

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
    if (state == AppLifecycleState.resumed && _launchedAd) {
      _launchedAd = false;
      // Resume simulation!
      final notifier = ref.read(plantListProvider.notifier);
      ref.read(gamePausedProvider.notifier).state = false;
      notifier.resumeSimulation();
    }
  }

  Future<void> _handleAdRedirect() async {
    final notifier = ref.read(plantListProvider.notifier);
    
    // Pause the game clock before redirecting
    ref.read(gamePausedProvider.notifier).state = true;
    notifier.pauseSimulation();
    setState(() {
      _launchedAd = true;
    });

    final uri = Uri.parse(widget.ad.externalLink);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch product link.')),
          );
        }
        _cleanupFailedRedirect();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error launching product link.')),
        );
      }
      _cleanupFailedRedirect();
    }
  }

  void _cleanupFailedRedirect() {
    ref.read(gamePausedProvider.notifier).state = false;
    ref.read(plantListProvider.notifier).resumeSimulation();
    setState(() {
      _launchedAd = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5F0), // Soft cream/paper tone
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE4DCD3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Row(
            children: [
              const Icon(
                Icons.eco,
                color: Color(0xFF5D7A68), // Soft forest green
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'BOTANIST RECOMMENDS',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: const Color(0xFF5D7A68).withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Ad Content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon/Image Mock Placeholder
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFECE6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE4DCD3),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: Color(0xFF8A8279),
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.ad.title,
                      style: const TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2520), // Soft off-black
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.ad.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF6E645A), // Warm dark gray
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // Divider
          Container(
            height: 1,
            color: const Color(0xFFE4DCD3),
          ),
          const SizedBox(height: 12),
          
          // Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Outbound Product Link',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF8A8279).withValues(alpha: 0.8),
                ),
              ),
              ElevatedButton(
                onPressed: _handleAdRedirect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D7A68),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Product',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.open_in_new, size: 12),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
