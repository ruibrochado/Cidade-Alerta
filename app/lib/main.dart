import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> testConnection() async {
    try {
      final supabase = Supabase.instance.client;

      await supabase.from('issues').select().limit(1);

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<bool>(
        future: testConnection(),
        builder: (context, snapshot) {
          // enquanto está a testar
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // erro
          if (snapshot.hasError || snapshot.data == false) {
            return const Scaffold(
              body: Center(child: Text('Connection failed')),
            );
          }

          // sucesso
          return const Scaffold(
            body: Center(child: Text('Database connected')),
          );
        },
      ),
    );
  }
}