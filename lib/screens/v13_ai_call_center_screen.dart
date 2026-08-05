import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/common.dart';

class V13AiCallCenterScreen extends StatefulWidget {
  const V13AiCallCenterScreen({super.key, required this.state});

  final AppState state;

  @override
  State<V13AiCallCenterScreen> createState() => _V13AiCallCenterScreenState();
}

class _V13AiCallCenterScreenState extends State<V13AiCallCenterScreen> {
  final callerController = TextEditingController(text: 'Sarah Johnson');
  final phoneController = TextEditingController(text: '205-555-0188');
  final transcriptController = TextEditingController(
    text:
        'Hi, my name is Sarah Johnson. I am at 1600 5th Avenue North in Birmingham. My 2019 Nissan Altima will not start and I think the battery is dead. The car is in a safe parking lot.',
  );

  String callMode = 'Dispatcher approval';
  String voiceProvider = 'Not connected';
  String callStatus = 'Ready';
  bool emergencyEscalation = true;
  bool priceApproval = true;
  bool addressVerification = true;
  bool autoTextCaller = false;
  bool recordConsent = true;
  Map<String, String> extracted = const {};
  final List<String> timeline = [
    'AI Dispatcher initialized.',
    'No live phone provider is connected.',
  ];

  @override
  void dispose() {
    callerController.dispose();
    phoneController.dispose();
    transcriptController.dispose();
    super.dispose();
  }

  void extractCall() {
    final text = transcriptController.text.toLowerCase();
    String service = 'Other Roadside Service';
    if (text.contains('battery') || text.contains('will not start')) {
      service = 'Battery / Jump Start';
    } else if (text.contains('tire') || text.contains('flat')) {
      service = 'Tire Service';
    } else if (text.contains('locked') || text.contains('lockout')) {
      service = 'Vehicle Lockout';
    } else if (text.contains('fuel') || text.contains('gas')) {
      service = 'Fuel Delivery';
    }

    String safety = 'Unknown';
    if (text.contains('safe parking') || text.contains('safe location')) {
      safety = 'Safe location reported';
    } else if (text.contains('highway') || text.contains('interstate')) {
      safety = 'Roadside hazard review required';
    }

    setState(() {
      extracted = {
        'Caller': callerController.text.trim().isEmpty
            ? 'Unknown caller'
            : callerController.text.trim(),
        'Phone': phoneController.text.trim().isEmpty
            ? 'Not provided'
            : phoneController.text.trim(),
        'Service': service,
        'Address': _extractAddress(transcriptController.text),
        'Vehicle': _extractVehicle(transcriptController.text),
        'Safety': safety,
        'Confidence': '88%',
      };
      callStatus = 'Draft ready for review';
      timeline.insert(
        0,
        'AI extracted a structured job draft from the call transcript.',
      );
    });
  }

  String _extractAddress(String text) {
    final lower = text.toLowerCase();
    final marker = lower.indexOf(' at ');
    if (marker == -1) return 'Needs dispatcher confirmation';
    final start = marker + 4;
    final endings = ['. my ', '. the ', '. i ', ', my '];
    var end = text.length;
    for (final ending in endings) {
      final found = lower.indexOf(ending, start);
      if (found != -1 && found < end) end = found;
    }
    final value = text.substring(start, end).trim();
    return value.isEmpty ? 'Needs dispatcher confirmation' : value;
  }

  String _extractVehicle(String text) {
    final match = RegExp(
      r'\b(19|20)\d{2}\s+[A-Za-z]+(?:\s+[A-Za-z]+){0,2}',
    ).firstMatch(text);
    return match?.group(0) ?? 'Needs dispatcher confirmation';
  }

  void simulateIncomingCall() {
    setState(() {
      callStatus = 'AI agent speaking with caller';
      timeline.insert(
        0,
        'Simulated incoming call answered by Roadside X AI Agent.',
      );
    });
  }

  void escalate() {
    setState(() {
      callStatus = 'Escalated to human dispatcher';
      timeline.insert(
        0,
        'Call escalated to a human dispatcher with transcript and collected details.',
      );
    });
  }

  void approveDraft() {
    if (extracted.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Extract the call information first.')),
      );
      return;
    }
    setState(() {
      callStatus = 'Approved for New Job review';
      timeline.insert(0, 'Dispatcher approved the AI-created job draft.');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Draft approved. Open New Job to verify the address, price, and technician assignment.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Dispatcher',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Answer, transcribe, structure, review, and escalate roadside calls with human approval controls.',
                  style: TextStyle(color: Color(0xFF9CB1C9)),
                ),
                const SizedBox(height: 22),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth > 1000 ? 4 : 2;
                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 2.1,
                      children: [
                        MetricCard(
                          label: 'Call Status',
                          value: callStatus,
                          icon: Icons.support_agent,
                        ),
                        MetricCard(
                          label: 'Voice Provider',
                          value: voiceProvider,
                          icon: Icons.phone_in_talk,
                        ),
                        MetricCard(
                          label: 'Draft Confidence',
                          value: extracted['Confidence'] ?? '--',
                          icon: Icons.fact_check_outlined,
                        ),
                        MetricCard(
                          label: 'Human Review',
                          value: callMode,
                          icon: Icons.verified_user_outlined,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 950;
                    final intake = _intakeCard();
                    final review = _reviewCard();
                    return wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: intake),
                              const SizedBox(width: 16),
                              Expanded(child: review),
                            ],
                          )
                        : Column(
                            children: [
                              intake,
                              const SizedBox(height: 16),
                              review,
                            ],
                          );
                  },
                ),
                const SizedBox(height: 16),
                _automationCard(),
                const SizedBox(height: 16),
                _providerCard(),
                const SizedBox(height: 16),
                _timelineCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _intakeCard() => SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Call Intake',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: callerController,
          decoration: const InputDecoration(labelText: 'Caller name'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: phoneController,
          decoration: const InputDecoration(labelText: 'Caller phone'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: transcriptController,
          minLines: 7,
          maxLines: 12,
          decoration: const InputDecoration(
            labelText: 'Call transcript or dispatcher notes',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: simulateIncomingCall,
              icon: const Icon(Icons.call),
              label: const Text('Simulate Incoming Call'),
            ),
            FilledButton.icon(
              onPressed: extractCall,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Extract Job Details'),
            ),
            OutlinedButton.icon(
              onPressed: escalate,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Escalate to Human'),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _reviewCard() => SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dispatcher Review',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        if (extracted.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'No AI draft yet. Add a transcript and select Extract Job Details.',
              ),
            ),
          )
        else
          ...extracted.entries.map(
            (entry) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF65D99B),
              ),
              title: Text(entry.key),
              subtitle: Text(entry.value),
            ),
          ),
        const Divider(),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: approveDraft,
              icon: const Icon(Icons.approval),
              label: const Text('Approve Draft'),
            ),
            OutlinedButton.icon(
              onPressed: extractCall,
              icon: const Icon(Icons.refresh),
              label: const Text('Reprocess'),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _automationCard() => SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Call Automation & Safety Rules',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: callMode,
          decoration: const InputDecoration(labelText: 'AI operating mode'),
          items: const [
            DropdownMenuItem(value: 'Draft only', child: Text('Draft only')),
            DropdownMenuItem(
              value: 'Dispatcher approval',
              child: Text('Dispatcher approval required'),
            ),
            DropdownMenuItem(
              value: 'Auto-create approved services',
              child: Text('Auto-create approved low-risk services'),
            ),
          ],
          onChanged: (value) => setState(() => callMode = value ?? callMode),
        ),
        SwitchListTile(
          value: emergencyEscalation,
          onChanged: (value) => setState(() => emergencyEscalation = value),
          title: const Text(
            'Escalate emergencies and unsafe roadside situations',
          ),
          subtitle: const Text(
            'Accidents, injuries, threats, fire, highway hazards, and unclear safety conditions go to a human.',
          ),
        ),
        SwitchListTile(
          value: priceApproval,
          onChanged: (value) => setState(() => priceApproval = value),
          title: const Text('Require human approval for final price'),
        ),
        SwitchListTile(
          value: addressVerification,
          onChanged: (value) => setState(() => addressVerification = value),
          title: const Text('Require GPS address verification before dispatch'),
        ),
        SwitchListTile(
          value: autoTextCaller,
          onChanged: (value) => setState(() => autoTextCaller = value),
          title: const Text('Prepare automatic caller confirmation text'),
          subtitle: const Text(
            'Sending requires an SMS provider and backend credentials.',
          ),
        ),
        SwitchListTile(
          value: recordConsent,
          onChanged: (value) => setState(() => recordConsent = value),
          title: const Text(
            'Require call-recording and transcription consent notice',
          ),
        ),
      ],
    ),
  );

  Widget _providerCard() => SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Voice & Phone Provider Connection',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'The Flutter app provides the call-center workflow. A real AI phone agent requires a telephone/voice provider and a secure backend webhook.',
          style: TextStyle(color: Color(0xFF9CB1C9)),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: voiceProvider,
          decoration: const InputDecoration(labelText: 'Provider profile'),
          items: const [
            DropdownMenuItem(
              value: 'Not connected',
              child: Text('Not connected'),
            ),
            DropdownMenuItem(
              value: 'Twilio-compatible',
              child: Text('Twilio-compatible voice connector'),
            ),
            DropdownMenuItem(
              value: 'SIP / PBX',
              child: Text('SIP / PBX connector'),
            ),
            DropdownMenuItem(
              value: 'Custom webhook',
              child: Text('Custom voice webhook connector'),
            ),
          ],
          onChanged: (value) =>
              setState(() => voiceProvider = value ?? voiceProvider),
        ),
        const SizedBox(height: 12),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.webhook),
          title: Text('Incoming-call webhook'),
          subtitle: Text('/api/v1/voice/incoming'),
        ),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.record_voice_over),
          title: Text('Transcript callback'),
          subtitle: Text('/api/v1/voice/transcript'),
        ),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.escalator_warning),
          title: Text('Human transfer route'),
          subtitle: Text('/api/v1/voice/escalate'),
        ),
      ],
    ),
  );

  Widget _timelineCard() => SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Call Audit Timeline',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        ...timeline
            .take(10)
            .map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history, color: Color(0xFF4BB3FD)),
                title: Text(item),
              ),
            ),
      ],
    ),
  );
}
