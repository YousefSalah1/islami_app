import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../di/injector.dart';
import 'bloc/quran_bloc.dart';
import 'bloc/quran_contract.dart';

class QuranTab extends StatefulWidget {
  const QuranTab({super.key});

  @override
  State<QuranTab> createState() => _QuranTabState();
}

class _QuranTabState extends State<QuranTab> {
  final TextEditingController _searchController = TextEditingController();
  late final QuranBloc _bloc = getIt<QuranBloc>();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _bloc.eventSink.add(LoadQuranEvent());

    _searchController.addListener(() {
      if (_query != _searchController.text) {
        setState(() {
          _query = _searchController.text.toLowerCase();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuranState>(
      stream: _bloc.state,
      initialData: QuranState(isLoading: true),
      builder: (context, snapshot) {
        final state = snapshot.data!;
        
        final filteredSurahs = _query.isEmpty
            ? state.allSurahs
            : state.allSurahs.where((s) {
                return s.englishName.toLowerCase().contains(_query) ||
                    s.arabicName.contains(_query) ||
                    (s.index + 1).toString() == _query;
              }).toList();

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

            // Search bar
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
            if (state.lastReadSurah != null) ...[
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
                    Navigator.pushNamed(context, '/sura_details', arguments: state.lastReadSurah);
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
                              state.lastReadSurah!.englishName,
                              style: const TextStyle(
                                color: AppColors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${state.lastReadSurah!.versesCount} ${AppStrings.verses}',
                              style: const TextStyle(color: Color(0xFF404040), fontSize: 12),
                            ),
                          ],
                        ),
                        Text(
                          state.lastReadSurah!.arabicName,
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
              child: state.isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : filteredSurahs.isEmpty
                  ? const Center(
                      child: Text('No suras found', style: TextStyle(color: Colors.white54)),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: filteredSurahs.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                      itemBuilder: (context, index) {
                        final surah = filteredSurahs[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            _bloc.eventSink.add(SaveLastReadSurahEvent(surah.index));
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
      },
    );
  }
}
