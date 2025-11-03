import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app/providers/achievement_provider.dart';
import 'app/providers/save_provider.dart';
import 'app/providers/auth_provider.dart';
import 'app/services/save_service.dart';
import 'app/services/sync_service.dart';
import 'app/modules/home/home_page.dart';
import 'app/theme/app_theme.dart';
import 'app/modules/account/components/welcome_popup.dart';
import 'app/global_widgets/sync_conflict_dialog.dart';
import 'app/providers/sync_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _setupGlobalErrorHandling();

  await SaveService().init();

  final container = ProviderContainer();

  runZonedGuarded(
    () {
      runApp(ProviderScope(
        parent: container,
        child: const FubaClickerApp(),
      ));
    },
    (error, stackTrace) {
      _handleGlobalError(error, stackTrace);
    },
  );
}

void _setupGlobalErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    _handleFlutterError(details);
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    _handleGlobalError(error, stackTrace);
    return true;
  };
}

void _handleFlutterError(FlutterErrorDetails details) {
  final exceptionString = details.exception.toString();
  final stackString = details.stack?.toString() ?? 'No stack trace';

  if (_isInfinityToIntError(exceptionString)) {
    _logInfinityError(
      exception: exceptionString,
      stackTrace: stackString,
      context: details.context?.toString(),
      library: details.library,
      informationCollector: details.informationCollector,
    );
  } else {
    developer.log(
      'Flutter Error: ${details.exception}',
      name: 'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  }
}

void _handleGlobalError(Object error, StackTrace stackTrace) {
  final errorString = error.toString();
  final stackString = stackTrace.toString();

  if (_isInfinityToIntError(errorString)) {
    _logInfinityError(
      exception: errorString,
      stackTrace: stackString,
      context: 'Global Error Handler',
    );
  } else {
    developer.log(
      'Uncaught Error: $error',
      name: 'GlobalError',
      error: error,
      stackTrace: stackTrace,
    );
    print('Uncaught Error: $error\n$stackTrace');
  }
}

bool _isInfinityToIntError(String errorMessage) {
  final lowerMessage = errorMessage.toLowerCase();
  return lowerMessage.contains('infinity.toint()') ||
      (lowerMessage.contains('unsupported operation') && lowerMessage.contains('infinity')) ||
      (lowerMessage.contains('infinity') && lowerMessage.contains('toint'));
}

void _logInfinityError({
  required String exception,
  required String stackTrace,
  String? context,
  String? library,
  Iterable<DiagnosticsNode> Function()? informationCollector,
}) {
  final timestamp = DateTime.now().toIso8601String();
  
  print('=' * 80);
  print('[INFINITY_TO_INT_ERROR] $timestamp');
  print('=' * 80);
  print('Erro: $exception');
  print('');
  print('Stack Trace:');
  print(stackTrace);
  print('');
  
  if (context != null) {
    print('Context: $context');
    print('');
  }
  
  if (library != null) {
    print('Library: $library');
    print('');
  }
  
  if (informationCollector != null) {
    print('Additional Information:');
    for (final info in informationCollector()) {
      print('  ${info.toStringDeep()}');
    }
    print('');
  }
  
  print('=' * 80);
  print('');

  developer.log(
    '❌ [INFINITY_TO_INT_ERROR] $exception',
    name: 'InfinityToIntError',
    error: exception,
    stackTrace: StackTrace.fromString(stackTrace),
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
        if (mounted && context.mounted) {
          showDialog(
            context: context,
            builder: (context) => const WelcomePopup(),
          );
        }
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

      if (!mounted) return;

      await _requestAudioPermission();

      if (!mounted) return;

      final saveNotifier = ref.read(saveNotifierProvider.notifier);
      await saveNotifier.loadGame();

      if (!mounted) return;

      final authState = ref.read(authStateProvider);
      if (!authState.isAuthenticated) {
        if (mounted) {
          setState(() {
            _showWelcomePopup = true;
          });
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error, stackTrace) {
      print('Erro ao carregar dados: $error\n$stackTrace');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        final context = kGlobalNavigationKey.currentContext;
        if (context != null && context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              backgroundColor: Colors.black.withAlpha(240),
              title: const Text(
                '❌ Erro ao Carregar o Jogo',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
                    if (mounted) {
                      setState(() {
                        _isLoading = true;
                      });
                      _loadGameData();
                    }
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Tentar Novamente'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Continuar Mesmo Assim'),
                ),
              ],
            ),
          );
        }
      });
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
      print('Erro ao solicitar permissão de áudio: $error\n$stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        ref.read(appContextProvider.notifier).state = context;
      } catch (error, stackTrace) {
        print('Erro ao definir contexto: $error\n$stackTrace');
      }
    });

    final authState = ref.watch(authStateProvider);
    final syncConflict = ref.watch(syncNotifierProvider);

    if (authState.isAuthenticated && _showWelcomePopup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _showWelcomePopup = false;
          });
        }
      });
    }

    if (syncConflict == SyncConflictType.needsConfirmation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final dialogContext = kGlobalNavigationKey.currentContext;
        if (dialogContext != null && dialogContext.mounted) {
          showDialog(
            context: dialogContext,
            barrierDismissible: false,
            builder: (context) => const SyncConflictDialog(),
          );
        }
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
      theme: AppTheme.getDark(),
      darkTheme: AppTheme.getDark(),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E0E3E), Color(0xFF3B0764), Color(0xFF581C87)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🌽', style: TextStyle(fontSize: 80)),
              SizedBox(height: 32),
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: Color(0xFF9333EA),
                  strokeWidth: 4,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Carregando...',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFFA78BFA),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final kGlobalNavigationKey = GlobalKey<NavigatorState>();
