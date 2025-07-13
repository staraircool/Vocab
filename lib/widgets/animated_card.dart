import 'package:flutter/material.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final Duration animationDuration;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) {
        _scaleController.forward();
      },
      onPanEnd: (details) {
        _scaleController.reverse();
        
        if (details.velocity.pixelsPerSecond.dx > 300) {
          // Swipe right
          _slideToRight();
        } else if (details.velocity.pixelsPerSecond.dx < -300) {
          // Swipe left
          _slideToLeft();
        }
      },
      onTap: () {
        _scaleController.forward().then((_) {
          _scaleController.reverse();
        });
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_slideController, _scaleController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SlideTransition(
              position: _slideAnimation,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }

  void _slideToLeft() {
    _slideController.forward().then((_) {
      if (widget.onSwipeLeft != null) {
        widget.onSwipeLeft!();
      }
      _slideController.reset();
    });
  }

  void _slideToRight() {
    _slideController.forward().then((_) {
      if (widget.onSwipeRight != null) {
        widget.onSwipeRight!();
      }
      _slideController.reset();
    });
  }

  void resetAnimation() {
    _slideController.reset();
    _scaleController.reset();
  }
}

