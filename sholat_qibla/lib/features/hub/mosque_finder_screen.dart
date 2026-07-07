import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_button.dart';
import '../../core/widgets/neo_card.dart';
import '../../engine/models/lat_lng.dart';
import 'mosque_finder_controller.dart';
import 'mosque_finder_service.dart';

/// Layar Pencari Masjid: daftar masjid terdekat (OpenStreetMap) dengan
/// jarak dan tombol buka peta. Satu-satunya fitur online — dipanggil
/// hanya saat layar ini dibuka (opt-in, privasi terjaga).
class MosqueFinderScreen extends StatefulWidget {
  const MosqueFinderScreen({
    super.key,
    required this.controller,
    this.openMap,
  });

  final MosqueFinderController controller;

  /// Pembuka peta eksternal; dapat diganti pada test.
  final Future<void> Function(LatLng location, String name)? openMap;

  @override
  State<MosqueFinderScreen> createState() => _MosqueFinderScreenState();
}

class _MosqueFinderScreenState extends State<MosqueFinderScreen> {
  MosqueSearchResult? _result;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.controller.search();
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _openMap(Mosque mosque) async {
    final open = widget.openMap ?? _launchGeoUri;
    await open(mosque.location, mosque.name);
  }

  /// Buka aplikasi peta perangkat (geo: URI, fallback web OSM).
  static Future<void> _launchGeoUri(LatLng loc, String name) async {
    final geo = Uri.parse(
        'geo:${loc.latitude},${loc.longitude}?q=${loc.latitude},'
        '${loc.longitude}(${Uri.encodeComponent(name)})');
    if (await canLaunchUrl(geo)) {
      await launchUrl(geo);
      return;
    }
    final web = Uri.parse('https://www.openstreetmap.org/'
        '?mlat=${loc.latitude}&mlon=${loc.longitude}#map=17/'
        '${loc.latitude}/${loc.longitude}');
    await launchUrl(web, mode: LaunchMode.externalApplication);
  }

  String _formatDistance(double km) =>
      km < 1 ? '${(km * 1000).round()} m' : '${km.toStringAsFixed(1)} km';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pencari Masjid')),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Mencari masjid terdekat…',
                style: AppTypography.textTheme.bodyMedium),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: NeoCard(
            highlighted: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.wifi_off, size: 28),
                const SizedBox(height: 8),
                Text('Tidak dapat memuat data masjid',
                    style: AppTypography.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Fitur ini memerlukan koneksi internet. Periksa jaringan '
                  'Anda lalu coba lagi.',
                  style: AppTypography.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                NeoButton(label: 'Coba Lagi', onPressed: _search),
              ],
            ),
          ),
        ),
      );
    }

    final result = _result!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Konteks lokasi + privasi.
        NeoCard(
          backgroundColor: AppColors.secondaryContainer,
          child: Row(
            children: [
              Icon(result.usedGps ? Icons.my_location : Icons.location_city,
                  size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sekitar ${result.locationLabel}',
                        style: AppTypography.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Data OpenStreetMap · daring hanya saat layar ini dibuka',
                      style: AppTypography.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (result.mosques.isEmpty)
          NeoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tidak ada masjid ditemukan',
                    style: AppTypography.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Tidak ada data masjid dalam radius 5 km di OpenStreetMap '
                  'untuk area ini.',
                  style: AppTypography.textTheme.bodySmall,
                ),
              ],
            ),
          )
        else
          for (final mosque in result.mosques) ...[
            _MosqueTile(
              mosque: mosque,
              distanceLabel: _formatDistance(mosque.distanceKm),
              onOpenMap: () => _openMap(mosque),
            ),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 12),
      ],
    );
  }
}

class _MosqueTile extends StatelessWidget {
  const _MosqueTile({
    required this.mosque,
    required this.distanceLabel,
    required this.onOpenMap,
  });

  final Mosque mosque;
  final String distanceLabel;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      semanticLabel:
          '${mosque.name}, jarak $distanceLabel. Buka di peta',
      onTap: onOpenMap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              border: Border.all(color: AppColors.outline, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.mosque, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mosque.name,
                  style: AppTypography.textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(distanceLabel,
                    style: AppTypography.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.map_outlined, size: 20, color: AppColors.primary),
        ],
      ),
    );
  }
}
