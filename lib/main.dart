import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://weprnbojltsqjvocqknh.supabase.co',
    anonKey: 'sb_publishable_fGrXqrPpCPya2SfEDe30BA_dRIBa4Kp',
  );

  runApp(const RoadsideXApp());
}
