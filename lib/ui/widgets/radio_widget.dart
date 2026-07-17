import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/focus_timer_notifier.dart';
import '../../services/audio_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';

class RadioWidget extends ConsumerStatefulWidget {
  const RadioWidget({super.key});

  @override
  ConsumerState<RadioWidget> createState() => _RadioWidgetState();
}

class _RadioWidgetState extends ConsumerState<RadioWidget> {
  bool _isPlaying = false;
  bool _showMenu = false;

  void _toggleRadio() {
    HapticFeedback.lightImpact();
    setState(() {
      _isPlaying = !_isPlaying;
    });
    final audio = ref.read(audioServiceProvider);
    if (_isPlaying) {
      audio.playBackgroundMusic();
    } else {
      audio.pauseBackgroundMusic();
    }
  }

  void _toggleMenu() {
    setState(() {
      _showMenu = !_showMenu;
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds / 60).floor();
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final focusState = ref.watch(focusTimerProvider);
    
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        if (_showMenu) const SizedBox(width: 180, height: 260),
        // The Radio Prop
        GestureDetector(
          onTap: _toggleMenu,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B735D),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                  border: Border.all(color: const Color(0xFF4A3C31), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Speaker grill
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        width: 20,
                        height: 2,
                        color: const Color(0xFF4A3C31),
                      )),
                    ),
                    // Dial
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD67C52),
                        shape: BoxShape.circle,
                      ),
                    ).animate(target: _isPlaying ? 1 : 0).rotate(end: 0.2),
                  ],
                ),
              ),
              if (_isPlaying)
                const Positioned(
                  top: -10,
                  right: 5,
                  child: Icon(Icons.music_note, size: 14, color: Color(0xFF2C2520)),
                ).animate(onPlay: (controller) => controller.repeat()).moveY(begin: 0, end: -10, duration: 1.seconds).fadeOut(delay: 500.ms),
            ],
          ),
        ),

        // Floating Menu
        if (_showMenu)
          Positioned(
            bottom: 50,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Lo-fi Radio',
                      style: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                          color: const Color(0xFF5D7A68),
                          iconSize: 32,
                          onPressed: _toggleRadio,
                        ),
                      ],
                    ),
                    const Divider(),
                    const Text(
                      'Focus Mode',
                      style: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Grow plants 1.5x faster!',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(focusState.remainingSeconds),
                      style: const TextStyle(fontFamily: 'OpenSans', fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C2520)),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: focusState.isActive ? Colors.red.shade300 : const Color(0xFFD67C52),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 36),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ref.read(focusTimerProvider.notifier).toggleTimer();
                      },
                      child: Text(focusState.isActive ? 'Give Up' : 'Start Focus'),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0),
            ),
          ),
      ],
    );
  }
}
