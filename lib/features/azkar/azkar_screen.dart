import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../sebha/providers/sebha_provider.dart';
import '../../data/models/zikr_model.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SebhaProvider>();

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (provider.categories.isEmpty) {
      return const Center(
        child: Text(
          'No azkar found',
          style: TextStyle(color: AppColors.primary),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 14),
        const Text(
          'الأذكار',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        // ── Category chips ─────────────────────────────────────
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final selected = provider.selectedCategoryIndex == index;
              return GestureDetector(
                onTap: () => provider.selectCategory(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.primary.withAlpha(100)),
                  ),
                  child: Text(
                    provider.categories[index],
                    style: TextStyle(
                      color: selected ? AppColors.black : AppColors.primary,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 6),

        // ── Progress info ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Zikr ${provider.currentZikrIndex + 1} / ${provider.currentCategoryZikr.length}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              TextButton.icon(
                onPressed: provider.reset,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 15,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'Reset',
                  style: TextStyle(color: AppColors.primary, fontSize: 12),
                ),
                style: TextButton.styleFrom(padding: const EdgeInsets.all(4)),
              ),
            ],
          ),
        ),

        // ── Zikr view ──────────────────────────────────────────
        Expanded(
          child: provider.currentZikr == null
              ? const SizedBox.shrink()
              : _ZikrView(
                  zikr: provider.currentZikr!,
                  tapCount: provider.tapCount,
                  targetCount: provider.targetCount,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    provider.tap();
                  },
                  onNext: provider.nextZikr,
                ),
        ),
      ],
    );
  }
}

class _ZikrView extends StatelessWidget {
  final ZikrModel zikr;
  final int tapCount;
  final int targetCount;
  final VoidCallback onTap;
  final VoidCallback onNext;

  const _ZikrView({
    required this.zikr,
    required this.tapCount,
    required this.targetCount,
    required this.onTap,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final progress = targetCount > 0
        ? (tapCount / targetCount).clamp(0.0, 1.0)
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final ringSize = (constraints.maxWidth * 0.30).clamp(90.0, 130.0);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Column(
            children: [
              // Zikr text card — takes remaining space
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withAlpha(60)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Text(
                          zikr.content,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            height: 1.9,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                        if (zikr.description.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            zikr.description,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Counter ring — tap to count
              GestureDetector(
                onTap: onTap,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: ringSize,
                      height: ringSize,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 7,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$tapCount',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: ringSize * 0.26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '/ $targetCount',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Next button
              GestureDetector(
                onTap: onNext,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.primary.withAlpha(120)),
                  ),
                  child: const Text(
                    'التالي',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
