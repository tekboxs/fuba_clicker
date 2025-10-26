import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/app/models/game_save_data.dart';

class ConflictResolutionDialog extends ConsumerWidget {
  final GameSaveData localData;
  final GameSaveData cloudData;
  final VoidCallback onLocalChosen;
  final VoidCallback onCloudChosen;

  const ConflictResolutionDialog({
    super.key,
    required this.localData,
    required this.cloudData,
    required this.onLocalChosen,
    required this.onCloudChosen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 8),
          Text('Conflito de Dados'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Existe uma diferença entre seus dados locais e da nuvem. '
            'Qual versão você gostaria de manter?',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildDataComparison(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            onLocalChosen();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Manter Local'),
        ),
        ElevatedButton(
          onPressed: () {
            onCloudChosen();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Usar Nuvem'),
        ),
      ],
    );
  }

  Widget _buildDataComparison() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDataRow('Fuba Local', localData.fuba.toString()),
            _buildDataRow('Fuba Nuvem', cloudData.fuba.toString()),
            const Divider(),
            _buildDataRow('Generadores Locais', localData.generators.length.toString()),
            _buildDataRow('Generadores Nuvem', cloudData.generators.length.toString()),
            const Divider(),
            _buildDataRow('Conquistas Locais', localData.achievements.length.toString()),
            _buildDataRow('Conquistas Nuvem', cloudData.achievements.length.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}


