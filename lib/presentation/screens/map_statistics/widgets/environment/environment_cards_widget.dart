import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:viet_wander/data/providers/environment_provider.dart';

class EnvironmentCardsWidget extends ConsumerWidget {
  final LatLng location;

  const EnvironmentCardsWidget({super.key, required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(environmentControllerProvider(location));

    return asyncData.when(
      loading: () => const SizedBox(
        height: 110,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF38BDF8),
            strokeWidth: 2,
          ),
        ),
      ),
      error: (err, stack) => const SizedBox(
        height: 110,
        child: Center(
          child: Text(
            'Không thể tải dữ liệu',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
      ),
      data: (data) {
        if (data == null) return const SizedBox.shrink();

        final aqiInfo = data.aqiInfo;

        return SizedBox(
          height: 110,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.only(right: 16),
              children: [
                // DEGREE
                _buildElegantCard(
                  child: Row(
                    children: [
                      Image.network(
                        'https://openweathermap.org/img/wn/${data.iconCode}@2x.png',
                        width: 56,
                        height: 56,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.cloud,
                          color: Colors.white24,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data.temperature.round()}°',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              data.description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white60,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // AQI
                _buildElegantCard(
                  accentColor: aqiInfo.color,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chỉ số AQI',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white60,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${data.aqi}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: aqiInfo.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              aqiInfo.status,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: aqiInfo.color.withValues(alpha: 0.8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // HUMIDITY & RAIN
                _buildElegantCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoRow(
                        icon: Icons.water_drop_outlined,
                        text: 'Độ ẩm: ${data.humidity}%',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.umbrella_outlined,
                        text: 'Mưa: ${data.rain1h} mm',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildElegantCard({required Widget child, Color? accentColor}) {
    final baseColor = accentColor ?? Colors.white;
    return Container(
      width: 175,
      margin: const EdgeInsets.only(left: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.withValues(alpha: 0.08),
            baseColor.withValues(alpha: 0.02),
          ],
        ),
        border: Border.all(color: baseColor.withValues(alpha: 0.1), width: 1),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
