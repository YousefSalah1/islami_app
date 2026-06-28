import 'package:flutter/material.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/quran/sura_details_screen.dart';
import '../../data/models/surah_model.dart';

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
        return MaterialPageRoute(builder: (_) => SuraDetailsScreen(surah: surah));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
