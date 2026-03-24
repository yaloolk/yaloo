import 'dart:math' show cos, sin;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:yaloo/core/constants/colors.dart';

class FloatingChatButton extends StatefulWidget {
  const FloatingChatButton({super.key});

  @override
  State<FloatingChatButton> createState() => _FloatingChatButtonState();
}

class _FloatingChatButtonState extends State<FloatingChatButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          // TODO: Open Chat AI
          _animateTap();
        },
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow rings
                ...List.generate(3, (index) {
                  final delay = index * 0.3;
                  final progress = (_pulseController.value + delay) % 1.0;
                  final opacity = (1 - progress) * 0.3;
                  final scale = 1.0 + (progress * 0.8);

                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 64.w,
                        height: 64.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryBlue.withOpacity(0.5),
                            width: 2.w,
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Main button with glassmorphism
                Transform.scale(
                  scale: _isHovered ? 1.05 : _pulseAnimation.value,
                  child: Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryBlue,
                          AppColors.primaryBlue.withBlue(180),
                          const Color(0xFF1E40AF),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        // Soft ambient shadow
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.3),
                          blurRadius: 20.r,
                          spreadRadius: 2.r,
                          offset: const Offset(0, 8),
                        ),
                        // Sharp inner glow
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 10.r,
                          spreadRadius: -2.r,
                          offset: const Offset(-2, -2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _isHovered
                                  ? Icon(
                                LucideIcons.sparkles,
                                color: Colors.white,
                                size: 28.w,
                                key: const ValueKey('sparkles'),
                              )
                                  : RotationTransition(
                                turns: _rotateAnimation,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // AI Core
                                    Icon(
                                      LucideIcons.bot,
                                      color: Colors.white,
                                      size: 28.w,
                                    ),
                                    // Orbital dots
                                    ...List.generate(3, (index) {
                                      final angle = (index * 120 +
                                          (_pulseController.value * 360)) *
                                          (3.14159 / 180);
                                      return Transform.translate(
                                        offset: Offset(
                                          18.w * cos(angle),
                                          18.w * sin(angle),
                                        ),
                                        child: Container(
                                          width: 4.w,
                                          height: 4.w,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Status indicator
                Positioned(
                  right: 2.w,
                  top: 2.w,
                  child: Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.4),
                          blurRadius: 6.r,
                          spreadRadius: 1.r,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _animateTap() {
    // Add haptic feedback and tap animation
    HapticFeedback.mediumImpact();
    // Navigate to chat or show modal
  }
}