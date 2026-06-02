import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_controller.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_state.dart';
import 'map_panel.dart';

mixin MapGestureMixin on ConsumerState<MapPanel> {
  MapController get mapController;
  double get currentZoom;
  void triggerMapTap(LatLng point);

  bool isGestureModeActive = false;
  bool isGestureStarting = false;
  Process? _pythonProcess;
  WebSocketChannel? _gestureChannel;

  bool isMouseOverriding = false;
  Timer? _mouseOverrideTimer;

  DateTime _lastSwitchTime = DateTime.now();
  double? _panAnchorX;
  double? _panAnchorY;
  LatLng? _baseCenter;
  double? _zoomAnchorY;
  double? _baseZoom;
  Offset? virtualCursor;
  double? _cursorAnchorX;
  double? _cursorAnchorY;
  String cursorState = 'HIDDEN';
  String _lastGesture = 'IDLE';

  // TOGGLE AI SERVER
  Future<void> toggleGestureMode() async {
    if (isGestureModeActive) {
      await _stopGestureServer();
      setState(() {
        isGestureModeActive = false;
      });
    } else {
      setState(() {
        isGestureStarting = true;
      });

      await _startGestureServer();

      setState(() {
        isGestureStarting = false;
        isGestureModeActive = _gestureChannel != null;
      });
    }
  }

  Future<void> _startGestureServer() async {
    try {
      debugPrint("Đang khởi động Python AI Server...");

      final currentDir = Directory.current.path;
      final parentDir = Directory(currentDir).parent.path;
      final pythonServerDir =
          '$parentDir${Platform.pathSeparator}python_gesture_server';
      final pythonExe = Platform.isWindows
          ? '$pythonServerDir${Platform.pathSeparator}venv${Platform.pathSeparator}Scripts${Platform.pathSeparator}python.exe'
          : '$pythonServerDir${Platform.pathSeparator}venv${Platform.pathSeparator}bin${Platform.pathSeparator}python';
      final scriptPath = 'hand_server.py';

      debugPrint(">> Target Dir: $pythonServerDir");
      debugPrint(">> Target Exe: $pythonExe");

      _pythonProcess = await Process.start(
        pythonExe,
        ['-u', scriptPath],
        workingDirectory: pythonServerDir,
        environment: {'PYTHONUNBUFFERED': '1', 'PYTHONIOENCODING': 'utf-8'},
      );

      final Completer<void> serverReadyCompleter = Completer<void>();

      _pythonProcess?.exitCode.then((code) {
        if (!serverReadyCompleter.isCompleted) {
          serverReadyCompleter.completeError(
            Exception("Python process exited prematurely with code $code"),
          );
        }
      });

      _pythonProcess?.stdout
          .transform(const Utf8Decoder(allowMalformed: true))
          .transform(const LineSplitter())
          .listen((String line) {
            debugPrint("PYTHON LOG: $line");

            if (line.contains("Sẵn sàng") ||
                line.contains("Server Spatial đã chạy")) {
              if (!serverReadyCompleter.isCompleted) {
                serverReadyCompleter.complete();
              }
            }
          });

      _pythonProcess?.stderr
          .transform(const Utf8Decoder(allowMalformed: true))
          .transform(const LineSplitter())
          .listen((String line) {
            if (line.contains("INFO:") ||
                line.startsWith("W0000") ||
                line.contains("WARNING")) {
              return;
            }
            debugPrint("PYTHON LỖI: $line");
          });

      await serverReadyCompleter.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () =>
            throw Exception("Timeout: Python Server mở quá lâu hoặc bị kẹt."),
      );

      debugPrint("Python đã phản hồi sẵn sàng! Đang cắm WebSocket...");

      _gestureChannel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8765'),
      );
      _gestureChannel!.stream.listen(
        (message) => _handleGesture(jsonDecode(message)),
        onError: (error) {
          debugPrint("Lỗi kết nối tay: $error");
          _stopGestureServer();
          if (mounted) setState(() => isGestureModeActive = false);
        },
        onDone: () {
          debugPrint("Đã ngắt kết nối WebSocket.");
          _stopGestureServer();
          if (mounted) setState(() => isGestureModeActive = false);
        },
      );
    } catch (e) {
      debugPrint("KHÔNG THỂ KHỞI TẠO AI SERVER: $e");
      setState(() => isGestureModeActive = false);
    }
  }

  Future<void> _stopGestureServer() async {
    debugPrint("Đang dọn dẹp AI Server...");
    _gestureChannel?.sink.close();
    _gestureChannel = null;

    _pythonProcess?.kill();
    _pythonProcess = null;

    setState(() {
      cursorState = 'HIDDEN';
      isMouseOverriding = false;
    });
  }

  // MOUSE OVERRIDE
  void handleMouseInteraction() {
    if (!isGestureModeActive) return;

    if (!isMouseOverriding) {
      setState(() {
        isMouseOverriding = true;
        cursorState = 'HIDDEN';
      });
    }

    _mouseOverrideTimer?.cancel();
    _mouseOverrideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && isGestureModeActive) {
        setState(() => isMouseOverriding = false);
      }
    });
  }

  void disposeGestureControl() {
    _mouseOverrideTimer?.cancel();
    _stopGestureServer();
  }

  void _handleGesture(Map<String, dynamic> data) {
    if (!mounted || !isGestureModeActive) return;

    if (isMouseOverriding) {
      _panAnchorX = null;
      _panAnchorY = null;
      _baseCenter = null;
      _zoomAnchorY = null;
      _baseZoom = null;
      _cursorAnchorX = null;
      _cursorAnchorY = null;
      return;
    }

    final String gesture = data['gesture'];

    if (gesture == 'HEARTBEAT') return;

    final double x = (data['x'] as num).toDouble();
    final double y = (data['y'] as num).toDouble();
    final size = context.size;

    if (size == null) return;
    virtualCursor ??= Offset(size.width / 2, size.height / 2);

    if (gesture == 'CURSOR') {
      setState(() => cursorState = 'ACTIVE');
      if (_cursorAnchorX == null || _cursorAnchorY == null) {
        _cursorAnchorX = x;
        _cursorAnchorY = y;
      } else {
        final dx = x - _cursorAnchorX!;
        final dy = y - _cursorAnchorY!;
        final double cursorSensitivity = 1.8;
        double newX = virtualCursor!.dx + (dx * size.width * cursorSensitivity);
        double newY =
            virtualCursor!.dy + (dy * size.height * cursorSensitivity);
        virtualCursor = Offset(
          newX.clamp(0.0, size.width),
          newY.clamp(0.0, size.height),
        );
        _cursorAnchorX = x;
        _cursorAnchorY = y;
      }
    } else {
      _cursorAnchorX = null;
      _cursorAnchorY = null;
    }

    if (gesture == 'CLICK') {
      setState(() => cursorState = 'ACTIVE');
      if (_lastGesture != 'CLICK' && virtualCursor != null) {
        final latlng = mapController.camera.offsetToCrs(virtualCursor!);
        triggerMapTap(latlng);
      }
    }

    if (gesture == 'IDLE') {
      if (_lastGesture == 'CURSOR' ||
          _lastGesture == 'CLICK' ||
          cursorState == 'CLUTCHING') {
        setState(() => cursorState = 'CLUTCHING');
      } else {
        setState(() => cursorState = 'HIDDEN');
      }
      _panAnchorX = null;
      _panAnchorY = null;
      _baseCenter = null;
      _zoomAnchorY = null;
      _baseZoom = null;
    }

    if (gesture == 'PAN') {
      setState(() => cursorState = 'HIDDEN');
      _zoomAnchorY = null;
      if (_panAnchorX == null || _panAnchorY == null || _baseCenter == null) {
        _panAnchorX = x;
        _panAnchorY = y;
        _baseCenter = mapController.camera.center;
      } else {
        final panSensitivity = 2.0 * math.pow(2, 12.0 - currentZoom);
        final dx = (_panAnchorX! - x) * panSensitivity;
        final dy = (y - _panAnchorY!) * panSensitivity;
        final targetLat = _baseCenter!.latitude + dy;
        final targetLng = _baseCenter!.longitude + dx;
        double smoothing = currentZoom > 10.0
            ? math.max(0.05, 1.0 - ((currentZoom - 10.0) / 10.0))
            : 1.0;
        final cLat = mapController.camera.center.latitude;
        final cLng = mapController.camera.center.longitude;
        mapController.move(
          LatLng(
            cLat + (targetLat - cLat) * smoothing,
            cLng + (targetLng - cLng) * smoothing,
          ),
          currentZoom,
        );
      }
    } else if (gesture == 'ZOOM') {
      setState(() => cursorState = 'HIDDEN');
      _panAnchorX = null;
      _panAnchorY = null;
      _baseCenter = null;
      if (_zoomAnchorY == null || _baseZoom == null) {
        _zoomAnchorY = y;
        _baseZoom = mapController.camera.zoom;
      } else {
        final dy = _zoomAnchorY! - y;
        if (dy.abs() > 0.01) {
          mapController.move(
            mapController.camera.center,
            (_baseZoom! + (dy * (8.0 * (20.0 / _baseZoom!)))).clamp(5.5, 20.0),
          );
        }
      }
    } else if (gesture == 'SWITCH') {
      setState(() => cursorState = 'HIDDEN');
      _panAnchorX = null;
      _panAnchorY = null;
      _baseCenter = null;
      _zoomAnchorY = null;
      final now = DateTime.now();
      if (now.difference(_lastSwitchTime).inMilliseconds > 2000) {
        _lastSwitchTime = now;
        final cur = ref.read(mapStatsControllerProvider).currentMapMode;
        ref
            .read(mapStatsControllerProvider.notifier)
            .changeMapMode(
              cur == MapViewMode.minimal
                  ? MapViewMode.satellite
                  : (cur == MapViewMode.satellite
                        ? MapViewMode.street
                        : MapViewMode.minimal),
            );
      }
    }

    _lastGesture = gesture;
  }
}
