import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/entities.dart';
import '../widgets/futuristic.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin});
  final void Function(UserRole role, String displayName) onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  UserRole role = UserRole.owner;
  bool obscure = true;

  Future<void> submit() async {
  if (email.text.trim().isEmpty || password.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enter an email and password.')),
    );
    return;
  }

  try {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email.text.trim(),
      password: password.text,
    );

    if (response.user != null) {
      widget.onLogin(role, response.user!.email ?? 'User');
    }
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FuturisticBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: .86, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutBack,
                builder: (context, value, child) => Transform.scale(
                  scale: value,
                  child: Opacity(opacity: value.clamp(0, 1), child: child),
                ),
                child: GlassPanel(
                  padding: const EdgeInsets.all(32),
                  radius: 30,
                  glowColor: const Color(0xFF00D9FF),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF00D9FF),
                                Color(0xFF7C4DFF),
                                Color(0xFFFF6FD8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF00D9FF,
                                ).withValues(alpha: .55),
                                blurRadius: 34,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.car_repair,
                            size: 42,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'ROADSIDE X PRO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const Text(
                        'ROADSIDE OPERATIONS PLATFORM',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF70EFFF),
                          fontSize: 11,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: email,
                        decoration: const InputDecoration(
                          labelText: 'Identity / Username',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: password,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          labelText: 'Security Key',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => obscure = !obscure),
                            icon: Icon(
                              obscure ? Icons.visibility : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<UserRole>(
                        value: role,
                        decoration: const InputDecoration(
                          labelText: 'Access Level',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: UserRole.owner,
                            child: Text('Owner / Administrator'),
                          ),
                          DropdownMenuItem(
                            value: UserRole.dispatcher,
                            child: Text('Dispatcher'),
                          ),
                          DropdownMenuItem(
                            value: UserRole.technician,
                            child: Text('Technician / Driver'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => role = value);
                        },
                      ),
                      const SizedBox(height: 24),
                      NeonButton(
                        label: 'ENTER COMMAND CENTER',
                        icon: Icons.login,
                        onPressed: submit,
                      ),
                      const SizedBox(height: 17),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PulsingStatusDot(),
                          SizedBox(width: 9),
                          Text(
                            'SECURE LOCAL NODE ONLINE',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF70FFC0),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      const Text(
                        'Local demonstration access. Connect a secure cloud identity provider before production use.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8798B7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
