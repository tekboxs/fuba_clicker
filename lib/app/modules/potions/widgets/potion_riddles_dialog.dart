import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';
import 'package:google_fonts/google_fonts.dart';

class PotionRiddlesDialog extends StatefulWidget {
  const PotionRiddlesDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PotionRiddlesDialog(),
    );
  }

  @override
  State<PotionRiddlesDialog> createState() => _PotionRiddlesDialogState();
}

class _PotionRiddlesDialogState extends State<PotionRiddlesDialog> {
  final GlobalKey<PageFlipWidgetState> _pageFlipKey =
      GlobalKey<PageFlipWidgetState>();
  int _currentPage = 0;
  late final List<Map<String, String>> _riddles;

  @override
  void initState() {
    super.initState();
    _riddles = _getPotionRiddles();
  }

  void _updatePage(int newPage) {
    if (newPage != _currentPage) {
      setState(() {
        _currentPage = newPage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 900,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF5D4037),
                    Color(0xFF3E2723),
                    Color(0xFF5D4037),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(200),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    PageFlipWidget(
                      key: _pageFlipKey,
                      backgroundColor: const Color(0xFFF5E6D3),
                      duration: const Duration(milliseconds: 600),
                      children: _buildBookPages(),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF5D4037),
                          size: 28,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFE8D5B7).withAlpha(200),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Color(0xFF5D4037),
                              size: 32,
                            ),
                            onPressed: _currentPage > 0
                                ? () async {
                                    _pageFlipKey.currentState?.previousPage();
                                    await Future.delayed(
                                        const Duration(milliseconds: 300));
                                    _updatePage(_currentPage - 1);
                                  }
                                : null,
                            style: IconButton.styleFrom(
                              backgroundColor: _currentPage > 0
                                  ? const Color(0xFFE8D5B7).withAlpha(200)
                                  : Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B7355).withAlpha(150),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_currentPage + 1} / ${((_riddles.length / 2)+1).ceil()}',
                              style: GoogleFonts.kalam(
                                color: const Color(0xFF3E2723),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF5D4037),
                              size: 32,
                            ),
                            onPressed:
                                _currentPage < ((_riddles.length / 2)+1).ceil() - 1
                                    ? () async {
                                        _pageFlipKey.currentState?.nextPage();
                                        await Future.delayed(
                                            const Duration(milliseconds: 300));
                                        _updatePage(_currentPage + 1);
                                      }
                                    : null,
                            style: IconButton.styleFrom(
                              backgroundColor: _currentPage <
                                      (_riddles.length / 2).ceil() - 1
                                  ? const Color(0xFFE8D5B7).withAlpha(200)
                                  : Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBookPages() {
    final pages = <Widget>[];

    pages.add(_buildCoverPage());

    for (int i = 0; i < _riddles.length; i += 2) {
      final leftRiddle = _riddles[i];
      final rightRiddle = i + 1 < _riddles.length ? _riddles[i + 1] : null;

      pages.add(_buildDoublePage(leftRiddle, rightRiddle));
    }

    return pages;
  }

  Widget _buildCoverPage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF5E6D3),
            Color(0xFFE8D5B7),
            Color(0xFFD4C4A8),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E2723).withAlpha(30),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF5D4037),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_stories,
                      color: Color(0xFF5D4037),
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'X',
                    style: GoogleFonts.kalam(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3E2723),
                      letterSpacing: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Os Segredos Perdidos',
                    style: GoogleFonts.kalam(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5D4037),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8D5B7).withAlpha(100),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF8B7355).withAlpha(100),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Para quem encontrar este livro:',
                          style: GoogleFonts.kalam(
                            fontSize: 13,
                            color: const Color(0xFF5D4037),
                            fontWeight: FontWeight.w600,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Se você está lendo estas palavras,'
                          ' significa que o destino te trouxe até aqui.'
                          ' Este livro contém segredos que muitos'
                          ' tentaram descobrir e falharam.',
                          style: GoogleFonts.kalam(
                            fontSize: 13,
                            color: const Color(0xFF3E2723),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'As poções aqui descritas são mais'
                          ' do que simples receitas. São fragmentos'
                          ' de uma verdade maior que escolhi'
                          ' esconder neste mundo.',
                          style: GoogleFonts.kalam(
                            fontSize: 13,
                            color: const Color(0xFF3E2723),
                            height: 1.6,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '— ',
                                style: GoogleFonts.kalam(
                                  fontSize: 14,
                                  color: const Color(0xFF5D4037),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'X',
                                style: GoogleFonts.kalam(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF5D4037),
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 8,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF5D4037),
                  Color(0xFF3E2723),
                  Color(0xFF5D4037),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Índice',
                    style: GoogleFonts.kalam(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _riddles.length,
                      itemBuilder: (context, index) {
                        final riddle = _riddles[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF5D4037),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${index + 1}. ${riddle['name'] ?? ''}',
                                  style: GoogleFonts.kalam(
                                    fontSize: 14,
                                    color: const Color(0xFF4E342E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E2723).withAlpha(15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFF8B7355).withAlpha(50),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '"Aquele que decifrar todas as charadas\n'
                      'descobrirá a verdade que escondi..."',
                      style: GoogleFonts.kalam(
                        fontSize: 11,
                        color: const Color(0xFF5D4037),
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoublePage(
      Map<String, String> leftRiddle, Map<String, String>? rightRiddle) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF5E6D3),
            Color(0xFFE8D5B7),
            Color(0xFFD4C4A8),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: const Color(0xFF8B7355).withAlpha(100),
                    width: 1,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: BookLinesPainter(),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: _buildRiddlePage(leftRiddle),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 8,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF5D4037),
                  Color(0xFF3E2723),
                  Color(0xFF5D4037),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: const Color(0xFF8B7355).withAlpha(100),
                    width: 1,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: BookLinesPainter(),
                      ),
                    ),
                  ),
                  rightRiddle != null
                      ? SingleChildScrollView(
                          child: _buildRiddlePage(rightRiddle),
                        )
                      : Center(
                          child: Text(
                            'Fubá.',
                            style: GoogleFonts.kalam(
                              fontSize: 18,
                              color: const Color(0xFF5D4037),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiddlePage(Map<String, String> riddle) {
    final isLastPage = _riddles.indexOf(riddle) == _riddles.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF8B7355).withAlpha(60),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              riddle['name'] ?? '',
              style: GoogleFonts.kalam(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3E2723),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF5E6D3).withAlpha(50),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFF8B7355).withAlpha(80),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 3,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: Text(
              riddle['riddle'] ?? '',
              style: GoogleFonts.kalam(
                fontSize: 16,
                color: const Color(0xFF4E342E),
                height: 2.0,
                letterSpacing: 0.3,
              ),
            ),
          ),
          if (isLastPage) ...[
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF3E2723).withAlpha(15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: const Color(0xFF5D4037).withAlpha(80),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5D4037),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Uma última palavra',
                        style: GoogleFonts.kalam(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3E2723),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Se você está lendo isto, significa que bolo de fubá.'
                    ' Mas saiba que'
                    ' este é apenas o começo.',
                    style: GoogleFonts.kalam(
                      fontSize: 13,
                      color: const Color(0xFF4E342E),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Cada poção que você criar me aproxima de você.'
                          ' Cada mistério desvendado revela um fragmento'
                          ' da verdade que escondi. Mas cuidado...',
                          style: GoogleFonts.kalam(
                            fontSize: 13,
                            color: const Color(0xFF4E342E),
                            height: 1.8,
                          ),
                        ),
                      ),
                      Text(
                        '[...]',
                        style: GoogleFonts.kalam(
                          fontSize: 13,
                          color: const Color(0xFF8B7355).withAlpha(100),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Continue experimentando. Continue descobrindo.'
                    ' Talvez um dia você me encontre... ou talvez',
                    style: GoogleFonts.kalam(
                      fontSize: 13,
                      color: const Color(0xFF4E342E),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'eu já esteja',
                        style: GoogleFonts.kalam(
                          fontSize: 13,
                          color: const Color(0xFF4E342E),
                          height: 1.8,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        ' [...] ',
                        style: GoogleFonts.kalam(
                          fontSize: 13,
                          color: const Color(0xFF8B7355).withAlpha(100),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        'você.',
                        style: GoogleFonts.kalam(
                          fontSize: 13,
                          color: const Color(0xFF4E342E),
                          height: 1.8,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E2723).withAlpha(10),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '[Parte do texto está ilegível devido ao tempo...]',
                          style: GoogleFonts.kalam(
                            fontSize: 10,
                            color: const Color(0xFF8B7355).withAlpha(120),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '— ',
                          style: GoogleFonts.kalam(
                            fontSize: 16,
                            color: const Color(0xFF5D4037),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'X',
                          style: GoogleFonts.kalam(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5D4037),
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Map<String, String>> _getPotionRiddles() {
    return [
      {
        'name': 'Poção de Força Básica',
        'emoji': '⚡',
        'riddle':
            'A chama que acende todas as outras, a primeira centelha no escuro. Quando a mão do iniciante toca o caldeirão, quantas vezes o fogo deve dançar antes que a força desperte? Procure o que nasce do chão, o que todos carregam sem saber. A resposta está na palma de sua mão, no número.',
      },
      {
        'name': 'Poção de Poder',
        'emoji': '💪',
        'riddle':
            'O encontro entre o que rasteja e o que voa. O vermelho do alvorecer encontra o azul do crepúsculo, mas não em igual medida. O primeiro domina, o segundo complementa. Quando o que é terrestre abraça o que é celeste, quando o fogo da terra se une às águas do céu, o toque se transforma em golpe. A terra deve prevalecer sobre o céu.',
      },
      {
        'name': 'Elixir de Tokens',
        'emoji': '⭐',
        'riddle':
            'Onde o céu toca a terra, onde o raro encontra o comum. Mais do que voa alto, menos do que permanece baixo. Quando as estrelas se alinham com a floresta, quando o azul do firmamento dança com o verde da vida, os fragmentos celestiais descem como chuva. O céu deve reinar sobre a terra, mas a terra não pode ser esquecida.',
      },
      {
        'name': 'Poção de Forus',
        'emoji': '💎',
        'riddle':
            'Dois tronos, dois reinos de poder imenso. Um nasce da tempestade roxa, outro do sol dourado. Quando se encontram como iguais, como espelhos perfeitos, quando a balança não pende para nenhum lado, quando nenhum domina o outro, a riqueza se multiplica além da compreensão. A simetria é sagrada aqui.',
      },
      {
        'name': 'Amplificador de Rebirth',
        'emoji': '🔄',
        'riddle':
            'Das profundezas do oceano sem fim, e do amanhecer que nunca se apaga. O abismo ciano e o despertar rosa se entrelaçam, mas o oceano deve fluir com intensidade superior. Quando o ciclo se completa, quando o que é profundo domina o que é suave, quando as águas profundas superam o despertar em sua essência, quando a profundidade prevalece sobre a delicadeza, tudo renasce.',
      },
      {
        'name': 'Essência Cósmica',
        'emoji': '🌌',
        'riddle':
            'A dualidade última: o branco que contém tudo e o preto que é a ausência de tudo. Quando a luz pura encontra o vazio primordial, quando o que é completo se une ao que é vazio, quando a luz domina mas não anula a escuridão, o próprio universo responde ao chamado. A proporção é crucial: a luz deve reinar, mas a escuridão não pode ser negligenciada. Ambas são necessárias, mas uma prevalece sobre a outra.',
      },
      {
        'name': 'Poção Permanente',
        'emoji': '♾️',
        'riddle':
            'O equilíbrio perfeito entre o tudo e o nada. Quando a luz e a escuridão se encontram em quantidades que desafiam a razão, quando a balança não pende para nenhum lado mesmo sob o peso imenso, algo que transcende o tempo nasce. Mas cuidado: este caminho exige dedicação extrema. Quantidades que parecem impossíveis, que desafiam a compreensão, de cada lado, até que a perfeição seja alcançada. Este é o caminho dos verdadeiros alquimistas.',
      },
      {
        'name': 'O Segredo das Cores',
        'emoji': '🎨',
        'riddle':
            'Cada objeto que você carrega guarda uma essência, uma cor que reflete sua natureza. Do mais humilde ao mais divino, cada um canta uma nota diferente na sinfonia do poder. Observe não apenas o que é, mas o que representa.',
      },
      {
        'name': 'A Arte da Mistura',
        'emoji': '🧪',
        'riddle':
            'Uma única cor pode despertar poder, mas a verdadeira magia nasce da harmonia entre opostos. Quando diferentes essências se encontram no caldeirão, quando o que é distinto se torna um, poções que desafiam a lógica podem surgir. Experimente. Descubra. Crie.',
      },
    ];
  }
}

class BookLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B7355).withAlpha(20)
      ..strokeWidth = 0.5;

    // Linhas horizontais para simular papel pautado
    for (double y = 40; y < size.height; y += 24) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Margem esquerda (linha vertical)
    final marginPaint = Paint()
      ..color = const Color(0xFF8B7355).withAlpha(40)
      ..strokeWidth = 1;

    canvas.drawLine(
      const Offset(30, 0),
      Offset(30, size.height),
      marginPaint,
    );
  }

  @override
  bool shouldRepaint(BookLinesPainter oldDelegate) => false;
}
