import 'package:flutter/material.dart';

class ShopTutorial extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const ShopTutorial({
    super.key,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<ShopTutorial> createState() => _ShopTutorialState();
}

class _ShopTutorialState extends State<ShopTutorial> {
  int _currentStep = 0;

  final List<TutorialStep> _steps = [
    TutorialStep(
      title: 'Bem-vindo à Loja! 🎁',
      description:
          'Aqui você pode comprar caixas para conseguir acessórios incríveis que aumentam seus bônus!',
      emoji: '🎁',
      position: TutorialPosition.center,
    ),
    TutorialStep(
      title: 'Compre Caixas 📦',
      description:
          'Clique em uma caixa para abri-la e ganhar acessórios aleatórios. Quanto melhor a caixa, melhores os acessórios que você pode conseguir!',
      emoji: '📦',
      position: TutorialPosition.center,
    ),
    TutorialStep(
      title: 'Veja seu Inventário 🎒',
      description:
          'Clique no botão flutuante "Inventário" no canto inferior direito para ver todos os acessórios que você coletou!',
      emoji: '🎒',
      position: TutorialPosition.bottom,
    ),
    TutorialStep(
      title: 'Equipe seus Acessórios ⚔️',
      description:
          'No inventário, clique nos itens verdes com "Clique para equipar" para equipá-los. Itens equipados aumentam seus bônus permanentemente!',
      emoji: '⚔️',
      position: TutorialPosition.center,
    ),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      widget.onComplete();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _skip() {
    widget.onSkip();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    return Stack(
      children: [
        GestureDetector(
          onTap: _nextStep,
          child: Container(
            color: Colors.black.withOpacity(0.75),
          ),
        ),
        _TutorialCard(
          step: step,
          currentStep: _currentStep,
          totalSteps: _steps.length,
          onNext: _nextStep,
          onPrevious: _previousStep,
          onSkip: _skip,
          showPrevious: _currentStep > 0,
          isLastStep: _currentStep == _steps.length - 1,
        ),
      ],
    );
  }
}

class TutorialStep {
  final String title;
  final String description;
  final String emoji;
  final TutorialPosition position;

  TutorialStep({
    required this.title,
    required this.description,
    required this.emoji,
    required this.position,
  });
}

enum TutorialPosition {
  top,
  bottom,
  left,
  right,
  center,
}


class _TutorialCard extends StatelessWidget {
  final TutorialStep step;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;
  final bool showPrevious;
  final bool isLastStep;

  const _TutorialCard({
    required this.step,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
    required this.showPrevious,
    required this.isLastStep,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final screenSize = MediaQuery.of(context).size;

    Offset cardPosition;
    switch (step.position) {
      case TutorialPosition.top:
        cardPosition = Offset(screenSize.width / 2, 100);
        break;
      case TutorialPosition.bottom:
        cardPosition = Offset(screenSize.width / 2, screenSize.height - 200);
        break;
      case TutorialPosition.left:
        cardPosition = Offset(200, screenSize.height / 2);
        break;
      case TutorialPosition.right:
        cardPosition = Offset(screenSize.width - 200, screenSize.height / 2);
        break;
      case TutorialPosition.center:
        cardPosition = Offset(screenSize.width / 2, screenSize.height / 2);
        break;
    }

    return Positioned(
      left: cardPosition.dx - (isMobile ? 150 : 200),
      top: cardPosition.dy - (isMobile ? 100 : 120),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: isMobile ? 300 : 400,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D23),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.cyan.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withOpacity(0.3),
                blurRadius: 24,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Color(0x80000000),
                blurRadius: 32,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          step.emoji,
                          style: TextStyle(fontSize: isMobile ? 24 : 28),
                        ),
                        SizedBox(width: isMobile ? 8 : 12),
                        Expanded(
                          child: Text(
                            step.title,
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: onSkip,
                    iconSize: 20,
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                step.description,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${currentStep + 1}/$totalSteps',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: Colors.white54,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showPrevious)
                        TextButton(
                          onPressed: onPrevious,
                          child: const Text(
                            'Anterior',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      SizedBox(width: isMobile ? 8 : 12),
                      ElevatedButton(
                        onPressed: onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 16 : 24,
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        child: Text(
                          isLastStep ? 'Concluir' : 'Próximo',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

