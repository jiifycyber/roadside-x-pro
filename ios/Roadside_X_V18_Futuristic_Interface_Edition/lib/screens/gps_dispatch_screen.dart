import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/entities.dart';
import '../services/gps_service.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class GpsDispatchScreen extends StatefulWidget {
  const GpsDispatchScreen({super.key, required this.state});
  final AppState state;

  @override
  State<GpsDispatchScreen> createState() => _GpsDispatchScreenState();
}

class _GpsDispatchScreenState extends State<GpsDispatchScreen> {
  final mapController = MapController();
  StreamSubscription<Position>? subscription;
  Position? current;
  bool loading = false;
  bool liveTracking = false;
  String? error;

  @override
  void initState() {
    super.initState();
    refreshCurrentLocation();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  Future<void> refreshCurrentLocation() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final position = await GpsService.currentPosition();
      if (!mounted) return;
      setState(() => current = position);
      mapController.move(LatLng(position.latitude, position.longitude), 13);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> toggleTracking() async {
    if (liveTracking) {
      await subscription?.cancel();
      subscription = null;
      setState(() => liveTracking = false);
      return;
    }
    try {
      await refreshCurrentLocation();
      subscription = GpsService.positionStream().listen(
        (position) {
          if (!mounted) return;
          setState(() => current = position);
        },
        onError: (Object e) {
          if (mounted) setState(() => error = e.toString());
        },
      );
      setState(() => liveTracking = true);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  List<Marker> markers() {
    final result = <Marker>[];
    if (current != null) {
      result.add(
        Marker(
          point: LatLng(current!.latitude, current!.longitude),
          width: 52,
          height: 52,
          child: const Tooltip(
            message: 'Current technician/device location',
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ),
      );
    }
    for (final job in widget.state.jobs.where((j) => j.hasCoordinates)) {
      result.add(
        Marker(
          point: LatLng(job.latitude!, job.longitude!),
          width: 56,
          height: 56,
          child: Tooltip(
            message: '${job.id} • ${job.customer}\n${job.location}',
            child: GestureDetector(
              onTap: () => showJob(job),
              child: CircleAvatar(
                backgroundColor: job.status == JobStatus.completed
                    ? Colors.green
                    : Colors.orange,
                child: const Icon(Icons.car_repair, color: Colors.white),
              ),
            ),
          ),
        ),
      );
    }
    return result;
  }

  void showJob(RoadsideJob job) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${job.id} • ${job.customer}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(job.location),
            Text(
              '${job.service} • ${labelStatus(job.status)} • ${job.technician}',
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => GpsService.openNavigation(
                  latitude: job.latitude!,
                  longitude: job.longitude!,
                  label: job.customer,
                ),
                icon: const Icon(Icons.navigation),
                label: const Text('Start Turn-by-Turn Navigation'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final center = current == null
        ? const LatLng(33.5186, -86.8104)
        : LatLng(current!.latitude, current!.longitude);

    return Column(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: loading ? null : refreshCurrentLocation,
              icon: loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: const Text('Find My Location'),
            ),
            FilledButton.tonalIcon(
              onPressed: toggleTracking,
              icon: Icon(liveTracking ? Icons.gps_off : Icons.gps_fixed),
              label: Text(
                liveTracking ? 'Stop Live Tracking' : 'Start Live Tracking',
              ),
            ),
            OutlinedButton.icon(
              onPressed: current == null
                  ? null
                  : () => mapController.move(
                      LatLng(current!.latitude, current!.longitude),
                      14,
                    ),
              icon: const Icon(Icons.center_focus_strong),
              label: const Text('Center Map'),
            ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 12),
          MaterialBanner(
            content: Text(error!),
            leading: const Icon(Icons.warning_amber),
            actions: [
              TextButton(
                onPressed: () => setState(() => error = null),
                child: const Text('DISMISS'),
              ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        SectionCard(
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 520,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(initialCenter: center, initialZoom: 11),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.jiffyroadside.phase4',
                  ),
                  MarkerLayer(markers: markers()),
                  RichAttributionWidget(
                    attributions: const [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mapped Customer Jobs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (widget.state.jobs.where((j) => j.hasCoordinates).isEmpty)
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('No GPS jobs yet'),
                  subtitle: Text(
                    'Create a job and verify the customer address to add it to the map.',
                  ),
                ),
              ...widget.state.jobs
                  .where((j) => j.hasCoordinates)
                  .map(
                    (job) => ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text('${job.id} • ${job.customer}'),
                      subtitle: Text(job.location),
                      trailing: FilledButton.tonalIcon(
                        onPressed: () => GpsService.openNavigation(
                          latitude: job.latitude!,
                          longitude: job.longitude!,
                          label: job.customer,
                        ),
                        icon: const Icon(Icons.navigation),
                        label: const Text('Navigate'),
                      ),
                      onTap: () => mapController.move(
                        LatLng(job.latitude!, job.longitude!),
                        15,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
