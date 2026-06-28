import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: AppColors.transparent),
  );

  final prefs = await SharedPreferences.getInstance();
  final bool showOnboarding = prefs.getBool('showHome') != true;

  runApp(
    MultiProvider(
      providers: [
        // Providers will be implemented in Day 2
        Provider.value(value: prefs),
      ],
      child: MyApp(showOnboarding: showOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Islami App',
      theme: AppTheme.darkTheme,
      home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
