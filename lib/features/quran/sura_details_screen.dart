import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
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

  void _copyVerse(int index) {
    Clipboard.setData(
      ClipboardData(text: '${_verses[index]} ﴿${index + 1}﴾\n— ${widget.surah.arabicName}'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verse copied'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shareVerse(int index) {
    Share.share('${_verses[index]} ﴿${index + 1}﴾\n— سورة ${widget.surah.arabicName}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: Text(widget.surah.englishName),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.share_rounded, color: AppColors.primary),
              onPressed: () =>
                  Share.share('Surah ${widget.surah.englishName} (${widget.surah.arabicName})'),
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Arabic header with decorative corners
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppAssets.leftCorner, width: 72, height: 52, color: AppColors.primary),
              const SizedBox(width: 12),
              Column(
                children: [
                  Text(
                    widget.surah.arabicName,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.janna,
                    ),
                  ),
                  Text(
                    '${widget.surah.versesCount} Verses',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Image.asset(AppAssets.rightCorner, width: 72, height: 52, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(color: Colors.white12),
          const Text(
            'Tap to copy  •  Long press to share',
            style: TextStyle(color: Colors.white30, fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const Divider(color: Colors.white12),
          // Verses list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _verses.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _copyVerse(index),
                        onLongPress: () => _shareVerse(index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${_verses[index]} ﴿${index + 1}﴾',
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 20,
                                  height: 1.9,
                                  fontFamily: AppFonts.janna,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
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
