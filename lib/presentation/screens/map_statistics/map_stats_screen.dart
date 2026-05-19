import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_controller.dart';
import 'package:viet_wander/presentation/screens/map_statistics/widgets/map_panel/map_controls.dart';
import 'widgets/map_panel/map_panel.dart';

class MapStatsScreen extends ConsumerStatefulWidget {
  const MapStatsScreen({super.key});

  @override
  ConsumerState<MapStatsScreen> createState() => _MapStatsScreenState();
}

class _MapStatsScreenState extends ConsumerState<MapStatsScreen>
    with TickerProviderStateMixin {
  double _expandedWidth = 420.0;
  bool _isDragging = false;
  static const double _minWidth = 400.0;
  static const double _maxWidth = 650.0;

  late AnimationController _lottieController;
  bool _isMapReady = false;
  bool _isLottieFinished = false;
  bool _shouldFadeOut = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _isMapReady = true);
      });
    });

    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_isMapReady) {
          setState(() => _shouldFadeOut = true);
        } else {
          _lottieController.repeat();
        }
      }
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSidebarOpen = ref.watch(
      mapStatsControllerProvider.select((state) => state.isSidebarOpen),
    );

    final controller = ref.read(mapStatsControllerProvider.notifier);

    final actualWidth = isSidebarOpen ? _expandedWidth : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          // MAIN UI
          AnimatedOpacity(
            duration: const Duration(milliseconds: 600),
            opacity: _isMapReady ? 1.0 : 0.0,
            child: Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: MapPanel(rightMargin: actualWidth),
                  ),
                ),
                MapSidebarControls(
                  actualWidth: actualWidth,
                  expandedWidth: _expandedWidth,
                  isSidebarOpen: isSidebarOpen,
                  isDragging: _isDragging,
                  onBackTap: () => context.go('/welcome'),
                  onToggleSidebar: controller.toggleSidebar,
                  onDragStart: () => setState(() => _isDragging = true),
                  onDragUpdate: (details) {
                    final newWidth = _expandedWidth - details.delta.dx;
                    if (newWidth < _minWidth - 10) {
                      // auto close if dragged beyond minWidth significantly
                      if (isSidebarOpen) controller.toggleSidebar();
                    } else {
                      setState(() {
                        _expandedWidth = newWidth.clamp(_minWidth, _maxWidth);
                      });
                    }
                  },
                  onDragEnd: () => setState(() => _isDragging = false),
                ),
              ],
            ),
          ),

          // LOADING OVERLAY
          if (!_isLottieFinished)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: _shouldFadeOut ? 0.0 : 1.0,
              onEnd: () {
                if (_shouldFadeOut) setState(() => _isLottieFinished = true);
              },
              child: Container(
                color: const Color(0xFF020617),
                child: Center(
                  child: Lottie.asset(
                    'assets/lotties/loading_globe.json',
                    controller: _lottieController,
                    onLoaded: (composition) {
                      _lottieController.duration = composition.duration;
                      _lottieController.forward();
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
