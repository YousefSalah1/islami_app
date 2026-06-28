import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_assets.dart';
import '../../core/routes/app_router.dart';
import '../../data/models/surah_model.dart';
import '../../data/repositories/quran_repository.dart';

class QuranTab extends StatefulWidget {
  const QuranTab({super.key});

  @override
  State<QuranTab> createState() => _QuranTabState();
}

class _QuranTabState extends State<QuranTab> {
  final QuranRepository _repository = QuranRepository();
  List<SurahModel> _allSurahs = [];
  List<SurahModel> _filteredSurahs = [];
  final TextEditingController _searchController = TextEditingController();
  
  SurahModel? _lastReadSurah;

  @override
  void initState() {
    super.initState();
    _allSurahs = _repository.getAllSurahs();
    _filteredSurahs = List.from(_allSurahs);
    _loadLastRead();
    
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredSurahs = _allSurahs.where((surah) {
          return surah.englishName.toLowerCase().contains(query) || 
                 surah.arabicName.contains(query);
        }).toList();
      });
    });
  }

  Future<void> _loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final lastIndex = prefs.getInt('last_read_surah_index');
    if (lastIndex != null && lastIndex >= 0 && lastIndex < 114) {
      setState(() {
        _lastReadSurah = _allSurahs[lastIndex];
      });
    }
  }

  Future<void> _saveLastRead(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_surah_index', index);
    _loadLastRead();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Center(
          child: Text(AppStrings.appName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24)),
        ),
        const SizedBox(height: 16),
        
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.blackLight,
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.white),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(AppAssets.quranIcon, width: 24, height: 24, color: AppColors.primary), // We might need to map SVG here if needed, but for now just use a simple icon
                ),
                hintText: AppStrings.suraName,
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),

        // Last Read Banner
        if (_lastReadSurah != null) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Last Read", style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRouter.suraDetails, arguments: _lastReadSurah);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                    image: AssetImage(AppAssets.shape4), // or whichever fits
                    fit: BoxFit.cover,
                    opacity: 0.3,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_lastReadSurah!.englishName, style: const TextStyle(color: AppColors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(_lastReadSurah!.arabicName, style: const TextStyle(color: AppColors.black, fontSize: 16)),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios, color: AppColors.black),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(AppStrings.surasList, style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredSurahs.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.white24, height: 1),
            itemBuilder: (context, index) {
              final surah = _filteredSurahs[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  _saveLastRead(surah.index);
                  Navigator.pushNamed(context, AppRouter.suraDetails, arguments: surah);
                },
                leading: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage(AppAssets.shape7), fit: BoxFit.contain), // Using shape as star equivalent
                  ),
                  child: Text('${surah.index + 1}', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(surah.englishName, style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                subtitle: Text('${surah.versesCount} ${AppStrings.verses}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                trailing: Text(surah.arabicName, style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ),
      ],
    );
  }
}
