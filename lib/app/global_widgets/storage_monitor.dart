import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/save_provider.dart';

class StorageMonitor extends ConsumerStatefulWidget {
  const StorageMonitor({super.key});

  @override
  ConsumerState<StorageMonitor> createState() => _StorageMonitorState();
}

class _StorageMonitorState extends ConsumerState<StorageMonitor> {
  int _storageSize = 0;
  bool _isOptimizing = false;

  @override
  void initState() {
    super.initState();
    _loadStorageSize();
  }

  Future<void> _loadStorageSize() async {
    final size = await ref.read(saveNotifierProvider.notifier).getStorageSize();
    if (mounted) {
      setState(() {
        _storageSize = size;
      });
    }
  }

  Future<void> _optimizeStorage() async {
    setState(() {
      _isOptimizing = true;
    });

    try {
      await ref.read(saveNotifierProvider.notifier).forceOptimizeStorage();
      await _loadStorageSize();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage otimizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao otimizar storage: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOptimizing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storage, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Monitor de Storage',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadStorageSize,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Atualizar informações',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Tamanho atual: '),
                Text(
                  '$_storageSize entradas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _storageSize > 50 ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_storageSize > 50)
              const Text(
                '⚠️ Storage próximo do limite. Considere otimizar.',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isOptimizing ? null : _optimizeStorage,
                icon: _isOptimizing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cleaning_services),
                label: Text(_isOptimizing ? 'Otimizando...' : 'Otimizar Storage'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A otimização remove dados antigos e compacta o storage para melhorar o desempenho.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
