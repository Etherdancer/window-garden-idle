import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'garden_notifier.dart';

class FocusTimerState {
  final bool isActive;
  final int remainingSeconds;
  final DateTime? endTime;
  
  const FocusTimerState({
    required this.isActive,
    required this.remainingSeconds,
    this.endTime,
  });

  FocusTimerState copyWith({
    bool? isActive,
    int? remainingSeconds,
    DateTime? endTime,
  }) {
    return FocusTimerState(
      isActive: isActive ?? this.isActive,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      endTime: endTime ?? this.endTime,
    );
  }
}

class FocusTimerNotifier extends StateNotifier<FocusTimerState> {
  final Ref _ref;
  Timer? _timer;
  static const int defaultDurationSeconds = 25 * 60; // 25 minutes

  FocusTimerNotifier(this._ref) : super(const FocusTimerState(isActive: false, remainingSeconds: defaultDurationSeconds));

  void startTimer() {
    if (state.isActive) return;
    
    final endTime = DateTime.now().add(const Duration(seconds: defaultDurationSeconds));
    state = state.copyWith(isActive: true, remainingSeconds: defaultDurationSeconds, endTime: endTime);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isActive || state.endTime == null) return;
      
      final now = DateTime.now();
      if (now.isBefore(state.endTime!)) {
        state = state.copyWith(remainingSeconds: state.endTime!.difference(now).inSeconds);
      } else {
        stopTimer();
        // Play a nice success notification
        _ref.read(notificationServiceProvider).showNotification(
          id: 888,
          title: '🍅 Focus Session Complete!',
          body: 'Great job! Your plants grew 50% faster while you were deeply focused.',
        );
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    state = const FocusTimerState(isActive: false, remainingSeconds: defaultDurationSeconds);
  }

  void toggleTimer() {
    if (state.isActive) {
      stopTimer();
    } else {
      startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusTimerProvider = StateNotifierProvider<FocusTimerNotifier, FocusTimerState>((ref) {
  return FocusTimerNotifier(ref);
});
