import 'package:flutter/material.dart';
import '../models/entities.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class V10EnterpriseScreen extends StatefulWidget {
  const V10EnterpriseScreen({super.key, required this.state});
  final AppState state;

  @override
  State<V10EnterpriseScreen> createState() => _V10EnterpriseScreenState();
}

class _V10EnterpriseScreenState extends State<V10EnterpriseScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
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
                        'Roadside X V10 Enterprise Command Center',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'AI-style recommendations, fleet, payroll, customer portal, offline queue, security and business intelligence.',
                        style: TextStyle(color: Color(0xFF9CB1C9)),
                      ),
                    ],
                  ),
                ),
                const Chip(
                  avatar: Icon(Icons.auto_awesome, size: 18),
                  label: Text('V10 Enterprise'),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabs: const [
              Tab(icon: Icon(Icons.auto_awesome), text: 'AI Command'),
              Tab(
                icon: Icon(Icons.monitor_heart_outlined),
                text: 'Business Health',
              ),
              Tab(icon: Icon(Icons.local_shipping_outlined), text: 'Fleet'),
              Tab(icon: Icon(Icons.payments_outlined), text: 'Payroll'),
              Tab(
                icon: Icon(Icons.person_pin_circle_outlined),
                text: 'Customer Portal',
              ),
              Tab(icon: Icon(Icons.cloud_off_outlined), text: 'Offline Queue'),
              Tab(icon: Icon(Icons.security_outlined), text: 'Security'),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _scroll(_aiCommand()),
                _scroll(_businessHealth()),
                _scroll(_fleet()),
                _scroll(_payroll()),
                _scroll(_customerPortal()),
                _scroll(_offlineQueue()),
                _scroll(_security()),
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

  Widget _aiCommand() {
    final state = widget.state;
    final available = state.technicians
        .where((t) => t.status == TechnicianStatus.available)
        .toList();
    final lowStock = state.inventory
        .where((i) => i.quantity <= i.lowStockAt)
        .toList();
    final bestTech = state.technicians.isEmpty
        ? null
        : state.technicians.reduce(
            (a, b) => a.activeJobs <= b.activeJobs ? a : b,
          );
    final insights = <_Insight>[
      _Insight(
        Icons.route_outlined,
        'Smart dispatch recommendation',
        available.isEmpty
            ? 'No technician is marked Available. Review the technician board before accepting another priority call.'
            : '${available.first.name} is available in ${available.first.area} and is a strong candidate for the next nearby job.',
        available.isEmpty ? 'Attention' : 'Recommended',
      ),
      _Insight(
        Icons.inventory_2_outlined,
        'Inventory forecast',
        lowStock.isEmpty
            ? 'Current inventory is above all configured low-stock thresholds.'
            : '${lowStock.length} item(s) need attention: ${lowStock.map((e) => e.name).take(3).join(', ')}.',
        lowStock.isEmpty ? 'Healthy' : 'Reorder',
      ),
      _Insight(
        Icons.attach_money,
        'Pricing intelligence',
        state.jobs.isEmpty
            ? 'Create jobs to generate service pricing and profitability recommendations.'
            : 'Average completed job value is ${money(state.revenue / state.jobs.length)}. Review low-margin calls before dispatch.',
        'Insight',
      ),
      _Insight(
        Icons.engineering_outlined,
        'Workload balancing',
        bestTech == null
            ? 'Add technicians to activate workload balancing.'
            : '${bestTech.name} currently has ${bestTech.activeJobs} active job(s), the lightest workload in the current roster.',
        'Suggested',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
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
            children: [
              MetricCard(
                label: 'Active Jobs',
                value: '${state.activeJobs}',
                icon: Icons.work_outline,
              ),
              MetricCard(
                label: 'Available Techs',
                value: '${available.length}',
                icon: Icons.engineering_outlined,
              ),
              MetricCard(
                label: 'Revenue',
                value: money(state.revenue),
                icon: Icons.attach_money,
              ),
              MetricCard(
                label: 'Low Stock',
                value: '${lowStock.length}',
                icon: Icons.warning_amber_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Actionable Recommendations',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        ...insights.map(
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SectionCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Icon(i.icon)),
                title: Text(
                  i.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(i.message),
                trailing: Chip(label: Text(i.badge)),
              ),
            ),
          ),
        ),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ask Roadside X',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Local command shortcuts demonstrate the questions a future cloud AI assistant can answer securely.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _questionChip('Who is available now?'),
                  _questionChip('What is today’s revenue?'),
                  _questionChip('Which inventory is low?'),
                  _questionChip('How many active calls?'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _questionChip(String text) => ActionChip(
    avatar: const Icon(Icons.chat_bubble_outline, size: 18),
    label: Text(text),
    onPressed: () => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_answer(text)))),
  );

  String _answer(String q) {
    final s = widget.state;
    if (q.contains('available')) {
      final names = s.technicians
          .where((t) => t.status == TechnicianStatus.available)
          .map((t) => t.name)
          .toList();
      return names.isEmpty
          ? 'No technicians are marked available.'
          : 'Available: ${names.join(', ')}';
    }
    if (q.contains('revenue'))
      return 'Current recorded revenue is ${money(s.revenue)}.';
    if (q.contains('inventory')) {
      final items = s.inventory
          .where((i) => i.quantity <= i.lowStockAt)
          .map((i) => i.name)
          .toList();
      return items.isEmpty
          ? 'No inventory is currently below its threshold.'
          : 'Low stock: ${items.join(', ')}';
    }
    return '${s.activeJobs} roadside call(s) are currently active.';
  }

  Widget _businessHealth() {
    final s = widget.state;
    final completed = s.jobs
        .where((j) => j.status == JobStatus.completed)
        .length;
    final completionRate = s.jobs.isEmpty
        ? 0.0
        : completed / s.jobs.length * 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, c) => GridView.count(
            crossAxisCount: c.maxWidth > 1000
                ? 4
                : c.maxWidth > 600
                ? 2
                : 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.15,
            children: [
              MetricCard(
                label: 'Estimated Profit',
                value: money(s.profit),
                icon: Icons.trending_up,
              ),
              MetricCard(
                label: 'Completion Rate',
                value: '${completionRate.toStringAsFixed(0)}%',
                icon: Icons.task_alt,
              ),
              MetricCard(
                label: 'MRR',
                value: money(s.mrr),
                icon: Icons.autorenew,
              ),
              MetricCard(
                label: 'Partner Calls',
                value: '${s.clubDispatches.length}',
                icon: Icons.hub_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Executive Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              _healthRow(
                'Operations',
                s.activeJobs <= 10 ? 'Healthy' : 'High workload',
                s.activeJobs <= 10,
              ),
              _healthRow(
                'Inventory',
                s.inventory.any((i) => i.quantity <= i.lowStockAt)
                    ? 'Attention required'
                    : 'Healthy',
                !s.inventory.any((i) => i.quantity <= i.lowStockAt),
              ),
              _healthRow(
                'Subscriptions',
                s.companies.any((c) => c.status != SubscriptionStatus.active)
                    ? 'Review accounts'
                    : 'Healthy',
                !s.companies.any((c) => c.status != SubscriptionStatus.active),
              ),
              _healthRow(
                'Integrations',
                s.partnerConnectors.any((p) => p.enabled)
                    ? 'Connector enabled'
                    : 'Sandbox/manual mode',
                s.partnerConnectors.any((p) => p.enabled),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _healthRow(String label, String value, bool good) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      good ? Icons.check_circle : Icons.warning_amber,
      color: good ? const Color(0xFF65D99B) : Colors.orangeAccent,
    ),
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    trailing: Text(value),
  );

  Widget _fleet() {
    final techs = widget.state.technicians;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fleet & Service Vehicle Board',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'This local module models vehicle assignments and maintenance readiness. Cloud telematics can be connected later.',
              ),
              const SizedBox(height: 14),
              ...techs.map(
                (t) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.local_shipping_outlined),
                  ),
                  title: Text('${t.name} Service Vehicle'),
                  subtitle: Text(
                    '${t.area} • ${labelTechnicianStatus(t.status)} • ${t.activeJobs} active job(s)',
                  ),
                  trailing: const Chip(label: Text('Inspection OK')),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          child: Wrap(
            spacing: 18,
            runSpacing: 12,
            children: const [
              _StaticStat('Maintenance Due', '0', Icons.build_outlined),
              _StaticStat('Open Inspections', '0', Icons.fact_check_outlined),
              _StaticStat('Fuel Alerts', '0', Icons.local_gas_station_outlined),
              _StaticStat('Vehicles Ready', '3', Icons.check_circle_outline),
            ],
          ),
        ),
      ],
    );
  }

  Widget _payroll() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Technician Earnings Preview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Uses completed jobs in this device to estimate technician production. Final payroll requires company pay rules and accounting approval.',
              ),
              const SizedBox(height: 12),
              ...widget.state.technicians.map((t) {
                final jobs = widget.state.jobs
                    .where(
                      (j) =>
                          j.technician == t.name &&
                          j.status == JobStatus.completed,
                    )
                    .toList();
                final revenue = jobs.fold<double>(0, (sum, j) => sum + j.total);
                final estimated = jobs.length * 25.0;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_outline),
                  ),
                  title: Text(
                    t.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${jobs.length} completed job(s) • ${money(revenue)} generated',
                  ),
                  trailing: Text('${money(estimated)} est. pay'),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _customerPortal() {
    final jobs = widget.state.jobs.take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer Self-Service Portal Preview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Customers can eventually request service, track the assigned technician, view receipts, pay and rate service through a secure public link.',
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  Chip(
                    avatar: Icon(Icons.add_road),
                    label: Text('Request Service'),
                  ),
                  Chip(
                    avatar: Icon(Icons.location_searching),
                    label: Text('Track Technician'),
                  ),
                  Chip(
                    avatar: Icon(Icons.receipt_long),
                    label: Text('View Receipt'),
                  ),
                  Chip(
                    avatar: Icon(Icons.star_outline),
                    label: Text('Rate Service'),
                  ),
                ],
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
                'Customer Tracking Links',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              if (jobs.isEmpty)
                const Text(
                  'Create a job to preview a customer tracking record.',
                ),
              ...jobs.map(
                (j) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.link)),
                  title: Text('${j.customer} • ${j.id}'),
                  subtitle: Text('${j.service} • ${labelStatus(j.status)}'),
                  trailing: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Preview link copied for ${j.id} (demo).',
                          ),
                        ),
                      );
                    },
                    child: const Text('Copy Link'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _offlineQueue() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.cloud_done_outlined, color: Color(0xFF65D99B)),
                  SizedBox(width: 8),
                  Text(
                    'Local-First Storage Active',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Jobs and operating data are stored locally on this device. A production backend can add conflict-safe synchronization between phones and computers.',
              ),
              const SizedBox(height: 14),
              _queueRow('Job status updates', 0),
              _queueRow('Photo uploads', 0),
              _queueRow('Signatures', 0),
              _queueRow('Partner callbacks', 0),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Production Sync Rules',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 10),
              Text(
                '• Queue changes when internet is unavailable.\n• Retry safely with unique event IDs.\n• Detect conflicting edits.\n• Preserve original timestamps and user IDs.\n• Encrypt uploads and verify server acknowledgements.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _queueRow(String label, int count) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.sync_outlined),
    title: Text(label),
    trailing: Chip(label: Text('$count pending')),
  );

  Widget _security() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Enterprise Security Checklist',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 10),
              _SecurityItem('Role-based navigation', true),
              _SecurityItem('Logout confirmation', true),
              _SecurityItem('Local activity logs', true),
              _SecurityItem('Cloud authentication', false),
              _SecurityItem('Two-factor authentication', false),
              _SecurityItem('Encrypted backend secrets', false),
              _SecurityItem('Automatic cloud backups', false),
              _SecurityItem('Device/session revocation', false),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Audit Trail Preview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...widget.state.activity
                  .take(12)
                  .map(
                    (a) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.history),
                      title: Text(a.message),
                      subtitle: Text(a.actor),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Insight {
  const _Insight(this.icon, this.title, this.message, this.badge);
  final IconData icon;
  final String title;
  final String message;
  final String badge;
}

class _StaticStat extends StatelessWidget {
  const _StaticStat(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 220,
    child: ListTile(
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(
        value,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
      ),
      subtitle: Text(label),
    ),
  );
}

class _SecurityItem extends StatelessWidget {
  const _SecurityItem(this.label, this.enabled);
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      enabled ? Icons.check_circle : Icons.radio_button_unchecked,
      color: enabled ? const Color(0xFF65D99B) : Colors.orangeAccent,
    ),
    title: Text(label),
    trailing: Text(enabled ? 'Included' : 'Backend required'),
  );
}
