import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/entities.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/futuristic.dart';

class TechnicianPortal extends StatelessWidget {
  const TechnicianPortal({
    super.key,
    required this.state,
    required this.technicianName,
    required this.onLogout,
  });
  final AppState state;
  final String technicianName;
  final VoidCallback onLogout;

  Future<void> _navigate(RoadsideJob job) async {
    final query = job.hasCoordinates
        ? '${job.latitude},${job.longitude}'
        : Uri.encodeComponent(job.location);
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$query',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:${phone.replaceAll(RegExp(r'[^0-9+]'), '')}');
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final jobs = state.jobs
            .where(
              (j) =>
                  j.technician == technicianName &&
                  j.status != JobStatus.completed &&
                  j.status != JobStatus.cancelled,
            )
            .toList();
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Roadside X Driver'),
            actions: [
              IconButton(
                onPressed: onLogout,
                tooltip: 'Sign Out',
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: FuturisticBackground(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Text(
                  'Welcome, $technicianName',
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Only jobs assigned to you are displayed.',
                  style: TextStyle(color: Color(0xFF9CB1C9)),
                ),
                const SizedBox(height: 18),
                if (jobs.isEmpty)
                  const SectionCard(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No active jobs assigned.')),
                    ),
                  ),
                ...jobs.map(
                  (job) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${job.id} • ${job.service}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Chip(label: Text(labelStatus(job.status))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            job.customer,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(job.location),
                          if (job.vehicle.isNotEmpty) Text(job.vehicle),
                          if (job.notes.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text('Notes: ${job.notes}'),
                            ),
                          const Divider(height: 26),
                          Wrap(
                            spacing: 9,
                            runSpacing: 9,
                            children: [
                              FilledButton.icon(
                                onPressed: () => _navigate(job),
                                icon: const Icon(Icons.navigation),
                                label: const Text('Navigate'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _call(job.phone),
                                icon: const Icon(Icons.call),
                                label: const Text('Call Customer'),
                              ),
                              DropdownButton<JobStatus>(
                                value: job.status,
                                items:
                                    const [
                                          JobStatus.accepted,
                                          JobStatus.enRoute,
                                          JobStatus.onSite,
                                          JobStatus.inProgress,
                                          JobStatus.completed,
                                        ]
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(labelStatus(s)),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (s) {
                                  if (s != null) state.updateJobStatus(job, s);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
