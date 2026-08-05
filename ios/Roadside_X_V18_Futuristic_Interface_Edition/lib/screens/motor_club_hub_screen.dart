import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/entities.dart';
import '../models/motor_club.dart';
import '../services/motor_club_integration_service.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class MotorClubHubScreen extends StatefulWidget {
  const MotorClubHubScreen({super.key, required this.state});
  final AppState state;

  @override
  State<MotorClubHubScreen> createState() => _MotorClubHubScreenState();
}

class _MotorClubHubScreenState extends State<MotorClubHubScreen> {
  int tab = 0;
  final service = const MotorClubIntegrationService();

  @override
  Widget build(BuildContext context) {
    final incoming = widget.state.clubDispatches
        .where((d) => d.status == ClubDispatchStatus.incoming)
        .length;
    final active = widget.state.clubDispatches
        .where(
          (d) => !{
            ClubDispatchStatus.completed,
            ClubDispatchStatus.cancelled,
            ClubDispatchStatus.declined,
            ClubDispatchStatus.paid,
          }.contains(d.status),
        )
        .length;
    final connected = widget.state.partnerConnectors
        .where((c) => c.status == ConnectorStatus.connected)
        .length;
    final awaitingPayment = widget.state.clubDispatches
        .where((d) => d.status == ClubDispatchStatus.invoiced)
        .fold<double>(0, (sum, d) => sum + d.authorizedAmount);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1450),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const SizedBox(
                      width: 760,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Motor Club & Insurance Integration Hub',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Receive, manage, bill, and reconcile partner dispatches. Live connections activate when approved credentials are supplied.',
                            style: TextStyle(color: Color(0xFF9CB1C9)),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _createTestDispatch,
                      icon: const Icon(Icons.science_outlined),
                      label: const Text('Generate Test Dispatch'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _manualDispatch,
                      icon: const Icon(Icons.add),
                      label: const Text('Manual Import'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
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
                        label: 'Incoming Calls',
                        value: '$incoming',
                        icon: Icons.inbox_outlined,
                      ),
                      MetricCard(
                        label: 'Active Partner Jobs',
                        value: '$active',
                        icon: Icons.local_shipping_outlined,
                      ),
                      MetricCard(
                        label: 'Connected Partners',
                        value:
                            '$connected/${widget.state.partnerConnectors.length}',
                        icon: Icons.hub_outlined,
                      ),
                      MetricCard(
                        label: 'Awaiting Payment',
                        value: money(awaitingPayment),
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                      value: 0,
                      label: Text('Dispatch Inbox'),
                      icon: Icon(Icons.inbox_outlined),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text('Partner Connections'),
                      icon: Icon(Icons.hub_outlined),
                    ),
                    ButtonSegment(
                      value: 2,
                      label: Text('Billing Queue'),
                      icon: Icon(Icons.receipt_long_outlined),
                    ),
                    ButtonSegment(
                      value: 3,
                      label: Text('Integration Logs'),
                      icon: Icon(Icons.terminal_outlined),
                    ),
                  ],
                  selected: {tab},
                  onSelectionChanged: (value) =>
                      setState(() => tab = value.first),
                ),
                const SizedBox(height: 16),
                if (tab == 0) _dispatchInbox(),
                if (tab == 1) _connections(),
                if (tab == 2) _billingQueue(),
                if (tab == 3) _logs(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dispatchInbox() {
    final dispatches = widget.state.clubDispatches;
    if (dispatches.isEmpty)
      return const SectionCard(
        child: Text(
          'No motor-club dispatches yet. Generate a test call or import one manually.',
        ),
      );
    return SectionCard(
      child: Column(
        children: dispatches
            .map(
              (d) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Chip(label: Text(d.partner)),
                          Chip(label: Text(clubDispatchStatusLabel(d.status))),
                          Text(
                            '${d.id} • Partner Ref ${d.referenceNumber}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${d.customer} • ${d.phone} • ${d.vehicle}'),
                      Text('${d.service} • ${d.pickupAddress}'),
                      if (d.destinationAddress.isNotEmpty)
                        Text('Destination: ${d.destinationAddress}'),
                      Text(
                        'Authorization: ${money(d.authorizedAmount)} • ${d.authorizedMiles.toStringAsFixed(1)} miles • PO ${d.purchaseOrder.isEmpty ? 'Not supplied' : d.purchaseOrder}',
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (d.status == ClubDispatchStatus.incoming) ...[
                            FilledButton.icon(
                              onPressed: () =>
                                  widget.state.updateClubDispatchStatus(
                                    d,
                                    ClubDispatchStatus.accepted,
                                  ),
                              icon: const Icon(Icons.check),
                              label: const Text('Accept'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  widget.state.updateClubDispatchStatus(
                                    d,
                                    ClubDispatchStatus.declined,
                                  ),
                              icon: const Icon(Icons.close),
                              label: const Text('Decline'),
                            ),
                          ],
                          FilledButton.tonalIcon(
                            onPressed: () => _assignTechnician(d),
                            icon: const Icon(Icons.engineering),
                            label: Text(
                              d.technician == 'Unassigned'
                                  ? 'Assign Tech'
                                  : d.technician,
                            ),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () => _advanceStatus(d),
                            icon: const Icon(Icons.update),
                            label: const Text('Advance Status'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _copyPayload(d),
                            icon: const Icon(Icons.data_object),
                            label: const Text('Copy JSON'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _details(d),
                            icon: const Icon(Icons.visibility_outlined),
                            label: const Text('Details'),
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
  }

  Widget _connections() => SectionCard(
    child: Column(
      children: widget.state.partnerConnectors
          .map(
            (c) => ListTile(
              leading: CircleAvatar(child: Icon(_categoryIcon(c.category))),
              title: Text(c.name),
              subtitle: Text(
                '${c.category.name} • ${c.mode.name.toUpperCase()} • Provider ID: ${c.providerId.isEmpty ? 'Not configured' : c.providerId}',
              ),
              trailing: Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Chip(label: Text(connectorStatusLabel(c.status))),
                  IconButton(
                    tooltip: 'Edit connector',
                    onPressed: () => _editConnector(c),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Test connection',
                    onPressed: () => _testConnector(c),
                    icon: const Icon(Icons.cable_outlined),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );

  Widget _billingQueue() {
    final items = widget.state.clubDispatches
        .where(
          (d) => {
            ClubDispatchStatus.completed,
            ClubDispatchStatus.invoiced,
            ClubDispatchStatus.paid,
          }.contains(d.status),
        )
        .toList();
    if (items.isEmpty)
      return const SectionCard(
        child: Text(
          'Completed partner jobs will appear here for invoicing and payment reconciliation.',
        ),
      );
    return SectionCard(
      child: Column(
        children: items
            .map(
              (d) => ListTile(
                leading: Icon(
                  d.status == ClubDispatchStatus.paid
                      ? Icons.verified
                      : Icons.receipt_long_outlined,
                ),
                title: Text('${d.partner} • ${d.referenceNumber}'),
                subtitle: Text(
                  '${d.customer} • ${d.service} • ${clubDispatchStatusLabel(d.status)}',
                ),
                trailing: Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      money(d.authorizedAmount),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    if (d.status == ClubDispatchStatus.completed)
                      FilledButton.tonal(
                        onPressed: () => widget.state.updateClubDispatchStatus(
                          d,
                          ClubDispatchStatus.invoiced,
                        ),
                        child: const Text('Create Invoice'),
                      ),
                    if (d.status == ClubDispatchStatus.invoiced)
                      FilledButton.tonal(
                        onPressed: () => widget.state.updateClubDispatchStatus(
                          d,
                          ClubDispatchStatus.paid,
                        ),
                        child: const Text('Mark Paid'),
                      ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _logs() => SectionCard(
    child: Column(
      children: widget.state.integrationLogs
          .map(
            (log) => ListTile(
              leading: const Icon(Icons.terminal),
              title: Text(log.action),
              subtitle: Text('${log.actor} • ${log.time}'),
            ),
          )
          .toList(),
    ),
  );

  IconData _categoryIcon(PartnerCategory c) {
    switch (c) {
      case PartnerCategory.motorClub:
        return Icons.car_crash_outlined;
      case PartnerCategory.insurance:
        return Icons.shield_outlined;
      case PartnerCategory.fleet:
        return Icons.local_shipping_outlined;
      case PartnerCategory.dealership:
        return Icons.storefront_outlined;
      case PartnerCategory.rental:
        return Icons.car_rental_outlined;
      case PartnerCategory.platform:
        return Icons.hub_outlined;
    }
  }

  Future<void> _testConnector(PartnerConnector connector) async {
    connector.status = ConnectorStatus.testing;
    widget.state.savePartnerConnector(
      connector,
      logMessage: 'Testing ${connector.name} connector',
    );
    final result = await service.testConnector(connector);
    connector.status = result.ok
        ? ConnectorStatus.connected
        : ConnectorStatus.attention;
    connector.lastSync = DateTime.now();
    widget.state.savePartnerConnector(
      connector,
      logMessage: '${connector.name}: ${result.message}',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _editConnector(PartnerConnector connector) async {
    final provider = TextEditingController(text: connector.providerId);
    final endpoint = TextEditingController(text: connector.endpoint);
    final keyLabel = TextEditingController(text: connector.apiKeyLabel);
    final notes = TextEditingController(text: connector.notes);
    var mode = connector.mode;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${connector.name} Connection'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<IntegrationMode>(
                    value: mode,
                    decoration: const InputDecoration(
                      labelText: 'Connection Method',
                    ),
                    items: IntegrationMode.values
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(m.name.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => mode = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: provider,
                    decoration: const InputDecoration(
                      labelText: 'Provider / Account ID',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: endpoint,
                    decoration: const InputDecoration(
                      labelText: 'API or Webhook Endpoint',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: keyLabel,
                    decoration: const InputDecoration(
                      labelText:
                          'Credential Label (never store raw production secrets here)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notes,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'A live partner connection requires that partner’s approval, documentation, and credentials. Store production secrets on a secure backend, not inside Flutter.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9CB1C9)),
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
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (saved != true) return;
    connector.mode = mode;
    connector.providerId = provider.text.trim();
    connector.endpoint = endpoint.text.trim();
    connector.apiKeyLabel = keyLabel.text.trim();
    connector.notes = notes.text.trim();
    connector.status = ConnectorStatus.disconnected;
    widget.state.savePartnerConnector(
      connector,
      logMessage: 'Updated ${connector.name} connector settings',
    );
  }

  Future<void> _assignTechnician(ClubDispatch dispatch) async {
    final tech = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Assign Technician'),
        children: widget.state.technicians
            .map(
              (t) => SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, t.name),
                child: ListTile(
                  leading: const Icon(Icons.engineering),
                  title: Text(t.name),
                  subtitle: Text(
                    '${t.area} • ${labelTechnicianStatus(t.status)}',
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
    if (tech != null) widget.state.assignClubDispatch(dispatch, tech);
  }

  void _advanceStatus(ClubDispatch d) {
    const flow = [
      ClubDispatchStatus.incoming,
      ClubDispatchStatus.accepted,
      ClubDispatchStatus.assigned,
      ClubDispatchStatus.enRoute,
      ClubDispatchStatus.onSite,
      ClubDispatchStatus.completed,
      ClubDispatchStatus.invoiced,
      ClubDispatchStatus.paid,
    ];
    final index = flow.indexOf(d.status);
    if (index >= 0 && index < flow.length - 1)
      widget.state.updateClubDispatchStatus(d, flow[index + 1]);
  }

  void _copyPayload(ClubDispatch d) {
    Clipboard.setData(ClipboardData(text: service.exportDispatchJson(d)));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Dispatch JSON copied.')));
  }

  void _details(ClubDispatch d) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('${d.partner} Dispatch ${d.referenceNumber}'),
      content: SizedBox(
        width: 520,
        child: SelectableText(service.exportDispatchJson(d)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  void _createTestDispatch() => widget.state.addClubDispatch(
    ClubDispatch(
      id: 'MC-${DateTime.now().millisecondsSinceEpoch}',
      partner: widget.state.partnerConnectors.isEmpty
          ? 'Test Motor Club'
          : widget.state.partnerConnectors.first.name,
      referenceNumber:
          'TEST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      purchaseOrder:
          'PO-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      customer: 'Test Customer',
      phone: '205-555-0199',
      vehicle: '2022 Ford Explorer',
      service: 'Tire Change',
      pickupAddress: '2101 5th Avenue North, Birmingham, AL',
      authorizedAmount: 175,
      authorizedMiles: 15,
      notes: 'Sandbox dispatch generated inside Roadside X.',
    ),
  );

  Future<void> _manualDispatch() async {
    final partner = TextEditingController();
    final reference = TextEditingController();
    final po = TextEditingController();
    final customer = TextEditingController();
    final phone = TextEditingController();
    final vehicle = TextEditingController();
    final serviceType = TextEditingController();
    final pickup = TextEditingController();
    final destination = TextEditingController();
    final amount = TextEditingController(text: '0');
    final miles = TextEditingController(text: '0');
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import Partner Dispatch'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: partner,
                  decoration: const InputDecoration(
                    labelText: 'Motor Club / Insurance Company',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: reference,
                  decoration: const InputDecoration(
                    labelText: 'Dispatch Reference Number',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: po,
                  decoration: const InputDecoration(
                    labelText: 'Purchase Order Number',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: customer,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phone,
                  decoration: const InputDecoration(
                    labelText: 'Customer Phone',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: vehicle,
                  decoration: const InputDecoration(labelText: 'Vehicle'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: serviceType,
                  decoration: const InputDecoration(
                    labelText: 'Service Requested',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pickup,
                  decoration: const InputDecoration(
                    labelText: 'Pickup / Breakdown Address',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: destination,
                  decoration: const InputDecoration(
                    labelText: 'Destination (optional)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Authorized Amount',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: miles,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Authorized Miles',
                  ),
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
              if (partner.text.trim().isEmpty ||
                  reference.text.trim().isEmpty ||
                  customer.text.trim().isEmpty ||
                  pickup.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Partner, reference, customer, and pickup address are required.',
                    ),
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (saved != true) return;
    widget.state.addClubDispatch(
      ClubDispatch(
        id: 'MC-${DateTime.now().millisecondsSinceEpoch}',
        partner: partner.text.trim(),
        referenceNumber: reference.text.trim(),
        purchaseOrder: po.text.trim(),
        customer: customer.text.trim(),
        phone: phone.text.trim(),
        vehicle: vehicle.text.trim(),
        service: serviceType.text.trim(),
        pickupAddress: pickup.text.trim(),
        destinationAddress: destination.text.trim(),
        authorizedAmount: double.tryParse(amount.text) ?? 0,
        authorizedMiles: double.tryParse(miles.text) ?? 0,
      ),
    );
  }
}
