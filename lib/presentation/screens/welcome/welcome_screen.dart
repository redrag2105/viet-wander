import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/split_option_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SplitOptionButton(
              title: 'THỐNG KÊ BẢN ĐỒ',
              subtitle: 'Tra cứu dữ liệu địa lý 34 tỉnh thành Việt Nam',
              imageUrl: 'assets/images/map_stats.png',
              onTap: () {
                context.go('/map-stats');
              },
            ),
          ),

          Container(height: 1, color: const Color(0xFF0F172A)),

          Expanded(
            child: SplitOptionButton(
              title: 'LỊCH TRÌNH PHƯỢT',
              subtitle: 'Thiết kế chuyến đi hoàn hảo của riêng bạn',
              imageUrl: 'assets/images/phuot.png',
              onTap: () {
                context.go('/road-trip');
              },
            ),
          ),
        ],
      ),
    );
  }
}
