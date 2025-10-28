import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';
import '../providers/sync_notifier.dart';

class SyncConflictDialog extends ConsumerWidget {
  const SyncConflictDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncService = ref.read(syncServiceProvider.notifier);
    final cloudSaveData = syncService.getCloudSaveData();

    if (cloudSaveData == null || cloudSaveData.isEmpty) {
      return const SizedBox.shrink();
    }

    final cloudSave = cloudSaveData.userData;
    final cloudRebirths = (cloudSave.rebirthData?['rebirthCount'] as int? ?? 0) +
        (cloudSave.rebirthData?['ascensionCount'] as int? ?? 0) +
        (cloudSave.rebirthData?['transcendenceCount'] as int? ?? 0);

    return AlertDialog(
      title: const Text('Conflito de Sincronização'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seu save local tem menos rebirths que o da nuvem. '
              'Isso pode indicar perda de dados. Escolha qual save usar:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.cloud, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Save Nuvem',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Rebirths: $cloudRebirths'),
                  Text('Fuba: ${cloudSave.fuba}'),
                  Text(
                    'Último sync: ${cloudSaveData.lastSync.toString().substring(0, 19)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            await syncService.forceSync();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Forçar Upload'),
        ),
        ElevatedButton(
          onPressed: () async {
            await syncService.downloadCloudToLocal();
            ref.read(syncNotifierProvider.notifier).notifyDataLoaded();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Usar Nuvem'),
        ),
      ],
    );
  }
}
