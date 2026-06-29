import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../di/injector.dart';
import 'bloc/hadith_bloc.dart';
import 'bloc/hadith_contract.dart';
import '../../../data/models/hadith_model.dart'; // We should pass Entity, but for now Model works

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  late final HadithBloc _bloc = getIt<HadithBloc>();

  @override
  void initState() {
    super.initState();
    _bloc.eventSink.add(LoadHadithEvent());
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<HadithState>(
      stream: _bloc.state,
      initialData: HadithState(),
      builder: (context, snapshot) {
        final state = snapshot.data!;

        if (state.isLoading && state.isInitialLoad) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state.errorMessage != null && state.data.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColors.primary, size: 48),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            const SizedBox(height: 16),
            SvgPicture.asset(
              AppAssets.logoTop,
              height: 52,
            ),
            const SizedBox(height: 4),
            const Text(
              'Swipe up for next hadith',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: PageView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: state.data.length,
                itemBuilder: (context, index) {
                  // Assuming _HadithCard accepts HadithModel or we cast it
                  final hadith = state.data[index] as HadithModel;
                  return _HadithCard(hadith: hadith);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HadithCard extends StatelessWidget {
  final HadithModel hadith;
  const _HadithCard({required this.hadith});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/hadith_details', arguments: hadith),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage(AppAssets.hadithCardBg),
                  fit: BoxFit.cover,
                  opacity: 0.2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      hadith.title,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: Text(
                        hadith.content,
                        style: const TextStyle(
                          color: AppColors.black,
                          fontSize: 14,
                          height: 1.8,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 8,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionButton(
                          icon: Icons.copy_rounded,
                          label: 'Copy',
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(
                                text: '${hadith.title}\n\n${hadith.content}',
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard'),
                                backgroundColor: AppColors.black,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _ActionButton(
                          icon: Icons.share_rounded,
                          label: 'Share',
                          onTap: () => Share.share(
                            '${hadith.title}\n\n${hadith.content}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: AppColors.black, width: 1.5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.black, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
