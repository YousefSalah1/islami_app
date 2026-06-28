import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/hadith_model.dart';

class HadithDetailScreen extends StatelessWidget {
  final HadithModel hadith;
  const HadithDetailScreen({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text('Hadith'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.primary),
            onPressed: () => Share.share('${hadith.title}\n\n${hadith.content}'),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: AppColors.primary),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '${hadith.title}\n\n${hadith.content}'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied!'), backgroundColor: AppColors.primary),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              hadith.title,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withAlpha(80)),
              ),
              child: Text(
                hadith.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
