import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_assets.dart';
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
        _filteredSurahs = query.isEmpty
            ? List.from(_allSurahs)
            : _allSurahs.where((s) {
                return s.englishName.toLowerCase().contains(query) ||
                    s.arabicName.contains(query) ||
                    s.index.toString() == query;
              }).toList();
      });
    });
  }

  Future<void> _loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final lastIndex = prefs.getInt('last_read_surah_index');
    if (lastIndex != null && lastIndex >= 0 && lastIndex < 114) {
      if (mounted) setState(() => _lastReadSurah = _allSurahs[lastIndex]);
    }
  }

  Future<void> _saveLastRead(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_surah_index', index);
    if (mounted) setState(() => _lastReadSurah = _allSurahs[index]);
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
        const SizedBox(height: 12),
        Center(
          child: SvgPicture.asset(
            AppAssets.logoTop,
            height: 52,
          ),
        ),
        const SizedBox(height: 12),

        // Search bar (fixed: uses Icon instead of broken SVG Image.asset)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0x99202020),
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.white),
              cursorColor: AppColors.primary,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
                hintText: AppStrings.suraName,
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Last Read Banner
        if (_lastReadSurah != null) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Last Read',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/sura_details', arguments: _lastReadSurah);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _lastReadSurah!.englishName,
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_lastReadSurah!.versesCount} ${AppStrings.verses}',
                          style: const TextStyle(color: Color(0xFF404040), fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      _lastReadSurah!.arabicName,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.surasList,
            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 6),

        // Sura list
        Expanded(
          child: _filteredSurahs.isEmpty
              ? const Center(
                  child: Text('No suras found', style: TextStyle(color: Colors.white54)),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _filteredSurahs.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, index) {
                    final surah = _filteredSurahs[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        _saveLastRead(surah.index);
                        Navigator.pushNamed(context, '/sura_details', arguments: surah);
                      },
                      leading: SizedBox(
                        width: 44,
                        height: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset(
                              AppAssets.suraNum,
                              width: 44,
                              height: 44,
                            ),
                            Text(
                              '${surah.index + 1}',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      title: Text(
                        surah.englishName,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${surah.versesCount} ${AppStrings.verses}',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      trailing: Text(
                        surah.arabicName,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
