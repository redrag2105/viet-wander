import 'package:flutter/material.dart';

class MapGestureToggle extends StatefulWidget {
  final bool isDarkMode;
  final bool isActive;
  final bool isMouseOverriding;
  final bool isLoading;
  final VoidCallback onToggle;

  const MapGestureToggle({
    super.key,
    required this.isDarkMode,
    required this.isActive,
    required this.isMouseOverriding,
    required this.isLoading,
    required this.onToggle,
  });

  @override
  State<MapGestureToggle> createState() => _MapGestureToggleState();
}

class _MapGestureToggleState extends State<MapGestureToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isLoading) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(MapGestureToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat(reverse: true);
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isMouseOverriding
        ? Colors.orange
        : (widget.isActive || widget.isLoading
              ? const Color(0xFF38BDF8)
              : (widget.isDarkMode ? Colors.white70 : Colors.black54));

    return Tooltip(
      message: widget.isLoading
          ? 'Đang kết nối không gian AI...'
          : (widget.isActive ? 'Điều khiển Cử chỉ (AI)' : 'Điều khiển Chuột'),
      child: Material(
        color: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onToggle,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: widget.isLoading ? _fadeAnimation.value : 1.0,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (widget.isActive || widget.isLoading)
                          ? const Color(0xFF38BDF8).withValues(alpha: 0.5)
                          : (widget.isDarkMode
                                ? Colors.white12
                                : Colors.black12),
                    ),
                  ),
                  child: Icon(
                    widget.isActive || widget.isLoading
                        ? Icons.back_hand_rounded
                        : Icons.mouse_rounded,
                    size: 22,
                    color: iconColor,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
