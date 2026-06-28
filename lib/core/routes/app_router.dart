import 'package:flutter/material.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/quran/sura_details_screen.dart';
import '../../features/hadith/hadith_detail_screen.dart';
import '../../data/models/surah_model.dart';
import '../../data/models/hadith_model.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String suraDetails = '/sura_details';
  static const String hadithDetails = '/hadith_details';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case suraDetails:
        final surah = settings.arguments as SurahModel;
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => SuraDetailsScreen(surah: surah),
          transitionsBuilder: (_, animation, __, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 350),
        );
      case hadithDetails:
        final hadith = settings.arguments as HadithModel;
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => HadithDetailScreen(hadith: hadith),
          transitionsBuilder: (_, animation, __, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 350),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text('No route: ${settings.name}'))),
        );
    }
  }
}
