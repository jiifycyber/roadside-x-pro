import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/entities.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class V12AdvancedAiScreen extends StatefulWidget {
  const V12AdvancedAiScreen({super.key, required this.state});
  final AppState state;

  @override
  State<V12AdvancedAiScreen> createState() => _V12AdvancedAiScreenState();
}

class _V12AdvancedAiScreenState extends State<V12AdvancedAiScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabs;
  final prompt = TextEditingController();
  final callIntake = TextEditingController();
  final List<String> aiHistory = [];
  bool requireApproval = true;
  bool explainRecommendations = true;
  bool fraudAlerts = true;
  bool complianceAlerts = true;
  bool pricingGuardrails = true;

  @override
  void initState() {
    super.initState();
    tabs = TabController(length: 9, vsync: this);
  }

  @override
  void dispose() {
    tabs.dispose();
    prompt.dispose();
    callIntake.dispose();
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
                        'Roadside X V12 Advanced AI Operations',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Explainable dispatch scoring, AI call intake, pricing guardrails, forecasting, reconciliation, safety and approval controls.',
                        style: TextStyle(color: Color(0xFF9CB1C9)),
                      ),
                    ],
                  ),
                ),
                const Chip(
                  avatar: Icon(Icons.auto_awesome, size: 18),
                  label: Text('V12'),
                ),
              ],
            ),
          ),
          TabBar(
            controller: tabs,
            isScrollable: true,
            tabs: const [
              Tab(icon: Icon(Icons.terminal), text: 'AI Command'),
              Tab(icon: Icon(Icons.route_outlined), text: 'Dispatch Scoring'),
              Tab(
                icon: Icon(Icons.record_voice_over_outlined),
                text: 'Call Intake',
              ),
              Tab(icon: Icon(Icons.price_check_outlined), text: 'Pricing AI'),
              Tab(icon: Icon(Icons.security_outlined), text: 'Risk Alerts'),
              Tab(icon: Icon(Icons.query_stats_outlined), text: 'Forecasting'),
              Tab(
                icon: Icon(Icons.receipt_long_outlined),
                text: 'Reconciliation',
              ),
              Tab(
                icon: Icon(Icons.health_and_safety_outlined),
                text: 'Safety Coach',
              ),
              Tab(icon: Icon(Icons.tune_outlined), text: 'AI Controls'),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: tabs,
              children: [
                _scroll(_commandCenter()),
                _scroll(_dispatchScoring()),
                _scroll(_callIntake()),
                _scroll(_pricingAi()),
                _scroll(_riskAlerts()),
                _scroll(_forecasting()),
                _scroll(_reconciliation()),
                _scroll(_safetyCoach()),
                _scroll(_controls()),
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

  Widget _commandCenter() {
    final unpaid = widget.state.jobs.where((j) => !j.paid).length;
    final lowStock = widget.state.inventory.where((i) => i.lowStock).length;
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
            label: 'Unpaid Jobs',
            value: '$unpaid',
            icon: Icons.payments_outlined,
          ),
          MetricCard(
            label: 'Low Stock',
            value: '$lowStock',
            icon: Icons.inventory_2_outlined,
          ),
          MetricCard(
            label: 'AI Approval',
            value: requireApproval ? 'Required' : 'Rule Based',
            icon: Icons.fact_check_outlined,
          ),
        ]),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ask Roadside X',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'Local business-data assistant. Production conversational AI can be connected through the secure backend blueprint.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: prompt,
                decoration: const InputDecoration(
                  labelText:
                      'Ask about jobs, profit, technicians, inventory or payments',
                  prefixIcon: Icon(Icons.auto_awesome),
                ),
                onSubmitted: (_) => _answerPrompt(),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _answerPrompt,
                icon: const Icon(Icons.send),
                label: const Text('Ask Assistant'),
              ),
              if (aiHistory.isNotEmpty) ...[
                const Divider(height: 28),
                ...aiHistory.reversed
                    .take(6)
                    .map(
                      (e) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          child: Icon(Icons.psychology_alt_outlined),
                        ),
                        title: Text(e),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _answerPrompt() {
    final q = prompt.text.trim().toLowerCase();
    if (q.isEmpty) return;
    String answer;
    if (q.contains('profit')) {
      answer =
          'Estimated recorded profit is ${money(widget.state.profit)} across ${widget.state.jobs.length} jobs.';
    } else if (q.contains('revenue')) {
      answer = 'Recorded revenue is ${money(widget.state.revenue)}.';
    } else if (q.contains('unpaid')) {
      final count = widget.state.jobs.where((j) => !j.paid).length;
      answer = '$count job${count == 1 ? '' : 's'} are marked unpaid.';
    } else if (q.contains('inventory') || q.contains('stock')) {
      final items = widget.state.inventory
          .where((i) => i.lowStock)
          .map((i) => i.name)
          .toList();
      answer = items.isEmpty
          ? 'No inventory item is currently at its reorder threshold.'
          : 'Low-stock items: ${items.join(', ')}.';
    } else if (q.contains('technician') || q.contains('driver')) {
      final best = _rankedTechnicians().isEmpty
          ? null
          : _rankedTechnicians().first;
      answer = best == null
          ? 'No technicians are available to score.'
          : '${best.$1.name} currently has the strongest dispatch score of ${best.$2}/100.';
    } else {
      answer =
          'I found ${widget.state.activeJobs} active calls, ${widget.state.technicians.length} technicians, and ${widget.state.inventory.where((i) => i.lowStock).length} low-stock alerts.';
    }
    setState(() {
      aiHistory.add(answer);
      prompt.clear();
    });
  }

  List<(Technician, int)> _rankedTechnicians() {
    final ranked = widget.state.technicians.map((t) {
      var score = 100;
      score -= t.activeJobs * 18;
      if (t.status == TechnicianStatus.busy) score -= 25;
      if (t.status == TechnicianStatus.offDuty) score -= 55;
      if (t.status == TechnicianStatus.offline) score -= 75;
      if (t.status == TechnicianStatus.available) score += 8;
      score = score.clamp(0, 100).toInt();
      return (t, score);
    }).toList();
    ranked.sort((a, b) => b.$2.compareTo(a.$2));
    return ranked;
  }

  Widget _dispatchScoring() {
    final ranked = _rankedTechnicians();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Explainable Technician Scoring',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Current local score uses availability and workload. A production backend can add distance, traffic, skills, equipment, SLA, overtime and historical performance.',
              ),
              const SizedBox(height: 12),
              ...ranked.map(
                (r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Text('${r.$2}')),
                  title: Text(
                    r.$1.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${labelTechnicianStatus(r.$1.status)} • ${r.$1.activeJobs} active jobs • ${r.$1.area}',
                  ),
                  trailing: FilledButton(
                    onPressed:
                        widget.state.jobs
                            .where((j) => j.technician == 'Unassigned')
                            .isEmpty
                        ? null
                        : () {
                            final job = widget.state.jobs.firstWhere(
                              (j) => j.technician == 'Unassigned',
                            );
                            if (requireApproval) {
                              _confirmAssignment(job, r.$1);
                            } else {
                              widget.state.assignTechnician(job, r.$1.name);
                            }
                          },
                    child: const Text('Assign Next'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmAssignment(
    RoadsideJob job,
    Technician technician,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve AI recommendation?'),
        content: Text('Assign ${job.id} to ${technician.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
    if (ok == true) widget.state.assignTechnician(job, technician.name);
  }

  Widget _callIntake() => SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Call Intake',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
        ),
        const Text(
          'Paste or dictate a call summary. V12 prepares a structured draft for dispatcher review.',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: callIntake,
          minLines: 6,
          maxLines: 10,
          decoration: const InputDecoration(
            labelText:
                'Example: John Smith, 205-555-0100, flat tire, 2020 Ford F-150, 123 Main St Birmingham',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _extractCall,
          icon: const Icon(Icons.document_scanner_outlined),
          label: const Text('Extract Job Draft'),
        ),
      ],
    ),
  );

  void _extractCall() {
    final text = callIntake.text.trim();
    if (text.isEmpty) return;
    final phone =
        RegExp(r'\b\d{3}[-. ]?\d{3}[-. ]?\d{4}\b').firstMatch(text)?.group(0) ??
        'Not detected';
    final service = ['tire', 'battery', 'lockout', 'fuel', 'jump'].firstWhere(
      (s) => text.toLowerCase().contains(s),
      orElse: () => 'roadside service',
    );
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Job Draft'),
        content: SelectableText(
          'Source: $text\n\nDetected phone: $phone\nSuggested service: ${service[0].toUpperCase()}${service.substring(1)}\n\nReview all fields before creating a real job.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Review Complete'),
          ),
        ],
      ),
    );
  }

  Widget _pricingAi() {
    final lowMargin = widget.state.jobs
        .where((j) => j.total > 0 && (j.profit / j.total) < .25)
        .toList();
    return Column(
      children: [
        _metrics([
          MetricCard(
            label: 'Revenue',
            value: money(widget.state.revenue),
            icon: Icons.attach_money,
          ),
          MetricCard(
            label: 'Profit',
            value: money(widget.state.profit),
            icon: Icons.trending_up,
          ),
          MetricCard(
            label: 'Low-Margin Jobs',
            value: '${lowMargin.length}',
            icon: Icons.warning_amber_outlined,
          ),
          MetricCard(
            label: 'Pricing Guardrails',
            value: pricingGuardrails ? 'On' : 'Off',
            icon: Icons.shield_outlined,
          ),
        ]),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Margin Protection',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Flags jobs below a 25% estimated margin. Your existing pricing workflow remains the source of the final customer price.',
              ),
              const SizedBox(height: 10),
              if (lowMargin.isEmpty)
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.check_circle_outline),
                  title: Text('No low-margin job detected.'),
                ),
              ...lowMargin.map(
                (j) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.warning_amber_outlined),
                  title: Text('${j.id} • ${j.customer}'),
                  subtitle: Text(
                    'Estimated margin ${((j.profit / j.total) * 100).toStringAsFixed(1)}% • Profit ${money(j.profit)}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _riskAlerts() {
    final duplicatePhones = <String, int>{};
    for (final j in widget.state.jobs) {
      duplicatePhones[j.phone] = (duplicatePhones[j.phone] ?? 0) + 1;
    }
    final repeated = duplicatePhones.entries
        .where((e) => e.key.isNotEmpty && e.value > 1)
        .length;
    final missingCoords = widget.state.jobs
        .where((j) => !j.hasCoordinates)
        .length;
    final unpaidCompleted = widget.state.jobs
        .where((j) => j.status == JobStatus.completed && !j.paid)
        .length;
    return Column(
      children: [
        _metrics([
          MetricCard(
            label: 'Repeated Phones',
            value: '$repeated',
            icon: Icons.content_copy_outlined,
          ),
          MetricCard(
            label: 'Missing GPS',
            value: '$missingCoords',
            icon: Icons.location_off_outlined,
          ),
          MetricCard(
            label: 'Completed Unpaid',
            value: '$unpaidCompleted',
            icon: Icons.money_off_outlined,
          ),
          MetricCard(
            label: 'Risk Monitoring',
            value: fraudAlerts ? 'Enabled' : 'Disabled',
            icon: Icons.security_outlined,
          ),
        ]),
        const SizedBox(height: 16),
        _listSection('Review Alerts', [
          (
            'Duplicate and repeat detection',
            'Repeated customer information is highlighted for review, not treated as wrongdoing.',
          ),
          (
            'GPS consistency',
            '$missingCoords job(s) do not currently contain verified coordinates.',
          ),
          (
            'Payment completion',
            '$unpaidCompleted completed job(s) remain marked unpaid.',
          ),
          (
            'Compliance monitoring',
            complianceAlerts
                ? 'Credential and documentation alerts are enabled.'
                : 'Compliance alerts are disabled.',
          ),
        ], Icons.policy_outlined),
      ],
    );
  }

  Widget _forecasting() {
    final completed = widget.state.jobs
        .where((j) => j.status == JobStatus.completed)
        .length;
    final baseline = math.max(1, widget.state.jobs.length);
    final projectedCalls = (baseline * 1.15).ceil();
    final avgTicket = widget.state.jobs.isEmpty
        ? 0.0
        : widget.state.revenue / widget.state.jobs.length;
    final projectedRevenue = projectedCalls * avgTicket;
    return Column(
      children: [
        _metrics([
          MetricCard(
            label: 'Recorded Jobs',
            value: '${widget.state.jobs.length}',
            icon: Icons.history,
          ),
          MetricCard(
            label: 'Completed',
            value: '$completed',
            icon: Icons.task_alt,
          ),
          MetricCard(
            label: 'Demo Call Forecast',
            value: '$projectedCalls',
            icon: Icons.query_stats_outlined,
          ),
          MetricCard(
            label: 'Demo Revenue Forecast',
            value: money(projectedRevenue),
            icon: Icons.show_chart,
          ),
        ]),
        const SizedBox(height: 16),
        _listSection('Forecast Inputs Needed for Production', const [
          (
            'Historical volume',
            'At least several weeks of complete call records by time and service area.',
          ),
          (
            'Weather and traffic',
            'Optional external signals for demand and ETA modeling.',
          ),
          (
            'Technician schedules',
            'Availability, qualifications, overtime and regional coverage.',
          ),
          (
            'Inventory usage',
            'Accurate stock deductions and replenishment history.',
          ),
        ], Icons.data_usage_outlined),
      ],
    );
  }

  Widget _reconciliation() {
    final completed = widget.state.jobs
        .where((j) => j.status == JobStatus.completed)
        .toList();
    final unpaid = completed.where((j) => !j.paid).toList();
    return Column(
      children: [
        _metrics([
          MetricCard(
            label: 'Completed Jobs',
            value: '${completed.length}',
            icon: Icons.task_alt,
          ),
          MetricCard(
            label: 'Awaiting Payment',
            value: '${unpaid.length}',
            icon: Icons.hourglass_bottom,
          ),
          MetricCard(
            label: 'Motor Club Calls',
            value: '${widget.state.clubDispatches.length}',
            icon: Icons.hub_outlined,
          ),
          MetricCard(
            label: 'Partner Connectors',
            value: '${widget.state.partnerConnectors.length}',
            icon: Icons.api_outlined,
          ),
        ]),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Reconciliation Review',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Compares completed work, payment status and partner references to prepare a human review queue.',
              ),
              const SizedBox(height: 10),
              if (unpaid.isEmpty)
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.check_circle_outline),
                  title: Text('No completed unpaid job is currently recorded.'),
                ),
              ...unpaid.map(
                (j) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: Text('${j.id} • ${j.customer}'),
                  subtitle: Text(
                    '${j.service} • ${money(j.total)} • ${j.paymentMethod}',
                  ),
                  trailing: const Chip(label: Text('Review')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget
  _safetyCoach() => _listSection('AI Safety & Technician Coaching', const [
    (
      'Tire service checklist',
      'Confirm safe parking position, stabilization, jack points and lug-nut torque procedure.',
    ),
    (
      'Battery service checklist',
      'Confirm eye protection, terminal polarity, ventilation and secure battery mounting.',
    ),
    (
      'Lockout checklist',
      'Confirm authorization, vehicle identity, protected entry method and damage documentation.',
    ),
    (
      'Roadside scene safety',
      'Confirm reflective equipment, warning lights, traffic exposure and escape route.',
    ),
    (
      'Coaching summary',
      'Compare response time, documentation quality and completion patterns without making automatic disciplinary decisions.',
    ),
  ], Icons.health_and_safety_outlined);

  Widget _controls() => Column(
    children: [
      SectionCard(
        child: Column(
          children: [
            SwitchListTile(
              value: requireApproval,
              onChanged: (v) => setState(() => requireApproval = v),
              title: const Text('Require human approval'),
              subtitle: const Text(
                'Recommended for dispatch, pricing, payments and external communications.',
              ),
            ),
            SwitchListTile(
              value: explainRecommendations,
              onChanged: (v) => setState(() => explainRecommendations = v),
              title: const Text('Explain AI recommendations'),
              subtitle: const Text(
                'Show the factors used in every technician or business recommendation.',
              ),
            ),
            SwitchListTile(
              value: fraudAlerts,
              onChanged: (v) => setState(() => fraudAlerts = v),
              title: const Text('Fraud and anomaly review alerts'),
              subtitle: const Text(
                'Alerts indicate items for review and are not accusations.',
              ),
            ),
            SwitchListTile(
              value: complianceAlerts,
              onChanged: (v) => setState(() => complianceAlerts = v),
              title: const Text('Compliance alerts'),
              subtitle: const Text(
                'Surface missing or expiring credentials and required documentation.',
              ),
            ),
            SwitchListTile(
              value: pricingGuardrails,
              onChanged: (v) => setState(() => pricingGuardrails = v),
              title: const Text('Pricing and margin guardrails'),
              subtitle: const Text(
                'Warn before a job falls below the configured profit target.',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      _listSection('Production AI Requirements', const [
        (
          'Secure backend',
          'API keys and model credentials must never be stored in the Flutter application.',
        ),
        (
          'Role permissions',
          'AI can only read or perform actions allowed for the signed-in user.',
        ),
        (
          'Audit trail',
          'Record prompts, recommendations, approvals and resulting actions.',
        ),
        (
          'Data controls',
          'Define retention, privacy, customer consent and partner-contract rules.',
        ),
        (
          'Fallback operations',
          'Dispatch and job completion must still work when AI services are unavailable.',
        ),
      ], Icons.admin_panel_settings_outlined),
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
}
