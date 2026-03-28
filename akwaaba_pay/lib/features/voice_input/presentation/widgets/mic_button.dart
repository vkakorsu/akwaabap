import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MicButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onTap;
  final double size;

  const MicButton({
    super.key,
    required this.isRecording,
    required this.onTap,
    this.size = 80,
  });

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(MicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isRecording && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PulseAnimatedBuilder(
      listenable: _pulseAnimation,
      builder: (context, child) {
        final scale = widget.isRecording ? _pulseAnimation.value : 1.0;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isRecording
                  ? AppColors.micActiveGradient
                  : AppColors.micGradient,
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.isRecording ? AppColors.secondary : AppColors.primary)
                    .withValues(alpha: 0.4),
                blurRadius: widget.isRecording ? 24 : 12,
                spreadRadius: widget.isRecording ? 4 : 0,
              ),
            ],
          ),
          child: Icon(
            widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
            color: Colors.white,
            size: widget.size * 0.45,
          ),
        ),
      ),
    );
  }
}

class PulseAnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const PulseAnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
