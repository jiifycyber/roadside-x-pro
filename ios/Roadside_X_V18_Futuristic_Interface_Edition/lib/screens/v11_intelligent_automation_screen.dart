import 'package:flutter/material.dart';
import '../models/entities.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class V11IntelligentAutomationScreen extends StatefulWidget {
  const V11IntelligentAutomationScreen({super.key, required this.state});
  final AppState state;

  @override
  State<V11IntelligentAutomationScreen> createState() =>
      _V11IntelligentAutomationScreenState();
}

class _V11IntelligentAutomationScreenState
    extends State<V11IntelligentAutomationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabs;
  final List<String> messages = [
    'Dispatch: Priority battery call awaiting assignment.',
    'Technician: En route and ETA updated.',
    'Customer: Receipt delivered successfully.',
  ];
  final List<String> automationLog = [];
  bool autoAssign = false;
  bool escalateUnaccepted = true;
  bool lowStockAlerts = true;
  bool complianceAlerts = true;

  @override
  void initState() {
    super.initState();
    tabs = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Roadside X V11 Intelligent Automation',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Predictive dispatch, workflow rules, unified communications, compliance, benchmarking, regions and plugins.',
                        style: TextStyle(color: Color(0xFF9CB1C9)),
                      ),
                    ],
                  ),
                ),
                const Chip(
                  avatar: Icon(Icons.psychology_alt_outlined, size: 18),
                  label: Text('V11'),
                ),
              ],
            ),
          ),
          TabBar(
            controller: tabs,
            isScrollable: true,
            tabs: const [
              Tab(
                icon: Icon(Icons.route_outlined),
                text: 'Predictive Dispatch',
              ),
              Tab(icon: Icon(Icons.account_tree_outlined), text: 'Automations'),
              Tab(icon: Icon(Icons.forum_outlined), text: 'Communications'),
              Tab(icon: Icon(Icons.verified_user_outlined), text: 'Compliance'),
              Tab(icon: Icon(Icons.leaderboard_outlined), text: 'Benchmarking'),
              Tab(icon: Icon(Icons.public_outlined), text: 'Regions'),
              Tab(icon: Icon(Icons.extension_outlined), text: 'Plugins'),
              Tab(icon: Icon(Icons.api_outlined), text: 'Public API'),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: tabs,
              children: [
                _scroll(_predictiveDispatch()),
                _scroll(_automations()),
                _scroll(_communications()),
                _scroll(_compliance()),
                _scroll(_benchmarking()),
                _scroll(_regions()),
                _scroll(_plugins()),
                _scroll(_publicApi()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scroll(Widget child) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: child,
      ),
    ),
  );

  Widget _predictiveDispatch() {
    final available = widget.state.technicians
        .where((t) => t.status == TechnicianStatus.available)
        .toList();
    final recommended = available.isNotEmpty
        ? available.first
        : (widget.state.technicians.isNotEmpty
              ? widget.state.technicians.first
              : null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _metrics([
          MetricCard(
            label: 'Active Calls',
            value: '${widget.state.activeJobs}',
            icon: Icons.work_outline,
          ),
          MetricCard(
            label: 'Available Techs',
            value: '${available.length}',
            icon: Icons.engineering_outlined,
          ),
          MetricCard(
            label: 'Suggested Tech',
            value: recommended?.name ?? 'None',
            icon: Icons.recommend_outlined,
          ),
          MetricCard(
            label: 'Automation Mode',
            value: autoAssign ? 'Auto' : 'Approval',
            icon: Icons.auto_mode_outlined,
          ),
        ]),
        const SizedBox(height: 18),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dispatch Recommendation Engine',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Text(
                recommended == null
                    ? 'Add technicians to activate predictive assignment.'
                    : '${recommended.name} is the current recommendation based on availability and recorded workload. Production routing can also include traffic, skills, equipment and partner SLA rules.',
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: autoAssign,
                onChanged: (v) => setState(() => autoAssign = v),
                title: const Text('Automatically assign qualifying calls'),
                subtitle: const Text(
                  'Leave off to require dispatcher approval.',
                ),
              ),
              FilledButton.icon(
                onPressed: recommended == null
                    ? null
                    : () => _log(
                        'Recommended ${recommended.name} for the next eligible job.',
                      ),
                icon: const Icon(Icons.bolt),
                label: const Text('Run Recommendation'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _automations() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionCard(
        child: Column(
          children: [
            SwitchListTile(
              value: escalateUnaccepted,
              onChanged: (v) => setState(() => escalateUnaccepted = v),
              title: const Text('Escalate unaccepted jobs'),
              subtitle: const Text(
                'Re-alert dispatch when a technician has not accepted within the configured window.',
              ),
            ),
            SwitchListTile(
              value: lowStockAlerts,
              onChanged: (v) => setState(() => lowStockAlerts = v),
              title: const Text('Low-stock workflow'),
              subtitle: const Text(
                'Create an owner alert when inventory reaches its reorder threshold.',
              ),
            ),
            SwitchListTile(
              value: complianceAlerts,
              onChanged: (v) => setState(() => complianceAlerts = v),
              title: const Text('Compliance expiration workflow'),
              subtitle: const Text(
                'Warn before licenses, insurance or inspections expire.',
              ),
            ),
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () {
                  if (escalateUnaccepted)
                    _log('Checked unaccepted jobs and escalation rules.');
                  if (lowStockAlerts)
                    _log('Checked inventory reorder thresholds.');
                  if (complianceAlerts)
                    _log('Checked compliance expiration dates.');
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Run Rules Now'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Automation Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            if (automationLog.isEmpty)
              const Text('No automation has run during this session.'),
            ...automationLog.reversed.map(
              (e) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.check_circle_outline),
                title: Text(e),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _communications() => Column(
    children: [
      SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unified Job Communications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const Text(
              'Local demonstration inbox for dispatcher, technician and customer messages tied to operations.',
            ),
            const SizedBox(height: 12),
            ...messages.map(
              (m) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  child: Icon(Icons.message_outlined),
                ),
                title: Text(m),
              ),
            ),
            FilledButton.icon(
              onPressed: () => setState(
                () => messages.add(
                  'Dispatcher: Follow-up message created at ${TimeOfDay.now().format(context)}.',
                ),
              ),
              icon: const Icon(Icons.add_comment_outlined),
              label: const Text('Add Test Message'),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _compliance() => _listSection('Compliance Center', const [
    ('Driver licenses', 'Track expiration and verification status.'),
    ('Insurance certificates', 'Store policy period and renewal reminders.'),
    ('Vehicle inspections', 'Track inspection and maintenance due dates.'),
    (
      'Training & certifications',
      'Record lockout, battery, towing and safety qualifications.',
    ),
  ], Icons.verified_user_outlined);

  Widget _benchmarking() {
    final completed = widget.state.jobs
        .where((j) => j.status == JobStatus.completed)
        .length;
    return Column(
      children: [
        _metrics([
          MetricCard(
            label: 'Completed Jobs',
            value: '$completed',
            icon: Icons.task_alt,
          ),
          MetricCard(
            label: 'Recorded Revenue',
            value: money(widget.state.revenue),
            icon: Icons.attach_money,
          ),
          MetricCard(
            label: 'Estimated Profit',
            value: money(widget.state.profit),
            icon: Icons.trending_up,
          ),
          MetricCard(
            label: 'Technicians',
            value: '${widget.state.technicians.length}',
            icon: Icons.groups_outlined,
          ),
        ]),
        const SizedBox(height: 16),
        _listSection('Performance Comparisons', const [
          (
            'Response-time trend',
            'Compare week-over-week and region-over-region response times.',
          ),
          (
            'Service profitability',
            'Compare tire, battery, lockout, fuel and custom services.',
          ),
          (
            'Technician productivity',
            'Compare accepted calls, completion rate, revenue and ratings.',
          ),
          (
            'Partner performance',
            'Compare motor-club authorization, payment timing and margins.',
          ),
        ], Icons.insights_outlined),
      ],
    );
  }

  Widget _regions() => _listSection('Multi-Region Expansion', const [
    (
      'Birmingham Operations',
      'Independent technicians, pricing, inventory and dispatch queue.',
    ),
    (
      'Charlotte Operations',
      'Ready for a separate regional roster and service rules.',
    ),
    (
      'Dallas Operations',
      'Ready for localized tax, pricing and coverage zones.',
    ),
    (
      'Enterprise Overview',
      'Owner roll-up across every active city and company.',
    ),
  ], Icons.public_outlined);

  Widget _plugins() => _listSection('Plugin Marketplace Architecture', const [
    (
      'Mobile Mechanic Module',
      'Diagnostics, repair estimates and parts workflows.',
    ),
    (
      'Heavy-Duty Module',
      'Truck-specific equipment, rates and technician qualifications.',
    ),
    (
      'EV Assistance Module',
      'Charging, battery state and EV-safe service procedures.',
    ),
    (
      'Locksmith Module',
      'Credentialing, restricted notes and specialized inventory.',
    ),
  ], Icons.extension_outlined);

  Widget _publicApi() => Column(
    children: [
      _listSection('Roadside X Public API', const [
        (
          'Dispatch API',
          'Approved partners can create, read and update roadside calls.',
        ),
        (
          'Technician Status API',
          'Authorized systems can receive assignment and status events.',
        ),
        (
          'Customer Tracking API',
          'Generate controlled, expiring tracking experiences.',
        ),
        (
          'Webhook Events',
          'job.created, job.accepted, technician.en_route, job.completed and invoice.paid.',
        ),
      ], Icons.api_outlined),
      const SizedBox(height: 14),
      SectionCard(
        child: const SelectableText(
          'POST /v1/jobs\nGET /v1/jobs/{id}\nPOST /v1/jobs/{id}/status\nPOST /v1/webhooks/partner\nAuthorization: Bearer <server-issued-token>',
        ),
      ),
    ],
  );

  Widget _metrics(List<Widget> children) => LayoutBuilder(
    builder: (context, c) => GridView.count(
      crossAxisCount: c.maxWidth > 1100
          ? 4
          : c.maxWidth > 650
          ? 2
          : 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 2.15,
      children: children,
    ),
  );

  Widget _listSection(
    String title,
    List<(String, String)> items,
    IconData icon,
  ) => SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (e) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Icon(icon)),
            title: Text(
              e.$1,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(e.$2),
          ),
        ),
      ],
    ),
  );

  void _log(String value) {
    setState(() => automationLog.add(value));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
