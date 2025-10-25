import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'providers/achievement_provider.dart';
import 'providers/save_provider.dart';
import 'providers/auth_provider.dart';
import 'services/save_service.dart';
import 'services/sync_service.dart';
import 'widgets/home_page.dart';
import 'widgets/welcome_popup.dart';

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://5969c28b8a0ac66f6465f1dd6485290c@o1402848.ingest.us.sentry.io/4510245636734976';
      options.tracesSampleRate = 1.0;
      // options.debug = kDebugMode;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      await SaveService().init();
      await SyncService().init();
      runApp(const ProviderScope(child: FubaClickerApp()));
    },
  );
}

class FubaClickerApp extends ConsumerStatefulWidget {
  const FubaClickerApp({super.key});

  @override
  ConsumerState<FubaClickerApp> createState() => _FubaClickerAppState();
}

class _FubaClickerAppState extends ConsumerState<FubaClickerApp> {
  bool _isLoading = true;
  bool _showWelcomePopup = false;

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      await _requestAudioPermission();

      final saveNotifier = ref.read(saveNotifierProvider.notifier);
      await saveNotifier.loadGame();

      final authState = ref.read(authStateProvider);
      if (!authState.isAuthenticated) {
        setState(() {
          _showWelcomePopup = true;
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestAudioPermission() async {
    try {
      if (kIsWeb) return;

      final status = await Permission.audio.status;
      if (status.isDenied) {
        await Permission.audio.request();
      }
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ref.read(appContextProvider.notifier).state = context;
      } catch (error, stackTrace) {
        Sentry.captureException(error, stackTrace: stackTrace);
      }
    });

    final authState = ref.watch(authStateProvider);
    
    if (authState.isAuthenticated && _showWelcomePopup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _showWelcomePopup = false;
        });
      });
    }

    return MaterialApp(
      title: 'Fuba Clicker',
      home: _isLoading ? _buildLoadingScreen() : _buildHomeWithWelcome(),
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

  Widget _buildHomeWithWelcome() {
    return Stack(
      children: [
        const HomePage(),
        if (_showWelcomePopup)
          Container(
            color: Colors.black54,
            child: const Center(
              child: WelcomePopup(),
            ),
          ),
      ],
    );
  }
}
