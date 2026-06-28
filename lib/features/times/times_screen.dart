import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/app_assets.dart';
import '../../data/local/countries_cities.dart';
import '../../data/models/prayer_times_model.dart';
import 'providers/times_provider.dart';

class TimesScreen extends StatelessWidget {
  const TimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimesProvider>();

    return LayoutBuilder(
      builder: (context, constraints) => switch (provider.status) {
        TimesStatus.initial => _InitialView(
          provider: provider,
          constraints: constraints,
        ),
        TimesStatus.loading => const _LoadingView(),
        TimesStatus.success => _SuccessView(
          provider: provider,
          constraints: constraints,
        ),
        TimesStatus.error => _ErrorView(
          provider: provider,
          constraints: constraints,
        ),
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Initial — no location saved yet
// ─────────────────────────────────────────────────────────────────────────────

class _InitialView extends StatelessWidget {
  final TimesProvider provider;
  final BoxConstraints constraints;
  const _InitialView({required this.provider, required this.constraints});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: constraints.maxHeight * 0.06,
      ),
      child: Column(
        children: [
          const Text(
            'مواقيت الصلاة',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Prayer Times',
            style: TextStyle(color: Colors.white60, fontSize: 16),
          ),
          SizedBox(height: constraints.maxHeight * 0.06),
          const Icon(Icons.mosque_rounded, color: AppColors.primary, size: 80),
          SizedBox(height: constraints.maxHeight * 0.06),
          const Text(
            'Select your country and city to get prayer times',
            style: TextStyle(color: Colors.white54, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _LocationSelector(provider: provider),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Getting prayer times...',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Success
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final TimesProvider provider;
  final BoxConstraints constraints;
  const _SuccessView({required this.provider, required this.constraints});

  @override
  Widget build(BuildContext context) {
    final times = provider.prayerTimes!;
    final country = provider.selectedCountry ?? '';
    final city = provider.selectedCity ?? times.city;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(AppAssets.logoTop, height: 52),
            const SizedBox(height: 20),
            // ── Location card ──────────────────────────────────
            _InfoCard(
              child: Row(
                children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.isNotEmpty ? '$city, $country' : country,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${times.weekday}  •  ${times.gregorianReadable}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        times.hijriDateString,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontFamily: 'JannaLT',
                        ),
                        textDirection: TextDirection.rtl,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Countdown ──────────────────────────────────────
          _InfoCard(
            color: AppColors.primary.withAlpha(20),
            borderColor: AppColors.primary.withAlpha(80),
            child: Row(
              children: [
                const Icon(
                  Icons.timer_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
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
          ..._buildCards(times),
          const SizedBox(height: 8),

          // ── Change country / city buttons ──────────────────
          Row(
            children: [
              Expanded(
                child: _ChangeButton(
                  icon: Icons.public_rounded,
                  label: 'Change Country',
                  onTap: () => _showCountryPicker(context, provider),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ChangeButton(
                  icon: Icons.location_city_rounded,
                  label: 'Change City',
                  onTap: () => _showCityPicker(context, provider),
                ),
              ),
            ],
          ),

          if (provider.errorMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.orange, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 4),
        ],
      ),
      ),
    );
  }

  List<Widget> _buildCards(PrayerTimesModel times) {
    final current = times.currentPrayer;
    final next = times.nextPrayer;
    return [
          (
            name: 'Fajr',
            ar: 'الفجر',
            time: times.fajr,
            icon: Icons.brightness_3_rounded,
          ),
          (
            name: 'Sunrise',
            ar: 'الشروق',
            time: times.sunrise,
            icon: Icons.wb_sunny_rounded,
          ),
          (
            name: 'Dhuhr',
            ar: 'الظهر',
            time: times.dhuhr,
            icon: Icons.light_mode_rounded,
          ),
          (
            name: 'Asr',
            ar: 'العصر',
            time: times.asr,
            icon: Icons.cloud_rounded,
          ),
          (
            name: 'Maghrib',
            ar: 'المغرب',
            time: times.maghrib,
            icon: Icons.wb_twilight_rounded,
          ),
          (
            name: 'Isha',
            ar: 'العشاء',
            time: times.isha,
            icon: Icons.nightlight_round,
          ),
        ]
        .map(
          (p) => _PrayerCard(
            name: p.name,
            arabic: p.ar,
            time: p.time,
            icon: p.icon,
            isCurrent: p.name == current,
            isNext: p.name == next,
          ),
        )
        .toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final TimesProvider provider;
  final BoxConstraints constraints;
  const _ErrorView({required this.provider, required this.constraints});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: 32,
        vertical: constraints.maxHeight * 0.07,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.primary,
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            provider.errorMessage ?? 'Something went wrong.',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Retry with same location
          if (provider.selectedCountry != null && provider.selectedCity != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  'Retry',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                onPressed: () => provider.fetchByCity(
                  country: provider.selectedCountry!,
                  city: provider.selectedCity!,
                ),
              ),
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.edit_location_alt_rounded),
              label: const Text(
                'Change Location',
                style: TextStyle(fontSize: 15),
              ),
              onPressed: () => _showLocationSheet(context, provider),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Location selector (used in Initial view)
// ─────────────────────────────────────────────────────────────────────────────

class _LocationSelector extends StatelessWidget {
  final TimesProvider provider;
  const _LocationSelector({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PickerTile(
          icon: Icons.public_rounded,
          label: provider.selectedCountry ?? 'Select Country',
          isSelected: provider.selectedCountry != null,
          onTap: () => _showCountryPicker(context, provider),
        ),
        const SizedBox(height: 10),
        if (provider.selectedCountry != null)
          _PickerTile(
            icon: Icons.location_city_rounded,
            label: provider.selectedCity ?? 'Select City',
            isSelected: provider.selectedCity != null,
            onTap: () => _showCityPicker(context, provider),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pickers
// ─────────────────────────────────────────────────────────────────────────────

void _showCountryPicker(BuildContext context, TimesProvider provider) {
  _showPickerSheet(
    context: context,
    title: 'Select Country',
    items: kCountries,
    selected: provider.selectedCountry,
    onSelected: (country) {
      provider.selectCountry(country);
      // If city was previously set for a different country, show city picker
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showCityPicker(context, provider),
      );
    },
  );
}

void _showCityPicker(BuildContext context, TimesProvider provider) {
  if (provider.selectedCountry == null) return;
  final cities = kCountriesCities[provider.selectedCountry] ?? [];
  _showPickerSheet(
    context: context,
    title: provider.selectedCountry!,
    items: cities,
    selected: provider.selectedCity,
    onSelected: (city) => provider.selectCity(city),
  );
}

void _showLocationSheet(BuildContext context, TimesProvider provider) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LocationPickerSheet(provider: provider),
  );
}

void _showPickerSheet({
  required BuildContext context,
  required String title,
  required List<String> items,
  required String? selected,
  required ValueChanged<String> onSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SearchablePickerSheet(
      title: title,
      items: items,
      selected: selected,
      onSelected: onSelected,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Searchable picker bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _SearchablePickerSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? selected;
  final ValueChanged<String> onSelected;

  const _SearchablePickerSheet({
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_SearchablePickerSheet> createState() => _SearchablePickerSheetState();
}

class _SearchablePickerSheetState extends State<_SearchablePickerSheet> {
  final _ctrl = TextEditingController();
  String _query = '';

  List<String> get _filtered => _query.isEmpty
      ? widget.items
      : widget.items.where((i) => i.toLowerCase().contains(_query)).toList();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _ctrl,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: AppColors.primary,
                  onChanged: (v) =>
                      setState(() => _query = v.toLowerCase().trim()),
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.white38),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            // List
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No results',
                        style: TextStyle(color: Colors.white38),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollCtrl,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: Colors.white10, height: 1),
                      itemBuilder: (_, i) {
                        final item = _filtered[i];
                        final isSelected = item == widget.selected;
                        return ListTile(
                          title: Text(
                            item,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () {
                            Navigator.pop(ctx);
                            widget.onSelected(item);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Combined location picker (from error state)
class _LocationPickerSheet extends StatefulWidget {
  final TimesProvider provider;
  const _LocationPickerSheet({required this.provider});

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  String? _country;
  String? _city;
  String _query = '';
  final _ctrl = TextEditingController();
  bool _onCityStep = false;

  List<String> get _countryList => _query.isEmpty
      ? kCountries
      : kCountries.where((c) => c.toLowerCase().contains(_query)).toList();

  List<String> get _cityList => kCountriesCities[_country] ?? [];

  @override
  void initState() {
    super.initState();
    _country = widget.provider.selectedCountry;
    _city = widget.provider.selectedCity;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
              child: Row(
                children: [
                  if (_onCityStep)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.primary,
                      ),
                      onPressed: () => setState(() {
                        _onCityStep = false;
                        _city = null;
                        _query = '';
                        _ctrl.clear();
                      }),
                    ),
                  Expanded(
                    child: Text(
                      _onCityStep ? _country! : 'Select Location',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _ctrl,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: AppColors.primary,
                  onChanged: (v) =>
                      setState(() => _query = v.toLowerCase().trim()),
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.white38),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Expanded(
              child: _onCityStep
                  ? ListView.separated(
                      controller: scrollCtrl,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _cityList.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: Colors.white10, height: 1),
                      itemBuilder: (_, i) {
                        final city = _cityList[i];
                        return ListTile(
                          title: Text(
                            city,
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: city == _city
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () {
                            Navigator.pop(ctx);
                            widget.provider.fetchByCity(
                              country: _country!,
                              city: city,
                            );
                          },
                        );
                      },
                    )
                  : ListView.separated(
                      controller: scrollCtrl,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _countryList.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: Colors.white10, height: 1),
                      itemBuilder: (_, i) {
                        final country = _countryList[i];
                        return ListTile(
                          title: Text(
                            country,
                            style: TextStyle(
                              color: country == _country
                                  ? AppColors.primary
                                  : Colors.white,
                              fontWeight: country == _country
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: country == _country
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () => setState(() {
                            _country = country;
                            _city = null;
                            _onCityStep = true;
                            _query = '';
                            _ctrl.clear();
                          }),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
          Icon(
            icon,
            color: isCurrent ? AppColors.black : AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  arabic,
                  style: TextStyle(
                    color: isCurrent ? AppColors.black : AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  name,
                  style: TextStyle(
                    color: isCurrent
                        ? AppColors.black.withAlpha(150)
                        : Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrent)
            _Badge(
              label: 'Now',
              bg: AppColors.black.withAlpha(40),
              fg: AppColors.black,
            ),
          if (isNext && !isCurrent)
            _Badge(
              label: 'Next',
              bg: AppColors.primary.withAlpha(30),
              fg: AppColors.primary,
              border: AppColors.primary.withAlpha(80),
            ),
          const SizedBox(width: 4),
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
  final Color? border;
  const _Badge({
    required this.label,
    required this.bg,
    required this.fg,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: border != null ? Border.all(color: border!) : null,
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ChangeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ChangeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withAlpha(60)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withAlpha(120)
                : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.white54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white38,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
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
