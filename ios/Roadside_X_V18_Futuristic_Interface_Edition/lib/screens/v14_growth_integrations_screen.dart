import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/app_state.dart';
import '../widgets/common.dart';

class V14GrowthIntegrationsScreen extends StatefulWidget {
  const V14GrowthIntegrationsScreen({super.key, required this.state});
  final AppState state;

  @override
  State<V14GrowthIntegrationsScreen> createState() =>
      _V14GrowthIntegrationsScreenState();
}

class _V14GrowthIntegrationsScreenState
    extends State<V14GrowthIntegrationsScreen> {
  final _callRailAccount = TextEditingController();
  final _callRailCompany = TextEditingController();
  final _callRailNumber = TextEditingController();
  final _googleCustomerId = TextEditingController();
  final _googleConversionAction = TextEditingController();
  final _wordpressUrl = TextEditingController();
  final _wordpressEndpoint = TextEditingController(
    text: '/wp-json/roadside-x/v1/lead',
  );

  bool callRailEnabled = false;
  bool googleAdsEnabled = false;
  bool wordpressEnabled = false;
  bool importTranscripts = true;
  bool importRecordings = false;
  bool uploadCompletedJobs = true;
  bool captureGclid = true;
  bool createDraftJobs = true;
  bool sendStatusToWordPress = false;

  final List<Map<String, dynamic>> _events = [];
  final List<Map<String, dynamic>> _leads = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _callRailAccount.dispose();
    _callRailCompany.dispose();
    _callRailNumber.dispose();
    _googleCustomerId.dispose();
    _googleConversionAction.dispose();
    _wordpressUrl.dispose();
    _wordpressEndpoint.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final config =
        jsonDecode(prefs.getString('v14_growth_config') ?? '{}')
            as Map<String, dynamic>;
    final savedEvents =
        jsonDecode(prefs.getString('v14_growth_events') ?? '[]')
            as List<dynamic>;
    final savedLeads =
        jsonDecode(prefs.getString('v14_growth_leads') ?? '[]')
            as List<dynamic>;
    setState(() {
      _callRailAccount.text = '${config['callRailAccount'] ?? ''}';
      _callRailCompany.text = '${config['callRailCompany'] ?? ''}';
      _callRailNumber.text = '${config['callRailNumber'] ?? ''}';
      _googleCustomerId.text = '${config['googleCustomerId'] ?? ''}';
      _googleConversionAction.text =
          '${config['googleConversionAction'] ?? ''}';
      _wordpressUrl.text = '${config['wordpressUrl'] ?? ''}';
      _wordpressEndpoint.text =
          '${config['wordpressEndpoint'] ?? '/wp-json/roadside-x/v1/lead'}';
      callRailEnabled = config['callRailEnabled'] == true;
      googleAdsEnabled = config['googleAdsEnabled'] == true;
      wordpressEnabled = config['wordpressEnabled'] == true;
      importTranscripts = config['importTranscripts'] != false;
      importRecordings = config['importRecordings'] == true;
      uploadCompletedJobs = config['uploadCompletedJobs'] != false;
      captureGclid = config['captureGclid'] != false;
      createDraftJobs = config['createDraftJobs'] != false;
      sendStatusToWordPress = config['sendStatusToWordPress'] == true;
      _events.addAll(savedEvents.cast<Map<String, dynamic>>());
      _leads.addAll(savedLeads.cast<Map<String, dynamic>>());
      _loading = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final config = {
      'callRailAccount': _callRailAccount.text.trim(),
      'callRailCompany': _callRailCompany.text.trim(),
      'callRailNumber': _callRailNumber.text.trim(),
      'googleCustomerId': _googleCustomerId.text.trim(),
      'googleConversionAction': _googleConversionAction.text.trim(),
      'wordpressUrl': _wordpressUrl.text.trim(),
      'wordpressEndpoint': _wordpressEndpoint.text.trim(),
      'callRailEnabled': callRailEnabled,
      'googleAdsEnabled': googleAdsEnabled,
      'wordpressEnabled': wordpressEnabled,
      'importTranscripts': importTranscripts,
      'importRecordings': importRecordings,
      'uploadCompletedJobs': uploadCompletedJobs,
      'captureGclid': captureGclid,
      'createDraftJobs': createDraftJobs,
      'sendStatusToWordPress': sendStatusToWordPress,
    };
    await prefs.setString('v14_growth_config', jsonEncode(config));
    await prefs.setString('v14_growth_events', jsonEncode(_events));
    await prefs.setString('v14_growth_leads', jsonEncode(_leads));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Integration settings saved locally.')),
      );
    }
  }

  Future<void> _simulateCallRail() async {
    final now = DateTime.now();
    final lead = {
      'id': 'CR-${now.millisecondsSinceEpoch}',
      'source': 'CallRail',
      'caller': '(205) 555-01${now.second.toString().padLeft(2, '0')}',
      'campaign': 'Google Ads • Emergency Roadside',
      'status': 'New call',
      'value': 0.0,
      'gclid': 'TEST-GCLID-${now.millisecondsSinceEpoch}',
      'createdAt': now.toIso8601String(),
    };
    setState(() {
      _leads.insert(0, lead);
      _events.insert(0, {
        'time': now.toIso8601String(),
        'system': 'CallRail',
        'message':
            'Test inbound call received and matched to Google Ads campaign.',
        'status': 'Success',
      });
    });
    await _save();
  }

  Future<void> _simulateWordPress() async {
    final now = DateTime.now();
    final lead = {
      'id': 'WP-${now.millisecondsSinceEpoch}',
      'source': 'WordPress',
      'caller': '(313) 555-0199',
      'campaign': 'Website Request Form',
      'status': createDraftJobs ? 'Draft job created' : 'Lead received',
      'value': 0.0,
      'gclid': captureGclid
          ? 'TEST-WP-GCLID-${now.millisecondsSinceEpoch}'
          : '',
      'createdAt': now.toIso8601String(),
    };
    setState(() {
      _leads.insert(0, lead);
      _events.insert(0, {
        'time': now.toIso8601String(),
        'system': 'WordPress',
        'message':
            'Test roadside request received through the WordPress REST endpoint.',
        'status': 'Success',
      });
    });
    await _save();
  }

  Future<void> _markConverted(Map<String, dynamic> lead) async {
    setState(() {
      lead['status'] = 'Completed job';
      lead['value'] = 225.0;
      _events.insert(0, {
        'time': DateTime.now().toIso8601String(),
        'system': 'Google Ads',
        'message': 'Offline conversion queued for ${lead['id']} at \$225.00.',
        'status': googleAdsEnabled ? 'Queued for backend' : 'Demo only',
      });
    });
    await _save();
  }

  Widget _statusChip(bool enabled) => Chip(
    avatar: Icon(enabled ? Icons.check_circle : Icons.pause_circle, size: 18),
    label: Text(enabled ? 'Enabled' : 'Not connected'),
  );

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'V14 Growth Integration Center',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              const Text(
                'Connect calls, advertising attribution, website requests, and completed-job revenue in one workflow.',
                style: TextStyle(color: Color(0xFF9CB1C9)),
              ),
              const SizedBox(height: 22),
              LayoutBuilder(
                builder: (context, c) {
                  final columns = c.maxWidth > 1050
                      ? 3
                      : c.maxWidth > 650
                      ? 2
                      : 1;
                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: columns == 1 ? 1.5 : 1.15,
                    children: [
                      _callRailCard(),
                      _googleAdsCard(),
                      _wordpressCard(),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unified Lead & Revenue Pipeline',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'CallRail and WordPress leads can be matched to completed Roadside X jobs. The backend can then upload eligible offline conversion values to Google Ads.',
                    ),
                    const SizedBox(height: 12),
                    if (_leads.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No test leads yet. Use a Test Event button above.',
                          ),
                        ),
                      ),
                    ..._leads
                        .take(20)
                        .map(
                          (lead) => ListTile(
                            leading: CircleAvatar(
                              child: Icon(
                                lead['source'] == 'CallRail'
                                    ? Icons.call
                                    : Icons.language,
                              ),
                            ),
                            title: Text('${lead['id']} • ${lead['caller']}'),
                            subtitle: Text(
                              '${lead['source']} • ${lead['campaign']} • ${lead['status']}',
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if ((lead['value'] as num).toDouble() > 0)
                                  Chip(
                                    label: Text(
                                      money((lead['value'] as num).toDouble()),
                                    ),
                                  ),
                                OutlinedButton(
                                  onPressed: () => _markConverted(lead),
                                  child: const Text('Complete Job'),
                                ),
                              ],
                            ),
                          ),
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
                      'Integration Activity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_events.isEmpty)
                      const Text('No integration activity recorded.'),
                    ..._events
                        .take(20)
                        .map(
                          (e) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.sync_alt),
                            title: Text('${e['system']} • ${e['status']}'),
                            subtitle: Text('${e['message']}\n${e['time']}'),
                            isThreeLine: true,
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _callRailCard() => SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.call, size: 30),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'CallRail',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
            ),
            _statusChip(callRailEnabled),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _callRailAccount,
          decoration: const InputDecoration(labelText: 'Account ID'),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: _callRailCompany,
          decoration: const InputDecoration(labelText: 'Company ID'),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: _callRailNumber,
          decoration: const InputDecoration(labelText: 'Tracking Number'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable CallRail connector'),
          value: callRailEnabled,
          onChanged: (v) => setState(() => callRailEnabled = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Import transcripts'),
          value: importTranscripts,
          onChanged: (v) => setState(() => importTranscripts = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Import recording links'),
          value: importRecordings,
          onChanged: (v) => setState(() => importRecordings = v),
        ),
        Wrap(
          spacing: 8,
          children: [
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
            OutlinedButton.icon(
              onPressed: _simulateCallRail,
              icon: const Icon(Icons.science),
              label: const Text('Test Call'),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _googleAdsCard() => SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.ads_click, size: 30),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Google Ads',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
            ),
            _statusChip(googleAdsEnabled),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _googleCustomerId,
          decoration: const InputDecoration(
            labelText: 'Google Ads Customer ID',
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: _googleConversionAction,
          decoration: const InputDecoration(
            labelText: 'Offline Conversion Action ID',
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable Google Ads connector'),
          value: googleAdsEnabled,
          onChanged: (v) => setState(() => googleAdsEnabled = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Capture GCLID / GBRAID / WBRAID'),
          value: captureGclid,
          onChanged: (v) => setState(() => captureGclid = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Upload completed-job value'),
          value: uploadCompletedJobs,
          onChanged: (v) => setState(() => uploadCompletedJobs = v),
        ),
        const Text(
          'OAuth client secrets, developer tokens, and refresh tokens belong on the Roadside X backend—not inside Flutter.',
          style: TextStyle(color: Color(0xFF9CB1C9), fontSize: 12),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save),
          label: const Text('Save'),
        ),
      ],
    ),
  );

  Widget _wordpressCard() => SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.language, size: 30),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'WordPress',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
            ),
            _statusChip(wordpressEnabled),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _wordpressUrl,
          decoration: const InputDecoration(
            labelText: 'Website URL',
            hintText: 'https://example.com',
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: _wordpressEndpoint,
          decoration: const InputDecoration(
            labelText: 'Roadside X REST Endpoint',
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable WordPress connector'),
          value: wordpressEnabled,
          onChanged: (v) => setState(() => wordpressEnabled = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Create draft jobs from forms'),
          value: createDraftJobs,
          onChanged: (v) => setState(() => createDraftJobs = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Send job status back to website'),
          value: sendStatusToWordPress,
          onChanged: (v) => setState(() => sendStatusToWordPress = v),
        ),
        Wrap(
          spacing: 8,
          children: [
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
            OutlinedButton.icon(
              onPressed: _simulateWordPress,
              icon: const Icon(Icons.science),
              label: const Text('Test Form'),
            ),
          ],
        ),
      ],
    ),
  );
}
