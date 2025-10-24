import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'providers/achievement_provider.dart';
import 'providers/save_provider.dart';
import 'services/save_service.dart';
import 'widgets/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SaveService().init();
  runApp(const ProviderScope(child: FubaClickerApp()));
}

class FubaClickerApp extends ConsumerStatefulWidget {
  const FubaClickerApp({super.key});

  @override
  ConsumerState<FubaClickerApp> createState() => _FubaClickerAppState();
}

class _FubaClickerAppState extends ConsumerState<FubaClickerApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    await Future.delayed(const Duration(milliseconds: 100));

    await _requestAudioPermission();

    final saveNotifier = ref.read(saveNotifierProvider.notifier);
    await saveNotifier.loadGame();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _requestAudioPermission() async {
    if (kIsWeb) return;

    final status = await Permission.audio.status;
    if (status.isDenied) {
      await Permission.audio.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appContextProvider.notifier).state = context;
    });

    return MaterialApp(
      title: 'Fuba Clicker',
      home: _isLoading ? _buildLoadingScreen() : const HomePage(),
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepOrange,
        useMaterial3: false,
      ),
       
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🌽', style: TextStyle(fontSize: 80)),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Carregando...',
              style: TextStyle(fontSize: 20, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
