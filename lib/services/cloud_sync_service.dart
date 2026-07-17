import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../models/garden.dart';
import '../models/garden_location.dart';
import 'time_manager.dart';

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  return CloudSyncService(ref);
});

class CloudSyncService {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CloudSyncService(this._ref);

  Future<void> syncToCloud(List<Garden> gardens) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Request Notification permissions
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
      String? fcmToken;
      if (settings.authorizationStatus == AuthorizationStatus.authorized || 
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        fcmToken = await FirebaseMessaging.instance.getToken();
      }

      final data = gardens.map((g) => g.toMap()).toList();
      
      DateTime? nextNotificationTime;

      // Calculate next notification time based on plant needs
      for (final garden in gardens) {
        final loc = garden.location;
        if (loc == null) continue; // Skip if location is invalid
        
        for (final plant in garden.plants) {
          // Assume default blinds level of 0.0 for offline estimation
          final timeUntilDry = TimeManager.estimateTimeUntilDry(plant, loc, 0.0);
          final timeUntilGrown = TimeManager.estimateTimeUntilNextStage(plant, loc, 0.0);
          
          if (timeUntilDry != null) {
            final dryTime = DateTime.now().add(timeUntilDry);
            if (nextNotificationTime == null || dryTime.isBefore(nextNotificationTime!)) {
              nextNotificationTime = dryTime;
            }
          }
          if (timeUntilGrown != null && plant.growthStage == 4) { // Only notify when fully grown (reaching stage 5)
            final grownTime = DateTime.now().add(timeUntilGrown);
            if (nextNotificationTime == null || grownTime.isBefore(nextNotificationTime!)) {
              nextNotificationTime = grownTime;
            }
          }
        }
      }
      
      final Map<String, dynamic> updateData = {
        'gardens': jsonEncode(data),
        'last_synced': FieldValue.serverTimestamp(),
      };
      
      if (nextNotificationTime != null && nextNotificationTime!.isAfter(DateTime.now())) {
        updateData['next_notification_time'] = Timestamp.fromDate(nextNotificationTime!);
      } else {
        // Remove the field if no notifications are needed, skipping this user in backend queries
        updateData['next_notification_time'] = FieldValue.delete();
      }
      
      if (fcmToken != null) {
        updateData['fcmToken'] = fcmToken;
      }

      await _firestore.collection('saves').doc(user.uid).set(updateData, SetOptions(merge: true));
      debugPrint('Cloud sync successful (upload)');
    } catch (e) {
      debugPrint('Error syncing to cloud: $e');
    }
  }

  Future<List<Garden>?> syncFromCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('saves').doc(user.uid).get();
      if (!doc.exists) return null;

      final data = doc.data();
      if (data != null && data.containsKey('gardens')) {
        final jsonStr = data['gardens'] as String;
        final List<dynamic> rawList = jsonDecode(jsonStr);
        final List<Garden> gardens = rawList.map((e) => Garden.fromMap(Map<String, dynamic>.from(e))).toList();
        debugPrint('Cloud sync successful (download)');
        return gardens;
      }
    } catch (e) {
      debugPrint('Error syncing from cloud: $e');
    }
    return null;
  }
}
