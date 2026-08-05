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
  final email = TextEditingController();
  final address = TextEditingController();

  final vehicleYear = TextEditingController();
  final vehicleMake = TextEditingController();
  final vehicleModel = TextEditingController();
  final vehicleColor = TextEditingController();
  final licensePlate = TextEditingController();

  final parts = TextEditingController(text: '100');
  final markup = TextEditingController(text: '80');
  final serviceCall = TextEditingController(text: '125');
  final taxRate = TextEditingController(text: '10');

  final customerNotes = TextEditingController();
  final technicianNotes = TextEditingController();

  AddressResult? foundAddress;
  bool locating = false;
  bool saving = false;

  String serviceType = 'Tire Replacement';
  String priority = 'Normal';
  String paymentMethod = 'Not Selected';
  String leadSource = 'Direct Customer';
  String? assignedTechnician;

  static const serviceTypes = <String>[
    'Tire Replacement',
    'Tire Change',
    'Jump Start',
    'Battery Replacement',
    'Vehicle Lockout',
    'Fuel Delivery',
    'Winch Out',
    'Other Roadside Service',
  ];

  static const priorities = <String>['Normal', 'Urgent', 'Emergency'];

  static const paymentMethods = <String>[
    'Not Selected',
    'Cash',
    'Credit Card',
    'Zelle',
    'Cash App',
    'Apple Pay',
    'Check',
    'Invoice',
  ];

  static const leadSources = <String>[
    'Direct Customer',
    'Website / WordPress',
    'Google Ads',
    'Motor Club',
    'Insurance Company',
    'Referral',
    'Repeat Customer',
    'Other',
  ];

  double number(TextEditingController controller) {
    return double.tryParse(controller.text.trim()) ?? 0;
  }

  double get partsCost => number(parts);

  double get markupRate => number(markup);

  double get markupAmount => partsCost * markupRate / 100;

  double get customerPartsPrice => partsCost + markupAmount;

  double get serviceCallAmount => number(serviceCall);

  double get subtotal => customerPartsPrice + serviceCallAmount;

  double get taxAmount => subtotal * number(taxRate) / 100;

  double get customerTotal => subtotal + taxAmount;

  double get projectedProfit => markupAmount + serviceCallAmount;

  String money(double amount) => '\$${amount.toStringAsFixed(2)}';

  @override
  void dispose() {
    customer.dispose();
    phone.dispose();
    email.dispose();
    address.dispose();
    vehicleYear.dispose();
    vehicleMake.dispose();
    vehicleModel.dispose();
    vehicleColor.dispose();
    licensePlate.dispose();
    parts.dispose();
    markup.dispose();
    serviceCall.dispose();
    taxRate.dispose();
    customerNotes.dispose();
    technicianNotes.dispose();
    super.dispose();
  }

  Future<void> locateAddress() async {
    if (address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the customer address first.')),
      );
      return;
    }

    setState(() => locating = true);

    try {
      final result = await GpsService.geocodeAddress(address.text.trim());

      if (!mounted) return;

      setState(() => foundAddress = result);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer address verified.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => locating = false);
      }
    }
  }

  String buildServiceSummary() {
    final vehicle = [
      vehicleYear.text.trim(),
      vehicleMake.text.trim(),
      vehicleModel.text.trim(),
      vehicleColor.text.trim(),
    ].where((value) => value.isNotEmpty).join(' ');

    final details = <String>[
      serviceType,
      if (vehicle.isNotEmpty) 'Vehicle: $vehicle',
      if (licensePlate.text.trim().isNotEmpty)
        'Plate: ${licensePlate.text.trim()}',
      'Priority: $priority',
      'Payment: $paymentMethod',
      'Source: $leadSource',
      foundAddress == null
          ? 'Address Status: Unverified'
          : 'Address Status: GPS Verified',
      if (email.text.trim().isNotEmpty) 'Email: ${email.text.trim()}',
      if (customerNotes.text.trim().isNotEmpty)
        'Customer Notes: ${customerNotes.text.trim()}',
      if (technicianNotes.text.trim().isNotEmpty)
        'Technician Notes: ${technicianNotes.text.trim()}',
    ];

    return details.join(' | ');
  }

  Future<void> createJob({required bool dispatchNow}) async {
    if (customer.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a customer name.')));
      return;
    }

    if (phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the customer phone number.')),
      );
      return;
    }

    if (address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the customer service address.')),
      );
      return;
    }

    if (foundAddress == null && dispatchNow) {
      await locateAddress();
    }

    if (!mounted) return;

    setState(() => saving = true);

    try {
      final job = RoadsideJob(
        id: 'JR-${4100 + widget.state.jobs.length + 1}',
        customer: customer.text.trim(),
        phone: phone.text.trim(),
        service: buildServiceSummary(),
        location: address.text.trim(),
        total: customerTotal,
        partsCost: partsCost,
        status: JobStatus.newJob,
        latitude: foundAddress?.latitude ?? 0,
        longitude: foundAddress?.longitude ?? 0,
      );

      widget.state.addJob(job);

      if (assignedTechnician != null && assignedTechnician!.trim().isNotEmpty) {
        widget.state.assignTechnician(job, assignedTechnician!);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            dispatchNow
                ? foundAddress == null
                      ? 'Job dispatched with an unverified address. Verify it before navigation.'
                      : 'Job created and sent to the Dispatch Board.'
                : foundAddress == null
                ? 'Draft saved with an unverified address.'
                : 'Draft saved with a verified address.',
          ),
        ),
      );

      widget.onCreated();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to create job: $error')));
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  Widget textField(
    TextEditingController controller,
    String label, {
    double width = 280,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hint,
    ValueChanged<String>? onChanged,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }

  Widget dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    double width = 280,
  }) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: items
            .map(
              (item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final technicianNames = widget.state.technicians
        .map((tech) => tech.name)
        .toList();

    return SectionCard(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Roadside Assistance Job',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create, price, verify, assign, and dispatch every roadside service from one screen.',
            ),
            const SizedBox(height: 22),

            sectionTitle('Customer Information', Icons.person),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                textField(customer, 'Customer Name', width: 300),
                textField(
                  phone,
                  'Phone Number',
                  width: 250,
                  keyboardType: TextInputType.phone,
                ),
                textField(
                  email,
                  'Email (Optional)',
                  width: 300,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),

            const SizedBox(height: 18),
            sectionTitle('Vehicle Information', Icons.directions_car),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                textField(
                  vehicleYear,
                  'Year',
                  width: 130,
                  keyboardType: TextInputType.number,
                ),
                textField(vehicleMake, 'Make', width: 200),
                textField(vehicleModel, 'Model', width: 220),
                textField(vehicleColor, 'Color', width: 180),
                textField(licensePlate, 'License Plate', width: 200),
              ],
            ),

            const SizedBox(height: 18),
            sectionTitle('Service and Dispatch', Icons.car_repair),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                dropdown(
                  label: 'Service Type',
                  value: serviceType,
                  items: serviceTypes,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => serviceType = value);
                    }
                  },
                  width: 290,
                ),
                dropdown(
                  label: 'Priority',
                  value: priority,
                  items: priorities,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => priority = value);
                    }
                  },
                  width: 200,
                ),
                SizedBox(
                  width: 300,
                  child: DropdownButtonFormField<String>(
                    initialValue: assignedTechnician,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Assigned Technician',
                    ),
                    hint: const Text('Unassigned'),
                    items: technicianNames
                        .map(
                          (name) => DropdownMenuItem<String>(
                            value: name,
                            child: Text(name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => assignedTechnician = value);
                    },
                  ),
                ),
                dropdown(
                  label: 'Lead Source',
                  value: leadSource,
                  items: leadSources,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => leadSource = value);
                    }
                  },
                  width: 260,
                ),
              ],
            ),

            const SizedBox(height: 18),
            sectionTitle('Customer Location', Icons.location_on),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                textField(
                  address,
                  'Customer Service Address',
                  width: 600,
                  hint: 'Street, city, state, ZIP',
                  onChanged: (_) {
                    if (foundAddress != null) {
                      setState(() => foundAddress = null);
                    }
                  },
                ),
                OutlinedButton.icon(
                  onPressed: locating ? null : locateAddress,
                  icon: locating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.pin_drop),
                  label: Text(locating ? 'Verifying...' : 'Verify Address'),
                ),
              ],
            ),

            if (foundAddress != null) ...[
              const SizedBox(height: 12),
              ListTile(
                tileColor: const Color(0xFF10243C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const Icon(
                  Icons.location_on,
                  color: Colors.greenAccent,
                ),
                title: const Text('GPS Location Confirmed'),
                subtitle: Text(
                  '${foundAddress!.latitude.toStringAsFixed(6)}, '
                  '${foundAddress!.longitude.toStringAsFixed(6)}',
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

            const SizedBox(height: 18),
            sectionTitle('Pricing', Icons.calculate),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                textField(
                  parts,
                  'Company Parts Cost',
                  width: 210,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
                textField(
                  markup,
                  'Markup %',
                  width: 160,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
                textField(
                  serviceCall,
                  'Service Call',
                  width: 180,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
                textField(
                  taxRate,
                  'Sales Tax %',
                  width: 160,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 260,
                  child: MetricCard(
                    label: 'Customer Parts Price',
                    value: money(customerPartsPrice),
                    icon: Icons.inventory_2,
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: MetricCard(
                    label: 'Sales Tax',
                    value: money(taxAmount),
                    icon: Icons.receipt_long,
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: MetricCard(
                    label: 'Customer Total',
                    value: money(customerTotal),
                    icon: Icons.payments,
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: MetricCard(
                    label: 'Projected Profit',
                    value: money(projectedProfit),
                    icon: Icons.savings,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            sectionTitle('Payment', Icons.account_balance_wallet),
            dropdown(
              label: 'Payment Method',
              value: paymentMethod,
              items: paymentMethods,
              onChanged: (value) {
                if (value != null) {
                  setState(() => paymentMethod = value);
                }
              },
              width: 320,
            ),

            const SizedBox(height: 18),
            sectionTitle('Notes', Icons.notes),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                textField(
                  customerNotes,
                  'Customer Notes',
                  width: 520,
                  maxLines: 3,
                ),
                textField(
                  technicianNotes,
                  'Internal Technician Notes',
                  width: 520,
                  maxLines: 3,
                ),
              ],
            ),

            const SizedBox(height: 22),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: saving
                      ? null
                      : () => createJob(dispatchNow: false),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Draft'),
                ),
                FilledButton.icon(
                  onPressed: saving ? null : () => createJob(dispatchNow: true),
                  icon: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    saving ? 'Creating Job...' : 'Create & Dispatch Job',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
