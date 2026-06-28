import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {"title": "Welcome To Islami App", "body": "", "image": AppAssets.welcome},
    {
      "title": "Welcome To Islami App",
      "body": "We Are Very Excited To Have You In Our Community",
      "image": AppAssets.kabba,
    },
    {
      "title": "Reading the Quran",
      "body": "Read, and your Lord is the Most Generous",
      "image": AppAssets.readingQuran,
    },
    {
      "title": "Bearish",
      "body": "Praise the name of your Lord, the Most High",
      "image": AppAssets.bearish,
    },
    {
      "title": "Holy Quran Radio",
      "body": "You can listen to the Holy Quran Radio through the application for free and easily",
      "image": AppAssets.radio,
    },
  ];

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showHome', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Title replaced by logo
            SvgPicture.asset(AppAssets.logoTop, height: 52),
            const SizedBox(height: 30),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (_, index) {
                  final page = _pages[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      page["image"]!.endsWith('.svg')
                          ? SvgPicture.asset(page["image"]!, height: 300, fit: BoxFit.contain)
                          : Image.asset(page["image"]!, height: 300, fit: BoxFit.contain),
                      const SizedBox(height: 40),
                      Text(
                        page["title"]!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      if (page["body"]!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Text(
                            page["body"]!,
                            style: const TextStyle(fontSize: 18, color: AppColors.primary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 10,
                  width: _currentPage == index ? 25 : 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppColors.primary : Colors.white38,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: const Text(
                      AppStrings.skip,
                      style: TextStyle(color: AppColors.primary, fontSize: 17),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finishOnboarding();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      _currentPage == _pages.length - 1 ? AppStrings.getStarted : AppStrings.next,
                      style: const TextStyle(color: AppColors.primary, fontSize: 17),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
