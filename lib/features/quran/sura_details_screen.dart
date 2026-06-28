import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_assets.dart';
import '../../data/models/surah_model.dart';
import '../../data/repositories/quran_repository.dart';

class SuraDetailsScreen extends StatefulWidget {
  final SurahModel surah;
  const SuraDetailsScreen({super.key, required this.surah});

  @override
  State<SuraDetailsScreen> createState() => _SuraDetailsScreenState();
}

class _SuraDetailsScreenState extends State<SuraDetailsScreen> {
  final QuranRepository _repository = QuranRepository();
  List<String> _verses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVerses();
  }

  Future<void> _loadVerses() async {
    final verses = await _repository.getSurahVerses(widget.surah.index);
    if (mounted) {
      setState(() {
        _verses = verses;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: Text(widget.surah.englishName),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppAssets.leftCorner, width: 80, height: 60, color: AppColors.primary),
              const SizedBox(width: 16),
              Text(
                widget.surah.arabicName,
                style: const TextStyle(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Image.asset(AppAssets.rightCorner, width: 80, height: 60, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _verses.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          '${_verses[index]} ﴿${index + 1}﴾',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(color: AppColors.primary, fontSize: 22, height: 1.8),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
