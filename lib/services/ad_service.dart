import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;

class AdService {
  // Launches external URL to product recommendations.
  // Before launching, it triggers a callback to pause the time calculations of the game.
  // After returning (or on failure), it triggers a callback to resume.
  static Future<bool> launchProductLink({
    required String url,
    required Function() onBeforeLaunch,
    required Function() onAfterLaunch,
  }) async {
    final Uri uri = Uri.parse(url);
    
    // 1. Pause active game calculations
    developer.log('Pausing game clock before outbound link redirect.');
    onBeforeLaunch();

    try {
      if (await canLaunchUrl(uri)) {
        // Launch in external application/browser
        final bool success = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        // 2. Resume game calculations after launching triggers
        onAfterLaunch();
        return success;
      } else {
        developer.log('Could not launch URL: $url');
        onAfterLaunch();
        return false;
      }
    } catch (e) {
      developer.log('Error launching product URL: $e');
      // Ensure we resume calculations even if launch throws an exception
      onAfterLaunch();
      return false;
    }
  }
}
