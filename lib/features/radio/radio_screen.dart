import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../radio/providers/radio_provider.dart';
import '../../data/models/radio_station_model.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      if (_query != _searchCtrl.text) {
        setState(() => _query = _searchCtrl.text.toLowerCase().trim());
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RadioProvider>();

    // Filter locally — no API call needed
    final stations = _query.isEmpty
        ? provider.stations
        : provider.stations.where((s) => s.name.toLowerCase().contains(_query)).toList();

    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          'Holy Quran Radio',
          style: TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        const Text('إذاعة القرآن الكريم', style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 12),

        // ── Search bar ────────────────────────────────────────────
        if (!provider.isLoading && provider.stations.isNotEmpty)
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
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                ),
              ),
            ),
          ),

        const SizedBox(height: 10),

        // ── Now playing banner ────────────────────────────────────
        if (provider.currentStationIndex != null) ...[
          _NowPlayingBanner(provider: provider),
          const SizedBox(height: 8),
        ],

        // ── Station list ─────────────────────────────────────────
        Expanded(child: _buildBody(context, provider, stations)),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    RadioProvider provider,
    List<RadioStationModel> stations,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (provider.errorMessage != null && provider.stations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, color: AppColors.primary, size: 52),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: provider.retry,
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
            const Icon(Icons.search_off_rounded, color: AppColors.primary, size: 40),
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
      separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
      itemBuilder: (context, index) {
        // Find original index in full list for provider
        final originalIndex = provider.stations.indexOf(stations[index]);
        return _StationTile(station: stations[index], index: originalIndex, provider: provider);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kept intact from original, fully responsive
// ─────────────────────────────────────────────────────────────────────────────

class _NowPlayingBanner extends StatelessWidget {
  final RadioProvider provider;
  const _NowPlayingBanner({required this.provider});

  @override
  Widget build(BuildContext context) {
    final station = provider.stations[provider.currentStationIndex!];
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
                const Text('Now Playing', style: TextStyle(color: Colors.white54, fontSize: 12)),
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
          if (provider.isBuffering)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            )
          else
            GestureDetector(
              onTap: provider.stop,
              child: const Icon(Icons.stop_circle_rounded, color: AppColors.primary, size: 30),
            ),
        ],
      ),
    );
  }
}

class _StationTile extends StatelessWidget {
  final RadioStationModel station;
  final int index;
  final RadioProvider provider;

  const _StationTile({required this.station, required this.index, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isCurrentStation = provider.currentStationIndex == index;
    final isPlaying = isCurrentStation && provider.isPlaying;
    final isBuffering = isCurrentStation && provider.isBuffering;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        backgroundColor: isCurrentStation ? AppColors.primary : const Color(0xFF2A2A2A),
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
        onTap: () => provider.playStation(index),
        child: isBuffering
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              )
            : Icon(
                isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                color: AppColors.primary,
                size: 36,
              ),
      ),
    );
  }
}
