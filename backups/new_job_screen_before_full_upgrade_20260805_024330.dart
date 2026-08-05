import 'package:flutter/material.dart';
import '../models/entities.dart';
import '../services/gps_service.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class NewJobScreen extends StatefulWidget {
  const NewJobScreen({super.key, required this.state, required this.onCreated});
  final AppState state;
  final VoidCallback onCreated;

  @override
  State<NewJobScreen> createState() => _NewJobScreenState();
}

class _NewJobScreenState extends State<NewJobScreen> {
  final customer = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final service = TextEditingController(text: 'Tire Replacement');
  final total = TextEditingController(text: '225');
  final parts = TextEditingController(text: '100');
  AddressResult? foundAddress;
  bool locating = false;

  @override
  void dispose() {
    customer.dispose();
    phone.dispose();
    address.dispose();
    service.dispose();
    total.dispose();
    parts.dispose();
    super.dispose();
  }

  double value(TextEditingController controller) =>
      double.tryParse(controller.text) ?? 0;

  Future<void> locateAddress() async {
    setState(() => locating = true);
    try {
      final result = await GpsService.geocodeAddress(address.text);
      if (!mounted) return;
      setState(() {
        foundAddress = result;
        address.text = result.displayName;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer address located and pinned on the GPS map.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  Future<void> createJob() async {
    if (customer.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a customer name.')));
      return;
    }
    if (address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the customer service address.')),
      );
      return;
    }

    if (foundAddress == null) await locateAddress();
    if (!mounted || foundAddress == null) return;

    widget.state.addJob(
      RoadsideJob(
        id: 'JR-${4100 + widget.state.jobs.length + 1}',
        customer: customer.text.trim(),
        phone: phone.text.trim(),
        service: service.text.trim(),
        location: address.text.trim(),
        total: value(total),
        partsCost: value(parts),
        status: JobStatus.newJob,
        latitude: foundAddress!.latitude,
        longitude: foundAddress!.longitude,
      ),
    );
    widget.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: customer,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                ),
              ),
              SizedBox(
                width: 260,
                child: TextField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
              ),
              SizedBox(
                width: 520,
                child: TextField(
                  controller: address,
                  onChanged: (_) => foundAddress = null,
                  onSubmitted: (_) => locateAddress(),
                  decoration: InputDecoration(
                    labelText: 'Customer Address',
                    hintText: 'Street, city, state, ZIP',
                    suffixIcon: locating
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            onPressed: locateAddress,
                            icon: const Icon(Icons.location_searching),
                            tooltip: 'Find address',
                          ),
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: service,
                  decoration: const InputDecoration(labelText: 'Service Type'),
                ),
              ),
              SizedBox(
                width: 220,
                child: TextField(
                  controller: parts,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Company Parts Cost',
                  ),
                ),
              ),
              SizedBox(
                width: 220,
                child: TextField(
                  controller: total,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Customer Total',
                  ),
                ),
              ),
            ],
          ),
          if (foundAddress != null) ...[
            const SizedBox(height: 14),
            ListTile(
              tileColor: const Color(0xFF10243C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: const Icon(Icons.location_on, color: Colors.greenAccent),
              title: const Text('GPS location confirmed'),
              subtitle: Text(
                '${foundAddress!.latitude.toStringAsFixed(6)}, ${foundAddress!.longitude.toStringAsFixed(6)}',
              ),
              trailing: TextButton.icon(
                onPressed: () => GpsService.openNavigation(
                  latitude: foundAddress!.latitude,
                  longitude: foundAddress!.longitude,
                ),
                icon: const Icon(Icons.navigation),
                label: const Text('Preview Route'),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Customer Total',
                  value: money(value(total)),
                  icon: Icons.receipt,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  label: 'Projected Profit',
                  value: money(value(total) - value(parts)),
                  icon: Icons.savings,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: locating ? null : locateAddress,
                icon: const Icon(Icons.pin_drop),
                label: const Text('Verify Address'),
              ),
              FilledButton.icon(
                onPressed: locating ? null : createJob,
                icon: const Icon(Icons.send),
                label: const Text('Create & Dispatch Job'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
