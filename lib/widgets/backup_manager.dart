import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../services/save_service.dart';
import '../services/save_validation_service.dart';

class BackupManager extends StatefulWidget {
  final GameSaveData currentSave;

  const BackupManager({
    super.key,
    required this.currentSave,
  });

  @override
  State<BackupManager> createState() => _BackupManagerState();
}

class _BackupManagerState extends State<BackupManager> {
  final TextEditingController _codeController = TextEditingController();
  String? _generatedCode;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _generateBackupCode() {
    try {
      final saveService = SaveService();
      final code = saveService.generateBackupCode(
        fuba: widget.currentSave.fuba,
        generators: widget.currentSave.generators,
        inventory: widget.currentSave.inventory,
        equipped: widget.currentSave.equipped,
        rebirthData: widget.currentSave.rebirthData,
        achievements: widget.currentSave.achievements,
        achievementStats: widget.currentSave.achievementStats,
        upgrades: widget.currentSave.upgrades,
      );
      
      setState(() {
        _generatedCode = code;
        _errorMessage = null;
        _successMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao gerar código: $e';
        _generatedCode = null;
      });
    }
  }

  void _restoreFromCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Digite um código de backup';
        _successMessage = null;
      });
      return;
    }

    try {
      final saveService = SaveService();
      final restoredData = saveService.restoreFromBackupCode(code);
      
      if (restoredData != null) {
        await saveService.saveGame(
          fuba: restoredData.fuba,
          generators: restoredData.generators,
          inventory: restoredData.inventory,
          equipped: restoredData.equipped,
          rebirthData: restoredData.rebirthData,
          achievements: restoredData.achievements,
          achievementStats: restoredData.achievementStats,
          upgrades: restoredData.upgrades,
        );
        
        setState(() {
          _successMessage = 'Save restaurado com sucesso!';
          _errorMessage = null;
        });
        
        _codeController.clear();
      } else {
        setState(() {
          _errorMessage = 'Código de backup inválido ou expirado';
          _successMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao restaurar save: $e';
        _successMessage = null;
      });
    }
  }

  void _copyToClipboard() {
    if (_generatedCode != null) {
      Clipboard.setData(ClipboardData(text: _generatedCode!));
      setState(() {
        _successMessage = 'Código copiado para a área de transferência!';
      });
    }
  }

  void _exportToFile() async {
    try {
      final saveService = SaveService();
      final jsonData = await saveService.exportToFile();
      
      if (kIsWeb) {
        _showWebExportDialog(jsonData);
      } else {
        // Para mobile/desktop, implementar file picker se necessário
        Clipboard.setData(ClipboardData(text: jsonData));
        setState(() {
          _successMessage = 'Dados exportados copiados para área de transferência!';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao exportar dados: $e';
      });
    }
  }

  void _showWebExportDialog(String jsonData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Save'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Copie o JSON abaixo e salve em um arquivo:'),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonData,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonData));
              Navigator.of(context).pop();
              setState(() {
                _successMessage = 'Dados exportados copiados para área de transferência!';
              });
            },
            child: const Text('Copiar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _importFromFile() async {
    if (kIsWeb) {
      _showWebImportDialog();
    } else {
      // Para mobile/desktop, implementar file picker se necessário
      setState(() {
        _errorMessage = 'Importação de arquivo não implementada para esta plataforma';
      });
    }
  }

  void _showWebImportDialog() {
    final TextEditingController importController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importar Save'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Cole o JSON do save que deseja importar:'),
            const SizedBox(height: 16),
            TextField(
              controller: importController,
              decoration: const InputDecoration(
                hintText: 'Cole o JSON aqui...',
                border: OutlineInputBorder(),
              ),
              maxLines: 8,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final jsonData = importController.text.trim();
              if (jsonData.isEmpty) return;
              
              try {
                final saveService = SaveService();
                final success = await saveService.importFromFile(jsonData);
                
                Navigator.of(context).pop();
                
                if (success) {
                  setState(() {
                    _successMessage = 'Save importado com sucesso!';
                    _errorMessage = null;
                  });
                } else {
                  setState(() {
                    _errorMessage = 'Erro ao importar save: JSON inválido';
                    _successMessage = null;
                  });
                }
              } catch (e) {
                Navigator.of(context).pop();
                setState(() {
                  _errorMessage = 'Erro ao importar save: $e';
                  _successMessage = null;
                });
              }
            },
            child: const Text('Importar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciador de Backup'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gerar Código de Backup',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gere um código para fazer backup do seu progresso atual.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _generateBackupCode,
                            child: const Text('Gerar Código'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _exportToFile,
                            icon: const Icon(Icons.download),
                            label: const Text('Exportar'),
                          ),
                        ),
                      ],
                    ),
                    if (_generatedCode != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Seu código de backup:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              _generatedCode!,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _copyToClipboard,
                              icon: const Icon(Icons.copy),
                              label: const Text('Copiar'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Restaurar de Código',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Digite um código de backup para restaurar seu progresso.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Código de Backup',
                        border: OutlineInputBorder(),
                        hintText: 'Cole seu código aqui...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _restoreFromCode,
                            child: const Text('Restaurar Save'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _importFromFile,
                            icon: const Icon(Icons.upload),
                            label: const Text('Importar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_successMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
