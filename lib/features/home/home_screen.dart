import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_assets.dart';

import 'quran_tab.dart';

// Placeholder widgets for other tabs (Day 2)
class PlaceholderTab extends StatelessWidget {
  final String title;
  const PlaceholderTab({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Center(child: Text(title, style: TextStyle(color: AppColors.primary, fontSize: 24)));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    QuranTab(),
    PlaceholderTab(title: 'Hadith'),
    PlaceholderTab(title: 'Sebha'),
    PlaceholderTab(title: 'Radio'),
    PlaceholderTab(title: 'Time'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.background, fit: BoxFit.cover),
          ),
          SafeArea(
            child: _tabs[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          _buildNavItem(AppAssets.quranIcon, AppStrings.quranTab, 0),
          _buildNavItem(AppAssets.hadithIcon, AppStrings.hadithTab, 1),
          _buildNavItem(AppAssets.sebhaIcon, AppStrings.sebhaTab, 2),
          _buildNavItem(AppAssets.radioIcon, AppStrings.radioTab, 3),
          _buildNavItem(AppAssets.timeIcon, AppStrings.timesTab, 4),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String svgPath, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blackLight : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SvgPicture.asset(
          svgPath,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            isSelected ? AppColors.white : AppColors.black,
            BlendMode.srcIn,
          ),
        ),
      ),
      label: label,
    );
  }
}
