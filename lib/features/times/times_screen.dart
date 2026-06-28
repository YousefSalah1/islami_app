import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/prayer_times_model.dart';
import 'providers/times_provider.dart';

class TimesScreen extends StatefulWidget {
  const TimesScreen({super.key});

  @override
  State<TimesScreen> createState() => _TimesScreenState();
}

class _TimesScreenState extends State<TimesScreen> {
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  @override
  void dispose() {
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimesProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return switch (provider.status) {
          TimesStatus.initial => _buildInitial(context, provider, constraints),
          TimesStatus.loading => _buildLoading(),
          TimesStatus.success => _buildSuccess(context, provider, constraints),
          TimesStatus.error => _buildError(context, provider, constraints),
          TimesStatus.permissionDenied => _buildManual(context, provider, constraints),
        };
      },
    );
  }

  // ── Initial: GPS button + cached preview ──────────────────────────────────
  Widget _buildInitial(BuildContext context, TimesProvider provider, BoxConstraints c) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: c.maxHeight * 0.06),
      child: Column(
        children: [
          const Text(
            'مواقيت الصلاة',
            style: TextStyle(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text('Prayer Times', style: TextStyle(color: Colors.white60, fontSize: 16)),
          SizedBox(height: c.maxHeight * 0.05),
          const Icon(Icons.mosque_rounded, color: AppColors.primary, size: 80),
          SizedBox(height: c.maxHeight * 0.05),
          _GpsButton(onTap: provider.fetchByGPS),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () => _showManualSheet(context, provider),
            icon: const Icon(Icons.edit_location_alt_rounded, color: Colors.white54, size: 18),
            label: const Text(
              'Enter city manually',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          if (provider.hasCachedData && provider.prayerTimes != null) ...[
            const SizedBox(height: 20),
            const Divider(color: Colors.white12),
            const SizedBox(height: 8),
            const Text('Last saved times', style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 8),
            _CompactPrayerRow(times: provider.prayerTimes!),
          ],
        ],
      ),
    );
  }

  // ── Loading ────────────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('Getting your location...', style: TextStyle(color: Colors.white60, fontSize: 14)),
        ],
      ),
    );
  }

  // ── Success ────────────────────────────────────────────────────────────────
  Widget _buildSuccess(BuildContext context, TimesProvider provider, BoxConstraints c) {
    final times = provider.prayerTimes!;
    final loc = provider.locationInfo;

    // Build location label
    final locationParts = <String>[];
    if (loc?.district.isNotEmpty == true) locationParts.add(loc!.district);
    if (loc?.city.isNotEmpty == true) locationParts.add(loc!.city);
    if (loc?.country.isNotEmpty == true) locationParts.add(loc!.country);
    final locationLabel = locationParts.isNotEmpty ? locationParts.join(', ') : times.city;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // ── Location card ──────────────────────────────────
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        locationLabel,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    GestureDetector(
                      onTap: provider.fetchByGPS,
                      child: const Icon(Icons.refresh_rounded, color: Colors.white38, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Text(
                    '${times.weekday}  •  ${times.gregorianReadable}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Text(
                    times.hijriDateString,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                      fontFamily: 'JannaLT',
                    ),
                    textDirection: TextDirection.rtl,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Countdown card ─────────────────────────────────
          _InfoCard(
            color: AppColors.primary.withAlpha(20),
            borderColor: AppColors.primary.withAlpha(80),
            child: Row(
              children: [
                const Icon(Icons.timer_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next: ${_arabicName(provider.nextPrayerName)}  (${provider.nextPrayerName})',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Remaining time',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  provider.countdownString,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Prayer cards ───────────────────────────────────
          ..._buildPrayerCards(times),
          const SizedBox(height: 8),

          // ── Actions ────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: provider.fetchByGPS,
                icon: const Icon(Icons.gps_fixed_rounded, color: AppColors.primary, size: 16),
                label: const Text(
                  'Use GPS',
                  style: TextStyle(color: AppColors.primary, fontSize: 13),
                ),
              ),
              const Text('•', style: TextStyle(color: Colors.white38)),
              TextButton.icon(
                onPressed: () => _showManualSheet(context, provider),
                icon: const Icon(Icons.edit_rounded, color: Colors.white54, size: 16),
                label: const Text(
                  'Change city',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ),
            ],
          ),
          if (provider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.orange, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  List<Widget> _buildPrayerCards(PrayerTimesModel times) {
    final current = times.currentPrayer;
    final next = times.nextPrayer;

    final prayers = [
      (name: 'Fajr', ar: 'الفجر', time: times.fajr, icon: Icons.brightness_3_rounded),
      (name: 'Sunrise', ar: 'الشروق', time: times.sunrise, icon: Icons.wb_sunny_rounded),
      (name: 'Dhuhr', ar: 'الظهر', time: times.dhuhr, icon: Icons.light_mode_rounded),
      (name: 'Asr', ar: 'العصر', time: times.asr, icon: Icons.cloud_rounded),
      (name: 'Maghrib', ar: 'المغرب', time: times.maghrib, icon: Icons.wb_twilight_rounded),
      (name: 'Isha', ar: 'العشاء', time: times.isha, icon: Icons.nightlight_round),
    ];

    return prayers.map((p) {
      return _PrayerCard(
        name: p.name,
        arabic: p.ar,
        time: p.time,
        icon: p.icon,
        isCurrent: p.name == current,
        isNext: p.name == next,
      );
    }).toList();
  }

  // ── Error ──────────────────────────────────────────────────────────────────
  Widget _buildError(BuildContext context, TimesProvider provider, BoxConstraints c) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: c.maxHeight * 0.08),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.primary, size: 56),
          const SizedBox(height: 16),
          Text(
            provider.errorMessage ?? 'Something went wrong.',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _GpsButton(onTap: provider.fetchByGPS),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _showManualSheet(context, provider),
            child: const Text('Enter city manually', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: provider.reset,
            child: const Text('Go back', style: TextStyle(color: Colors.white38, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ── Permission denied → manual entry ──────────────────────────────────────
  Widget _buildManual(BuildContext context, TimesProvider provider, BoxConstraints c) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: c.maxHeight * 0.05,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Icon(Icons.location_off_rounded, color: AppColors.primary, size: 56)),
          const SizedBox(height: 14),
          Center(
            child: Text(
              provider.errorMessage ?? 'Location permission denied.',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Enter Location Manually',
            style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _InputField(ctrl: _cityCtrl, hint: 'City (e.g. Cairo)'),
          const SizedBox(height: 10),
          _InputField(ctrl: _countryCtrl, hint: 'Country (e.g. Egypt)'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final city = _cityCtrl.text.trim();
                final country = _countryCtrl.text.trim();
                if (city.isEmpty || country.isEmpty) return;
                provider.fetchByCity(city: city, country: country);
              },
              child: const Text(
                'Get Prayer Times',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: provider.fetchByGPS,
              icon: const Icon(Icons.gps_fixed_rounded, color: AppColors.primary, size: 16),
              label: const Text('Try GPS again', style: TextStyle(color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Manual bottom sheet ────────────────────────────────────────────────────
  void _showManualSheet(BuildContext context, TimesProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Location',
              style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _InputField(ctrl: _cityCtrl, hint: 'City (e.g. Cairo)'),
            const SizedBox(height: 10),
            _InputField(ctrl: _countryCtrl, hint: 'Country (e.g. Egypt)'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final city = _cityCtrl.text.trim();
                  final country = _countryCtrl.text.trim();
                  if (city.isEmpty || country.isEmpty) return;
                  Navigator.pop(ctx);
                  provider.fetchByCity(city: city, country: country);
                },
                child: const Text(
                  'Get Prayer Times',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _arabicName(String name) => switch (name) {
    'Fajr' => 'الفجر',
    'Sunrise' => 'الشروق',
    'Dhuhr' => 'الظهر',
    'Asr' => 'العصر',
    'Maghrib' => 'المغرب',
    'Isha' => 'العشاء',
    _ => name,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _GpsButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GpsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.gps_fixed_rounded, size: 22),
        label: const Text(
          'Use My GPS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onPressed: onTap,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;

  const _InfoCard({required this.child, this.color, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor ?? Colors.white12),
      ),
      child: child,
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final String name;
  final String arabic;
  final String time;
  final IconData icon;
  final bool isCurrent;
  final bool isNext;

  const _PrayerCard({
    required this.name,
    required this.arabic,
    required this.time,
    required this.icon,
    required this.isCurrent,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primary : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent
              ? AppColors.primary
              : isNext
              ? AppColors.primary.withAlpha(80)
              : Colors.white12,
          width: (isCurrent || isNext) ? 1.5 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.primary.withAlpha(60),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Icon(icon, color: isCurrent ? AppColors.black : AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  arabic,
                  style: TextStyle(
                    color: isCurrent ? AppColors.black : AppColors.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  name,
                  style: TextStyle(
                    color: isCurrent ? AppColors.black.withAlpha(160) : Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrent)
            _Badge(label: 'Now', bg: AppColors.black.withAlpha(40), fg: AppColors.black),
          if (isNext && !isCurrent)
            _Badge(
              label: 'Next',
              bg: AppColors.primary.withAlpha(30),
              fg: AppColors.primary,
              borderColor: AppColors.primary.withAlpha(80),
            ),
          const SizedBox(width: 6),
          Text(
            time,
            style: TextStyle(
              color: isCurrent ? AppColors.black : AppColors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final Color? borderColor;

  const _Badge({required this.label, required this.bg, required this.fg, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null ? Border.all(color: borderColor!, width: 1) : null,
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;

  const _InputField({required this.ctrl, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _CompactPrayerRow extends StatelessWidget {
  final PrayerTimesModel times;
  const _CompactPrayerRow({required this.times});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chip('الفجر', times.fajr),
        _chip('الشروق', times.sunrise),
        _chip('الظهر', times.dhuhr),
        _chip('العصر', times.asr),
        _chip('المغرب', times.maghrib),
        _chip('العشاء', times.isha),
      ],
    );
  }

  Widget _chip(String label, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            time,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
