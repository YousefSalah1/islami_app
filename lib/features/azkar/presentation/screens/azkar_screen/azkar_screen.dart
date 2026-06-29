import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../di/injector.dart';
import '../../../domain/entities/zikr_entity.dart';
import 'bloc/azkar_bloc.dart';
import 'bloc/azkar_contract.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  late final AzkarBloc _bloc = getIt<AzkarBloc>();

  @override
  void initState() {
    super.initState();
    _bloc.eventSink.add(LoadAzkarEvent());
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AzkarState>(
      stream: _bloc.state,
      initialData: AzkarState(isLoading: true),
      builder: (context, snapshot) {
        final state = snapshot.data!;

        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state.categories.isEmpty) {
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
            SvgPicture.asset(
              AppAssets.logoTop,
              height: 52,
            ),
            const SizedBox(height: 10),

            // ── Category chips ─────────────────────────────────────
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final selected = state.selectedCategoryIndex == index;
                  return GestureDetector(
                    onTap: () => _bloc.eventSink.add(SelectCategoryEvent(index)),
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
                        state.categories[index],
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
                    'Zikr ${state.currentZikrIndex + 1} / ${state.currentCategoryZikr.length}',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  TextButton.icon(
                    onPressed: () => _bloc.eventSink.add(ResetZikrEvent()),
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
              child: state.currentZikr == null
                  ? const SizedBox.shrink()
                  : _ZikrView(
                      zikr: state.currentZikr!,
                      tapCount: state.tapCount,
                      targetCount: state.targetCount,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _bloc.eventSink.add(TapZikrEvent());
                      },
                      onNext: () => _bloc.eventSink.add(NextZikrEvent()),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ZikrView extends StatelessWidget {
  final ZikrEntity zikr;
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
