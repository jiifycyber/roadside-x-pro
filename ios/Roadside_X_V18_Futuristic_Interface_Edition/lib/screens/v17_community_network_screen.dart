import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class V17CommunityNetworkScreen extends StatefulWidget {
  const V17CommunityNetworkScreen({super.key, required this.state});
  final AppState state;

  @override
  State<V17CommunityNetworkScreen> createState() =>
      _V17CommunityNetworkScreenState();
}

class _V17CommunityNetworkScreenState extends State<V17CommunityNetworkScreen> {
  int tab = 0;
  final postController = TextEditingController();
  final List<Map<String, dynamic>> posts = [
    {
      'author': 'Jiffy Roadside Assistance',
      'role': 'Verified Provider',
      'body':
          'Another successful battery replacement completed safely in Birmingham.',
      'likes': 18,
      'comments': 4,
    },
    {
      'author': 'Roadside X Training',
      'role': 'Official',
      'body':
          'New lockout safety checklist is available in the Training Center.',
      'likes': 31,
      'comments': 7,
    },
  ];

  final groups = const [
    ('Independent Roadside Owners', '1,248 members'),
    ('Birmingham Provider Network', '326 members'),
    ('Battery & Electrical Specialists', '881 members'),
    ('Heavy-Duty Roadside', '514 members'),
  ];

  final marketplace = const [
    ('Commercial jump box', '\$275', 'Birmingham, AL'),
    ('Roadside service van', '\$18,500', 'Hoover, AL'),
    ('Lockout tool bundle', '\$160', 'Bessemer, AL'),
  ];

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
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
                  'Roadside X Community Network',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                const Text(
                  'A private professional network for roadside companies, technicians, partners, training, referrals, and marketplace activity.',
                  style: TextStyle(color: Color(0xFF9CB1C9)),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _tab('Feed', Icons.dynamic_feed, 0),
                    _tab('Groups', Icons.groups_outlined, 1),
                    _tab('Marketplace', Icons.storefront_outlined, 2),
                    _tab('Messages', Icons.forum_outlined, 3),
                    _tab('Referrals', Icons.swap_horiz, 4),
                    _tab('Moderation', Icons.shield_outlined, 5),
                  ],
                ),
                const SizedBox(height: 20),
                _content(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(String label, IconData icon, int index) => ChoiceChip(
    selected: tab == index,
    avatar: Icon(icon, size: 18),
    label: Text(label),
    onSelected: (_) => setState(() => tab = index),
  );

  Widget _content() {
    switch (tab) {
      case 0:
        return _feed();
      case 1:
        return _groups();
      case 2:
        return _marketplace();
      case 3:
        return _messages();
      case 4:
        return _referrals();
      default:
        return _moderation();
    }
  }

  Widget _feed() => Column(
    children: [
      SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create a professional post',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: postController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'Share an update, training tip, job opportunity, or company announcement...',
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.photo_outlined),
                  label: const Text('Photo'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.video_library_outlined),
                  label: const Text('Video'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.work_outline),
                  label: const Text('Job Opportunity'),
                ),
                FilledButton.icon(
                  onPressed: _publish,
                  icon: const Icon(Icons.send),
                  label: const Text('Publish'),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      ...posts.map(
        (post) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.business)),
                  title: Text(
                    post['author'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(post['role'] as String),
                  trailing: const Icon(Icons.more_horiz),
                ),
                Text(post['body'] as String),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(
                        () => post['likes'] = (post['likes'] as int) + 1,
                      ),
                      icon: const Icon(Icons.thumb_up_alt_outlined),
                      label: Text('${post['likes']}'),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.comment_outlined),
                      label: Text('${post['comments']}'),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  void _publish() {
    final text = postController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      posts.insert(0, {
        'author': 'Your Company',
        'role': 'Verified Provider',
        'body': text,
        'likes': 0,
        'comments': 0,
      });
      postController.clear();
    });
  }

  Widget _groups() => SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Professional Groups',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        ...groups.map(
          (g) => ListTile(
            leading: const CircleAvatar(child: Icon(Icons.groups)),
            title: Text(g.$1),
            subtitle: Text(g.$2),
            trailing: OutlinedButton(
              onPressed: () {},
              child: const Text('Join'),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _marketplace() => SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Provider Marketplace',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Create Listing'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...marketplace.map(
          (m) => ListTile(
            leading: const CircleAvatar(child: Icon(Icons.handyman_outlined)),
            title: Text(m.$1),
            subtitle: Text('${m.$2} • ${m.$3}'),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ],
    ),
  );

  Widget _messages() => SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Unified Messages',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        const ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text('Dispatcher Team'),
          subtitle: Text('2 unread messages • Active job coordination'),
          trailing: Chip(label: Text('Company')),
        ),
        const ListTile(
          leading: CircleAvatar(child: Icon(Icons.business)),
          title: Text('Reliable Roadside LLC'),
          subtitle: Text('Provider referral conversation'),
          trailing: Chip(label: Text('Partner')),
        ),
        const ListTile(
          leading: CircleAvatar(child: Icon(Icons.school)),
          title: Text('Roadside X Training'),
          subtitle: Text('New certification available'),
          trailing: Chip(label: Text('Training')),
        ),
      ],
    ),
  );

  Widget _referrals() => SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Provider Referral Exchange',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Transfer overflow calls to verified providers only when customer, contract, and motor-club rules allow it.',
        ),
        const SizedBox(height: 12),
        const ListTile(
          leading: CircleAvatar(child: Icon(Icons.car_repair)),
          title: Text('Tire replacement • Hoover, AL'),
          subtitle: Text(
            'Requested ETA: 35 minutes • Customer consent required',
          ),
          trailing: Chip(label: Text('Open')),
        ),
        const ListTile(
          leading: CircleAvatar(child: Icon(Icons.battery_charging_full)),
          title: Text('Battery replacement • Birmingham, AL'),
          subtitle: Text('Authorized amount: \$325 • Verified provider only'),
          trailing: Chip(label: Text('Review')),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Post Referral Request'),
        ),
      ],
    ),
  );

  Widget _moderation() => SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Trust, Safety & Moderation',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 10),
        ListTile(
          leading: Icon(Icons.verified_user),
          title: Text('Verified provider badges'),
          subtitle: Text(
            'Business verification, insurance review, and identity controls.',
          ),
        ),
        ListTile(
          leading: Icon(Icons.report_outlined),
          title: Text('Report, block, and appeal tools'),
          subtitle: Text(
            'Users can report content, listings, messages, and accounts.',
          ),
        ),
        ListTile(
          leading: Icon(Icons.privacy_tip_outlined),
          title: Text('Job-data privacy separation'),
          subtitle: Text(
            'Customer addresses, phone numbers, and dispatch details never appear in public posts by default.',
          ),
        ),
        ListTile(
          leading: Icon(Icons.admin_panel_settings_outlined),
          title: Text('Admin moderation queue'),
          subtitle: Text(
            'Review reports, remove content, suspend accounts, and preserve audit records.',
          ),
        ),
        ListTile(
          leading: Icon(Icons.psychology_outlined),
          title: Text('AI-assisted moderation blueprint'),
          subtitle: Text(
            'Content risk scoring supports human review; it does not replace moderators.',
          ),
        ),
      ],
    ),
  );
}
