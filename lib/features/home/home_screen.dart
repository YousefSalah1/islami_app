import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_assets.dart';
import '../hadith/hadith_screen.dart';
import '../azkar/azkar_screen.dart';
import '../radio/radio_screen.dart';
import '../times/times_screen.dart';
import 'quran_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  /// Per-tab background PNGs — one for each tab
  static const List<String> _backgrounds = [
    AppAssets.background_quran,
    AppAssets.background_hadith,
    AppAssets.background_azkar,
    AppAssets.background_radio,
    AppAssets.background_prayer_time,
  ];

  static const List<Widget> _screens = [
    QuranTab(),
    HadithScreen(),
    AzkarScreen(),
    RadioScreen(),
    TimesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Per-tab PNG background with cross-fade on tab switch ──────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: RepaintBoundary(
            key: ValueKey(_selectedIndex),
            child: Image.asset(
              _backgrounds[_selectedIndex],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),

        // ── Dark overlay for text readability ─────────────────────────────
        Container(color: Colors.black.withAlpha(130)),

        // ── Transparent Scaffold ──────────────────────────────────────────
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(index: _selectedIndex, children: _screens),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: [
              _navItem(AppAssets.quranIcon, AppStrings.quranTab, 0),
              _navItem(AppAssets.hadithIcon, AppStrings.hadithTab, 1),
              _navItem(AppAssets.sebhaIcon, AppStrings.azkarTab, 2),
              _navItem(AppAssets.radioIcon, AppStrings.radioTab, 3),
              _navItem(AppAssets.timeIcon, AppStrings.timesTab, 4),
            ],
          ),
        ),
      ],
    );
  }

  BottomNavigationBarItem _navItem(String svgPath, String label, int index) {
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
