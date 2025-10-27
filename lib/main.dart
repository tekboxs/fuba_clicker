import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app/providers/achievement_provider.dart';
import 'app/providers/save_provider.dart';
import 'app/providers/auth_provider.dart';
import 'app/services/save_service.dart';
import 'app/services/sync_service.dart';
import 'app/modules/home/home_page.dart';
import 'app/modules/account/components/welcome_popup.dart';
import 'app/global_widgets/sync_conflict_dialog.dart';
import 'app/providers/sync_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    Sentry.captureException(details.exception, stackTrace: details.stack);
  };

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://5969c28b8a0ac66f6465f1dd6485290c@o1402848.ingest.us.sentry.io/4510245636734976';
      options.tracesSampleRate = kIsWeb ? 0.0 : 1.0;
      options.debug = kDebugMode;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      await SaveService().init();

      final container = ProviderContainer();

      runApp(ProviderScope(
        parent: container,
        child: const FubaClickerApp(),
      ));
    },
  );
}

///Save simple data like primitives types
class TokenService {
  final String boxName;
  Box? box;

  TokenService({this.boxName = 'tokenDb'});

  ///open box to make possible read and update
  _init() async {
    if (box == null || !box!.isOpen) {
      box = await Hive.openBox(boxName);
    }
  }

  ///return if a key already in memory
  ///can be used to handle update or add
  Future<bool> existKey(dynamic key) async {
    await _init();
    return box!.containsKey(key.toString());
  }

  ///remove all current data
  Future<void> clear() async {
    await _init();
    await box!.clear();
  }

  ///remove only a key
  ///have no effect if this doesnt exists
  Future deleteMethod(key) async {
    await _init();
    return await box!.delete(key.toString());
  }

  ///return stored value this service only handle
  ///[PRIMITIVES] types, if not exists return null
  Future<dynamic> readMethod(dynamic key) async {
    await _init();
    if (key is int) {
      return await box!.getAt(key);
    } else {
      return await box!.get(key.toString());
    }
  }

  ///override a current key
  ///if not already exists may cause exception
  Future<void> writeMethod(dynamic key, dynamic value) async {
    await _init();
    if (key is int) {
      await box!.putAt(key, value);
    }
    await box!.put(key.toString(), value);
  }

  Future<int> get memoryLength async {
    await _init();
    return box!.length;
  }

  Future<List<dynamic>> get getAllItens async {
    await _init();
    return [for (var key in box!.keys) await readMethod(key)];
  }
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
    _initSyncService();
    showWelcomePopup();
  }

  showWelcomePopup() {
    if (_showWelcomePopup) {
      Future.delayed(const Duration(milliseconds: 500), () {
        showDialog(
          context: context,
          builder: (context) => const WelcomePopup(),
        );
      });
    }
  }

  Future<void> _initSyncService() async {
    try {
      await ref.read(syncServiceProvider.notifier).init();
    } catch (e) {
      print('Erro ao inicializar SyncService: $e');
    }
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

      print('Erro ao carregar dados: $error\n$stackTrace');

      setState(() {
        _isLoading = false;
      });

      if (kDebugMode || !kIsWeb) {
        Future.delayed(const Duration(milliseconds: 500), () {
          showDialog(
            context: kGlobalNavigationKey.currentContext!,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.black.withAlpha(240),
              title: const Text(
                '❌ Erro ao Carregar o Jogo',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Houve um erro ao carregar os dados do jogo.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      error.toString(),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Stack Trace:',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        stackTrace.toString(),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });
                    _loadGameData();
                  },
                  child: const Text('Tentar Novamente'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Continuar Mesmo Assim'),
                ),
              ],
            ),
          );
        });
      }
    }
  }

  Future<void> _requestAudioPermission() async {
    if (kIsWeb) return;

    try {
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
    final syncConflict = ref.watch(syncNotifierProvider);

    if (authState.isAuthenticated && _showWelcomePopup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _showWelcomePopup = false;
        });
      });
    }

    if (syncConflict == SyncConflictType.needsConfirmation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: kGlobalNavigationKey.currentContext!,
          barrierDismissible: false,
          builder: (context) => const SyncConflictDialog(),
        );
      });
    }

    ErrorWidget.builder = (FlutterErrorDetails details) {
      final navigatorKey = kGlobalNavigationKey;
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '❌',
                    style: TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ops! Algo deu errado',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    details.exception.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Stack Trace:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      details.stack.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (navigatorKey.currentState != null) {
                        navigatorKey.currentState!.pushNamedAndRemoveUntil(
                          '/',
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar Novamente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    };

    return MaterialApp(
      navigatorKey: kGlobalNavigationKey,
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

final kGlobalNavigationKey = GlobalKey<NavigatorState>();
