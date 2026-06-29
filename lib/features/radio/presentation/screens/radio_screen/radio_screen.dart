import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../di/injector.dart';
import 'bloc/radio_bloc.dart';
import 'bloc/radio_contract.dart';
import '../../../data/models/radio_station_model.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  late final RadioBloc _bloc = getIt<RadioBloc>();

  @override
  void initState() {
    super.initState();
    _bloc.eventSink.add(LoadRadioStationsEvent());
    
    _searchCtrl.addListener(() {
      if (_query != _searchCtrl.text) {
        setState(() => _query = _searchCtrl.text.toLowerCase().trim());
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RadioState>(
      stream: _bloc.state,
      initialData: RadioState(),
      builder: (context, snapshot) {
        final state = snapshot.data!;

        // Filter locally
        final stations = _query.isEmpty
            ? state.stations
            : state.stations
                  .where((s) => s.name.toLowerCase().contains(_query))
                  .toList();

        return Column(
          children: [
            const SizedBox(height: 16),
            SvgPicture.asset(
              AppAssets.logoTop,
              height: 52,
            ),
            const SizedBox(height: 12),

            // ── Search bar ────────────────────────────────────────────
            if (!state.isLoading && state.stations.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withAlpha(60)),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: AppColors.primary,
                    decoration: const InputDecoration(
                      hintText: 'Search stations...',
                      hintStyle: TextStyle(color: Colors.white38),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 4,
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // ── Now playing banner ────────────────────────────────────
            if (state.currentStationIndex != null) ...[
              _NowPlayingBanner(state: state, bloc: _bloc),
              const SizedBox(height: 8),
            ],

            // ── Station list ─────────────────────────────────────────
            Expanded(child: _buildBody(context, state, _bloc, stations.cast<RadioStationModel>())),
          ],
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    RadioState state,
    RadioBloc bloc,
    List<RadioStationModel> stations,
  ) {
    if (state.isLoading && state.isInitialLoad) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.errorMessage != null && state.stations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.primary,
                size: 52,
              ),
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => bloc.eventSink.add(LoadRadioStationsEvent()),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (stations.isEmpty && _query.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: AppColors.primary,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'No stations found for "$_query"',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: stations.length,
      separatorBuilder: (_, __) =>
          const Divider(color: Colors.white12, height: 1),
      itemBuilder: (context, index) {
        // Find original index in full list for state
        final originalIndex = state.stations.indexOf(stations[index]);
        return _StationTile(
          station: stations[index],
          index: originalIndex,
          state: state,
          bloc: bloc,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kept intact from original, fully responsive
// ─────────────────────────────────────────────────────────────────────────────

class _NowPlayingBanner extends StatelessWidget {
  final RadioState state;
  final RadioBloc bloc;
  const _NowPlayingBanner({required this.state, required this.bloc});

  @override
  Widget build(BuildContext context) {
    final station = state.stations[state.currentStationIndex!];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withAlpha(100)),
      ),
      child: Row(
        children: [
          const Icon(Icons.radio_rounded, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Now Playing',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  station.name,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (state.isBuffering)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          else
            GestureDetector(
              onTap: () => bloc.eventSink.add(StopStationEvent()),
              child: const Icon(
                Icons.stop_circle_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }
}

class _StationTile extends StatelessWidget {
  final RadioStationModel station;
  final int index;
  final RadioState state;
  final RadioBloc bloc;

  const _StationTile({
    required this.station,
    required this.index,
    required this.state,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentStation = state.currentStationIndex == index;
    final isPlaying = isCurrentStation && state.isPlaying;
    final isBuffering = isCurrentStation && state.isBuffering;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        backgroundColor: isCurrentStation
            ? AppColors.primary
            : const Color(0xFF2A2A2A),
        child: Icon(
          Icons.radio_rounded,
          color: isCurrentStation ? AppColors.black : AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        station.name,
        style: TextStyle(
          color: isCurrentStation ? AppColors.primary : Colors.white,
          fontWeight: isCurrentStation ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: GestureDetector(
        onTap: () => bloc.eventSink.add(PlayStationEvent(index)),
        child: isBuffering
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Icon(
                isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_filled_rounded,
                color: AppColors.primary,
                size: 36,
              ),
      ),
    );
  }
}
