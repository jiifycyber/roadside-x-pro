import 'package:flutter/material.dart';
import '../models/entities.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/futuristic.dart';
import 'new_job_screen.dart';
import 'gps_dispatch_screen.dart';
import 'motor_club_hub_screen.dart';
import 'v12_advanced_ai_screen.dart';
import 'v13_ai_call_center_screen.dart';
import 'v14_growth_integrations_screen.dart';
import 'v11_intelligent_automation_screen.dart';
import 'v17_community_network_screen.dart';

class _BrandOrb extends StatelessWidget {
  const _BrandOrb();
  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        colors: [Color(0xFF00D9FF), Color(0xFF7C4DFF), Color(0xFFFF6FD8)],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF00D9FF).withValues(alpha: .5),
          blurRadius: 24,
        ),
      ],
    ),
    child: const Icon(Icons.car_repair, color: Colors.white),
  );
}

class Phase4Shell extends StatefulWidget {
  const Phase4Shell({
    super.key,
    required this.state,
    required this.role,
    required this.displayName,
    required this.onLogout,
  });

  final AppState state;
  final UserRole role;
  final String displayName;
  final VoidCallback onLogout;

  @override
  State<Phase4Shell> createState() => _Phase4ShellState();
}

class _Phase4ShellState extends State<Phase4Shell> {
  int page = 0;
  final menu = const [
    ('Dashboard', Icons.dashboard_rounded),
    ('Customers', Icons.public),
    ('Business Integrations', Icons.link),
    ('AI Dispatcher', Icons.support_agent),
    ('AI Assistant', Icons.auto_awesome),
    ('Automation Center', Icons.psychology_alt_outlined),
    ('New Job', Icons.add_circle_outline),
    ('Dispatch Board', Icons.view_kanban_outlined),
    ('GPS Dispatch Map', Icons.map_outlined),
    ('Motor Clubs & Insurance', Icons.hub_outlined),
    ('Customers', Icons.people_outline),
    ('Technicians', Icons.engineering_outlined),
    ('Receipts', Icons.receipt_long_outlined),
    ('Inventory', Icons.inventory_2_outlined),
    ('Analytics', Icons.analytics_outlined),
    ('Companies', Icons.apartment_outlined),
    ('Subscriptions', Icons.credit_card_outlined),
    ('Users & Roles', Icons.admin_panel_settings_outlined),
    ('Activity Logs', Icons.history_outlined),
    ('Settings', Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        final narrow = MediaQuery.sizeOf(context).width < 900;
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: narrow
              ? AppBar(
                  title: Text(menu[page].$1),
                  backgroundColor: const Color(0xFF0A1C34),
                )
              : null,
          drawer: narrow
              ? Drawer(child: SafeArea(child: _sidebar(true)))
              : null,
          body: FuturisticBackground(
            child: Row(
              children: [
                if (!narrow) SizedBox(width: 286, child: _sidebar(false)),
                Expanded(child: _content()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sidebar(bool close) => Container(
    margin: const EdgeInsets.all(12),
    child: GlassPanel(
      radius: 26,
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
      glowColor: const Color(0xFF00D9FF),
      child: Column(
        children: [
          const ListTile(
            leading: _BrandOrb(),
            title: Text(
              'ROADSIDE X PRO',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 1.2,
              ),
            ),
            subtitle: Text(
              'ROADSIDE OPERATIONS PLATFORM',
              style: TextStyle(
                color: Color(0xFF63E9FF),
                letterSpacing: 1.25,
                fontSize: 10,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: menu.length,
              itemBuilder: (context, i) {
                final selected = i == page;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: selected
                          ? const LinearGradient(
                              colors: [Color(0xAA00D9FF), Color(0xAA7C4DFF)],
                            )
                          : null,
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF8CF7FF)
                            : Colors.white.withValues(alpha: .04),
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF00D9FF,
                                ).withValues(alpha: .34),
                                blurRadius: 20,
                                spreadRadius: -5,
                              ),
                            ]
                          : const [],
                    ),
                    child: ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      leading: Icon(
                        menu[i].$2,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF91A8CB),
                      ),
                      title: Text(
                        menu[i].$1,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : const Color(0xFFC5D1E7),
                          fontSize: 13,
                        ),
                      ),
                      onTap: () {
                        setState(() => page = i);
                        if (close) Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF00D9FF), Color(0xFFFF6FD8)],
                ),
              ),
              child: const Icon(Icons.person_outline, color: Colors.white),
            ),
            title: Text(
              widget.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(_roleLabel(widget.role)),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFFF6B8A)),
            title: const Text(
              'Log Out',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            onTap: () async {
              if (close) Navigator.pop(context);
              await _confirmLogout();
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                PulsingStatusDot(),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'ALL SYSTEMS ONLINE',
                    style: TextStyle(
                      color: Color(0xFF70FFC0),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Super Administrator';
      case UserRole.owner:
        return 'Owner / Administrator';
      case UserRole.dispatcher:
        return 'Dispatcher';
      case UserRole.technician:
        return 'Technician / Driver';
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out of Roadside X?'),
        content: const Text('You will return to the login screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) widget.onLogout();
  }

  Widget _content() {
    switch (page) {
      case 0:
        return _dashboard();
      case 1:
        return V17CommunityNetworkScreen(state: widget.state);
      case 2:
        return V14GrowthIntegrationsScreen(state: widget.state);
      case 3:
        return V13AiCallCenterScreen(state: widget.state);
      case 4:
        return V12AdvancedAiScreen(state: widget.state);
      case 5:
        return V11IntelligentAutomationScreen(state: widget.state);
      case 6:
        return _newJob();
      case 7:
        return _dispatch();
      case 8:
        return _gpsDispatch();
      case 9:
        return MotorClubHubScreen(state: widget.state);
      case 10:
        return _customers();
      case 11:
        return _technicians();
      case 12:
        return _receipts();
      case 13:
        return _inventory();
      case 14:
        return _analytics();
      case 15:
        return _companies();
      case 16:
        return _subscriptions();
      case 17:
        return _users();
      case 18:
        return _activity();
      default:
        return _settings();
    }
  }

  Widget _page(String title, String subtitle, Widget child, {Widget? action}) =>
      SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassPanel(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 18,
                    ),
                    glowColor: const Color(0xFF7C4DFF),
                    child: Wrap(
                      spacing: 18,
                      runSpacing: 14,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 760,
                          child: HolographicTitle(
                            title: title,
                            subtitle: subtitle,
                          ),
                        ),
                        if (action != null) action,
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  child,
                ],
              ),
            ),
          ),
        ),
      );

  Widget _dashboard() => _page(
    'Roadside X Pro Command Center',
    'Live jobs, dispatch operations, revenue, technicians, and company performance.',
    Column(
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
            childAspectRatio: 2.2,
            children: [
              MetricCard(
                label: 'Active Jobs',
                value: '${widget.state.activeJobs}',
                icon: Icons.work_outline,
              ),
              MetricCard(
                label: 'Roadside Revenue',
                value: money(widget.state.revenue),
                icon: Icons.attach_money,
              ),
              MetricCard(
                label: 'Estimated Profit',
                value: money(widget.state.profit),
                icon: Icons.trending_up,
              ),
              MetricCard(
                label: 'Monthly Recurring Revenue',
                value: money(widget.state.mrr),
                icon: Icons.autorenew,
                note: 'SaaS subscriptions',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Jobs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ...widget.state.jobs.take(5).map(_jobTile),
            ],
          ),
        ),
      ],
    ),
    action: FilledButton.icon(
      onPressed: () => setState(() => page = 6),
      icon: const Icon(Icons.add),
      label: const Text('New Job'),
    ),
  );

  Widget _jobTile(RoadsideJob j) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const CircleAvatar(child: Icon(Icons.car_repair)),
    title: Text('${j.id} • ${j.customer}'),
    subtitle: Text('${j.service} • ${j.location} • ${j.technician}'),
    trailing: Chip(label: Text(labelStatus(j.status))),
  );

  Widget _newJob() => _page(
    'Create New GPS Job',
    'Type the customer address, verify the map pin, calculate pricing, and send the call to dispatch.',
    NewJobScreen(
      state: widget.state,
      onCreated: () => setState(() => page = 7),
    ),
  );

  Widget _gpsDispatch() => _page(
    'Live GPS Dispatch Map',
    'Track the current device, view customer job pins, and launch turn-by-turn driving directions.',
    GpsDispatchScreen(state: widget.state),
  );

  Widget _dispatch() => _page(
    'Live Dispatch Board',
    'Assign technicians and update every roadside call from New through Completed.',
    Column(
      children: widget.state.jobs
          .map(
            (j) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SectionCard(
                child: Column(
                  children: [
                    _jobTile(j),
                    const Divider(),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        DropdownButton<JobStatus>(
                          value: j.status,
                          items: JobStatus.values
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(labelStatus(s)),
                                ),
                              )
                              .toList(),
                          onChanged: (s) {
                            if (s != null) widget.state.updateJobStatus(j, s);
                          },
                        ),
                        DropdownButton<String>(
                          value:
                              widget.state.technicians.any(
                                (t) => t.name == j.technician,
                              )
                              ? j.technician
                              : null,
                          hint: const Text('Assign Technician'),
                          items: widget.state.technicians
                              .where(
                                (t) =>
                                    t.status != TechnicianStatus.offline &&
                                    t.status != TechnicianStatus.offDuty,
                              )
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t.name,
                                  child: Text(
                                    '${t.name} • ${labelTechnicianStatus(t.status)}',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) widget.state.assignTechnician(j, v);
                          },
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _showReceipt(j),
                          icon: const Icon(Icons.receipt),
                          label: const Text('Receipt'),
                        ),
                        if (j.hasCoordinates)
                          OutlinedButton.icon(
                            onPressed: () => setState(() => page = 8),
                            icon: const Icon(Icons.map),
                            label: const Text('View on GPS Map'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    ),
  );

  Widget _customers() => _page(
    'Customer Management',
    'Searchable customer history and vehicle records.',
    SectionCard(
      child: Column(
        children: widget.state.customers
            .map(
              (c) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(c.name),
                subtitle: Text('${c.phone} • ${c.vehicle}'),
                trailing: Chip(label: Text('${c.jobs} jobs')),
              ),
            )
            .toList(),
      ),
    ),
  );

  Widget _technicians() => _page(
    'Technician Management',
    'Add, edit, remove, assign, and change technician availability without editing code.',
    widget.state.technicians.isEmpty
        ? const SectionCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text('No technicians added yet.'),
              ),
            ),
          )
        : Column(
            children: widget.state.technicians
                .map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SectionCard(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final details = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.name,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${t.phone} • ${t.area} • ${t.activeJobs} active jobs',
                              ),
                              const SizedBox(height: 10),
                              DropdownButton<TechnicianStatus>(
                                value: t.status,
                                isExpanded: constraints.maxWidth < 600,
                                items: TechnicianStatus.values
                                    .map(
                                      (status) => DropdownMenuItem(
                                        value: status,
                                        child: Text(
                                          labelTechnicianStatus(status),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (status) {
                                  if (status != null)
                                    widget.state.setTechnicianStatus(t, status);
                                },
                              ),
                            ],
                          );
                          final actions = Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _showTechnicianDialog(t),
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _showTechnicianJobs(t),
                                icon: const Icon(Icons.assignment_ind),
                                label: const Text('Jobs'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _removeTechnician(t),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Remove'),
                              ),
                            ],
                          );
                          if (constraints.maxWidth < 700)
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                details,
                                const SizedBox(height: 12),
                                actions,
                              ],
                            );
                          return Row(
                            children: [
                              const CircleAvatar(
                                child: Icon(Icons.engineering),
                              ),
                              const SizedBox(width: 14),
                              Expanded(child: details),
                              actions,
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
    action: FilledButton.icon(
      onPressed: () => _showTechnicianDialog(),
      icon: const Icon(Icons.person_add),
      label: const Text('Add Technician'),
    ),
  );

  Future<void> _showTechnicianDialog([Technician? technician]) async {
    final name = TextEditingController(text: technician?.name ?? '');
    final phone = TextEditingController(text: technician?.phone ?? '');
    final area = TextEditingController(text: technician?.area ?? '');
    var status = technician?.status ?? TechnicianStatus.available;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            technician == null ? 'Add Technician' : 'Edit Technician',
          ),
          content: SizedBox(
            width: 430,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(
                      labelText: 'Technician Name',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: area,
                    decoration: const InputDecoration(
                      labelText: 'Service Area',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TechnicianStatus>(
                    value: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: TechnicianStatus.values
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(labelTechnicianStatus(s)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setDialogState(() => status = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (name.text.trim().isEmpty ||
                    phone.text.trim().isEmpty ||
                    area.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enter the technician name, phone number, and service area.',
                      ),
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (saved != true) return;
    if (technician == null) {
      widget.state.addTechnician(
        Technician(
          id: 'TECH-${DateTime.now().millisecondsSinceEpoch}',
          name: name.text.trim(),
          phone: phone.text.trim(),
          area: area.text.trim(),
          status: status,
        ),
      );
    } else {
      widget.state.updateTechnician(
        technician,
        name: name.text.trim(),
        phone: phone.text.trim(),
        area: area.text.trim(),
        status: status,
      );
    }
  }

  void _removeTechnician(Technician technician) {
    final removed = widget.state.removeTechnician(technician);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          removed
              ? '${technician.name} was removed.'
              : '${technician.name} still has an active assigned job. Reassign or complete that job first.',
        ),
      ),
    );
  }

  void _showTechnicianJobs(Technician technician) {
    final jobs = widget.state.jobs
        .where((j) => j.technician == technician.name)
        .toList();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${technician.name} Jobs'),
        content: SizedBox(
          width: 500,
          child: jobs.isEmpty
              ? const Text('No jobs assigned to this technician.')
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: jobs.map(_jobTile).toList(),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _receipts() => _page(
    'Receipts & Invoices',
    'Customer-safe receipts with internal profit kept private.',
    SectionCard(
      child: Column(
        children: widget.state.jobs
            .map(
              (j) => ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text('${j.id} • ${j.customer}'),
                subtitle: Text('${j.service} • ${money(j.total)}'),
                trailing: FilledButton(
                  onPressed: () => _showReceipt(j),
                  child: const Text('View'),
                ),
              ),
            )
            .toList(),
      ),
    ),
  );

  void _showReceipt(RoadsideJob j) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Jiffy Roadside Receipt'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Jiffy Roadside Assistance Corporation\n313-952-5266'),
            const Divider(),
            Text(
              'Receipt: ${j.id}\nCustomer: ${j.customer}\nService: ${j.service}\nLocation: ${j.location}\nTotal Paid: ${money(j.total)}',
            ),
            const SizedBox(height: 16),
            const Text(
              'Thank you for choosing Jiffy Roadside Assistance Corporation.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connect email/SMS service to send receipts.'),
            ),
          ),
          icon: const Icon(Icons.send),
          label: const Text('Send'),
        ),
      ],
    ),
  );

  Widget _inventory() => _page(
    'Inventory Management',
    'Track batteries, tires, equipment, and low-stock alerts.',
    SectionCard(
      child: Column(
        children: widget.state.inventory
            .map(
              (i) => ListTile(
                leading: Icon(
                  i.lowStock ? Icons.warning_amber : Icons.inventory_2,
                  color: i.lowStock ? Colors.orange : null,
                ),
                title: Text(i.name),
                subtitle: Text('${i.category} • Reorder at ${i.reorderAt}'),
                trailing: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => widget.state.adjustInventory(i, -1),
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '${i.quantity}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => widget.state.adjustInventory(i, 1),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    ),
  );

  Widget _analytics() => _page(
    'Business Analytics',
    'Revenue, profit, service demand, and performance intelligence.',
    Column(
      children: [
        LayoutBuilder(
          builder: (context, c) => GridView.count(
            crossAxisCount: c.maxWidth > 800 ? 3 : 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.2,
            children: [
              MetricCard(
                label: 'Revenue',
                value: money(widget.state.revenue),
                icon: Icons.attach_money,
              ),
              MetricCard(
                label: 'Profit Margin',
                value: widget.state.revenue == 0
                    ? '0%'
                    : '${(widget.state.profit / widget.state.revenue * 100).toStringAsFixed(1)}%',
                icon: Icons.percent,
              ),
              MetricCard(
                label: 'Completed Jobs',
                value:
                    '${widget.state.jobs.where((j) => j.status == JobStatus.completed).length}',
                icon: Icons.check_circle_outline,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Service Performance',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...widget.state.jobs.map(
                (j) => ListTile(
                  title: Text(j.service),
                  subtitle: LinearProgressIndicator(
                    value: (j.total / 500).clamp(0, 1),
                  ),
                  trailing: Text(money(j.total)),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _companies() => _page(
    'Company Management',
    'Operate Jiffy and license the platform to other roadside companies.',
    SectionCard(
      child: Column(
        children: widget.state.companies
            .map(
              (c) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.apartment)),
                title: Text(c.name),
                subtitle: Text('${c.plan} Plan • ${c.users} users'),
                trailing: Chip(label: Text(c.status.name)),
              ),
            )
            .toList(),
      ),
    ),
    action: FilledButton.icon(
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Company onboarding form is ready for backend connection.',
          ),
        ),
      ),
      icon: const Icon(Icons.add),
      label: const Text('Add Company'),
    ),
  );

  Widget _subscriptions() => _page(
    'Subscriptions & Access Control',
    'Suspend unpaid accounts and restore access after payment.',
    SectionCard(
      child: Column(
        children: widget.state.companies
            .map(
              (c) => ListTile(
                leading: Icon(
                  c.status == SubscriptionStatus.active
                      ? Icons.verified
                      : Icons.lock_outline,
                ),
                title: Text(c.name),
                subtitle: Text(
                  '${c.plan} • ${money(c.monthlyPrice)}/month • ${c.status.name}',
                ),
                trailing: FilledButton.tonal(
                  onPressed: () => widget.state.toggleSubscription(c),
                  child: Text(
                    c.status == SubscriptionStatus.active
                        ? 'Suspend'
                        : 'Activate',
                  ),
                ),
              ),
            )
            .toList(),
      ),
    ),
  );

  Widget _users() => _page(
    'Users, Roles & Permissions',
    'Role-based access for owner, dispatcher, technician, and super admin accounts.',
    const SectionCard(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.shield),
            title: Text('Jontarius Cooper'),
            subtitle: Text('Super Admin • Full system access'),
            trailing: Chip(label: Text('Active')),
          ),
          ListTile(
            leading: Icon(Icons.support_agent),
            title: Text('Dispatcher Account'),
            subtitle: Text('Jobs, customers, quotes, dispatch, receipts'),
            trailing: Chip(label: Text('Dispatcher')),
          ),
          ListTile(
            leading: Icon(Icons.engineering),
            title: Text('Technician Account'),
            subtitle: Text('Assigned jobs, status updates, navigation'),
            trailing: Chip(label: Text('Technician')),
          ),
        ],
      ),
    ),
  );

  Widget _activity() => _page(
    'Activity Logs',
    'Audit important actions across jobs, users, billing, and security.',
    SectionCard(
      child: Column(
        children: widget.state.activity
            .map(
              (a) => ListTile(
                leading: const Icon(Icons.history),
                title: Text(a.action),
                subtitle: Text('${a.actor} • ${a.time}'),
              ),
            )
            .toList(),
      ),
    ),
  );

  Widget _settings() => _page(
    'System Settings',
    'Company identity, security, integrations, backups, and automation.',
    const Column(
      children: [
        SectionCard(
          child: Column(
            children: [
              SwitchListTile(
                value: true,
                onChanged: null,
                title: Text('Two-Factor Authentication'),
                subtitle: Text('Required for administrators'),
              ),
              SwitchListTile(
                value: true,
                onChanged: null,
                title: Text('Automatic Backups'),
                subtitle: Text('Daily encrypted backup policy'),
              ),
              SwitchListTile(
                value: false,
                onChanged: null,
                title: Text('Offline Mobile Sync'),
                subtitle: Text('Requires backend synchronization service'),
              ),
            ],
          ),
        ),
        SizedBox(height: 14),
        SectionCard(
          child: ListTile(
            leading: Icon(Icons.integration_instructions),
            title: Text('External Integrations'),
            subtitle: Text(
              'GPS, address lookup, OpenStreetMap, and external turn-by-turn navigation are enabled. Stripe, Twilio, email, cloud database, and push notifications still require production credentials.',
            ),
          ),
        ),
      ],
    ),
  );
}
