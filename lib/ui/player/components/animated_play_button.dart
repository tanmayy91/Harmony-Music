import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';

import '../../widgets/loader.dart';

/// A button that animates between a play and pause icon.
///
/// When playing, a soft pulsing glow ring expands around the button.
/// Also shows a loading indicator when the audio is in a loading state.
class AnimatedPlayButton extends StatefulWidget {
  /// Size of the icon.
  final double iconSize;

  const AnimatedPlayButton({super.key, this.iconSize = 40.0});

  @override
  State<AnimatedPlayButton> createState() => _AnimatedPlayButtonState();
}

class _AnimatedPlayButtonState extends State<AnimatedPlayButton>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseScale = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startPulse() {
    _pulseController.repeat();
  }

  void _stopPulse() {
    _pulseController.stop();
    _pulseController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return GetX<PlayerController>(builder: (controller) {
      final buttonState = controller.buttonState.value;
      final isPlaying = buttonState == PlayButtonState.playing;
      final isLoading = buttonState == PlayButtonState.loading;

      if (isPlaying) {
        _iconController.forward();
        _startPulse();
      } else if (!isLoading) {
        _iconController.reverse();
        _stopPulse();
      }

      final ringColor =
          Theme.of(context).textTheme.titleLarge?.color ?? Colors.white;
      // Ring size slightly bigger than the CircleAvatar (radius 35 → diameter 70)
      const ringSize = 80.0;

      return SizedBox(
        width: ringSize,
        height: ringSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing glow ring — only visible when playing
            if (isPlaying)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) => Opacity(
                  opacity: _pulseOpacity.value,
                  child: Transform.scale(
                    scale: _pulseScale.value,
                    child: Container(
                      width: ringSize,
                      height: ringSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ringColor.withOpacity(0.18),
                      ),
                    ),
                  ),
                ),
              ),
            // The actual icon button
            IconButton(
              iconSize: widget.iconSize,
              onPressed: () {
                isPlaying ? controller.pause() : controller.play();
              },
              icon: isLoading
                  ? const LoadingIndicator(dimension: 20)
                  : AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: _iconController,
                    ),
            ),
          ],
        ),
      );
    });
  }
}
