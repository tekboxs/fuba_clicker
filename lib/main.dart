import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/home_page.dart';

/// Ponto de entrada da aplicação
void main() {
  runApp(const ProviderScope(child: FubaClickerApp()));
}

/// Widget principal da aplicação
class FubaClickerApp extends ConsumerWidget {
  const FubaClickerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Fuba Clicker',
      home: const HomePage(),
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepOrange,
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
