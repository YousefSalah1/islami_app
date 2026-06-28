import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_assets.dart';
import '../hadith/providers/hadith_provider.dart';
import '../../data/models/hadith_model.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HadithProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.primary, size: 48),
            const SizedBox(height: 12),
            Text(provider.errorMessage!, style: const TextStyle(color: AppColors.primary)),
          ],
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          'الحديث الشريف',
          style: TextStyle(color: AppColors.primary, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: PageView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: provider.ahadith.length,
            itemBuilder: (context, index) {
              return _HadithCard(hadith: provider.ahadith[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _HadithCard extends StatelessWidget {
  final HadithModel hadith;
  const _HadithCard({required this.hadith});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/hadith_details', arguments: hadith),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Container(
          width: double.infinity,
          height: size.height * 0.65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: AssetImage(AppAssets.hadithCardBg),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC000000)],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  hadith.title,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  hadith.content,
                  style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.8),
                  textAlign: TextAlign.center,
                  maxLines: 6,
                  overflow: TextOverflow.fade,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActionButton(
                      icon: Icons.copy_rounded,
                      label: 'Copy',
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: '${hadith.title}\n\n${hadith.content}'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard'), backgroundColor: AppColors.primary),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    _ActionButton(
                      icon: Icons.share_rounded,
                      label: 'Share',
                      onTap: () => Share.share('${hadith.title}\n\n${hadith.content}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(200),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.black, size: 18),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
