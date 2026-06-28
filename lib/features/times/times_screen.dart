import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../times/providers/times_provider.dart';
import '../../data/models/prayer_times_model.dart';

class TimesScreen extends StatefulWidget {
  const TimesScreen({super.key});

  @override
  State<TimesScreen> createState() => _TimesScreenState();
}

class _TimesScreenState extends State<TimesScreen> {
  final TextEditingController _cityCtrl = TextEditingController(text: 'Cairo');
  final TextEditingController _countryCtrl = TextEditingController(text: 'Egypt');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimesProvider>().fetchByCity();
    });
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimesProvider>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Prayer Times',
            style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text('مواقيت الصلاة', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 20),

          // City search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildTextField(_cityCtrl, 'City'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(_countryCtrl, 'Country'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.all(14),
                  ),
                  onPressed: () => provider.fetchByCity(
                    city: _cityCtrl.text.trim(),
                    country: _countryCtrl.text.trim(),
                  ),
                  child: const Icon(Icons.search_rounded),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // GPS button
          TextButton.icon(
            onPressed: provider.fetchByLocation,
            icon: const Icon(Icons.gps_fixed_rounded, color: AppColors.primary, size: 18),
            label: const Text('Use My Location', style: TextStyle(color: AppColors.primary)),
          ),

          const SizedBox(height: 12),

          // Content
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else if (provider.errorMessage != null)
            _buildError(provider)
          else if (provider.prayerTimes != null)
            _buildPrayerTimes(provider.prayerTimes!),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildError(TimesProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.primary, size: 48),
          const SizedBox(height: 12),
          Text(provider.errorMessage!, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildPrayerTimes(PrayerTimesModel times) {
    final prayers = [
      {'name': 'Fajr', 'arabic': 'الفجر', 'time': times.fajr, 'icon': Icons.brightness_3_rounded},
      {'name': 'Sunrise', 'arabic': 'الشروق', 'time': times.sunrise, 'icon': Icons.wb_sunny_rounded},
      {'name': 'Dhuhr', 'arabic': 'الظهر', 'time': times.dhuhr, 'icon': Icons.light_mode_rounded},
      {'name': 'Asr', 'arabic': 'العصر', 'time': times.asr, 'icon': Icons.cloud_rounded},
      {'name': 'Maghrib', 'arabic': 'المغرب', 'time': times.maghrib, 'icon': Icons.wb_twilight_rounded},
      {'name': 'Isha', 'arabic': 'العشاء', 'time': times.isha, 'icon': Icons.nightlight_round},
    ];

    return Column(
      children: [
        Text(
          '${times.city} — ${times.date}',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: prayers.map((prayer) {
              final isNext = prayer['name'] == times.nextPrayer;
              return _PrayerCard(
                name: prayer['name'] as String,
                arabic: prayer['arabic'] as String,
                time: prayer['time'] as String,
                icon: prayer['icon'] as IconData,
                isHighlighted: isNext,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final String name;
  final String arabic;
  final String time;
  final IconData icon;
  final bool isHighlighted;

  const _PrayerCard({
    required this.name,
    required this.arabic,
    required this.time,
    required this.icon,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.primary : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlighted ? AppColors.primary : Colors.white12,
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: isHighlighted
            ? [BoxShadow(color: AppColors.primary.withAlpha(60), blurRadius: 12, offset: const Offset(0, 4))]
            : [],
      ),
      child: Row(
        children: [
          Icon(icon, color: isHighlighted ? AppColors.black : AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  arabic,
                  style: TextStyle(
                    color: isHighlighted ? AppColors.black : AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  name,
                  style: TextStyle(
                    color: isHighlighted ? AppColors.black.withAlpha(160) : Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: isHighlighted ? AppColors.black : AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isHighlighted) ...[
            const SizedBox(width: 8),
            const Icon(Icons.access_time_rounded, color: AppColors.black, size: 18),
          ],
        ],
      ),
    );
  }
}
