import 'dart:math';
import 'package:big_decimal/big_decimal.dart';

// Cópia da implementação para teste
class TestGenerator {
  final BigDecimal baseProduction;
  
  TestGenerator(this.baseProduction);
  
  BigDecimal getProduction(int owned) {
    if (owned <= 0) return BigDecimal.zero;

    // Tier 1 (1-100): Crescimento linear
    if (owned <= 100) {
      return baseProduction * BigDecimal.parse(owned.toString());
    }

    // Tier 2 (101-300): Crescimento suave (expoente 1.15)
    if (owned <= 300) {
      final linearBase = baseProduction * BigDecimal.parse('100');
      final excessOwned = owned - 100;
      final exponentialFactor = pow(1 + (excessOwned / 100), 1.15);
      return linearBase * BigDecimal.parse((exponentialFactor * 100).toString());
    }

    // Tier 3 (301-600): Crescimento moderado (expoente 1.3)
    if (owned <= 600) {
      final tier2Value = _calculateTier2Max();
      final excessOwned = owned - 300;
      final exponentialFactor = pow(1 + (excessOwned / 300), 1.3);
      return tier2Value * BigDecimal.parse(exponentialFactor.toString());
    }

    // Tier 4 (601+): Crescimento forte mas controlado (expoente 1.45)
    final tier3Value = _calculateTier3Max();
    final excessOwned = owned - 600;
    final exponentialFactor = pow(1 + (excessOwned / 600), 1.45);
    return tier3Value * BigDecimal.parse(exponentialFactor.toString());
  }

  BigDecimal _calculateTier2Max() {
    final linearBase = baseProduction * BigDecimal.parse('100');
    final exponentialFactor = pow(1 + (200 / 100), 1.15);
    return linearBase * BigDecimal.parse((exponentialFactor * 100).toString());
  }

  BigDecimal _calculateTier3Max() {
    final tier2Value = _calculateTier2Max();
    final exponentialFactor = pow(1 + (300 / 300), 1.3);
    return tier2Value * BigDecimal.parse(exponentialFactor.toString());
  }
}

// Teste para validar a progressão dos novos geradores
class NewGeneratorBalanceTest {
  static void testGeneratorProgression() {
    print('=== TESTE DE PROGRESSÃO DOS NOVOS GERADORES ===\n');
    
    // Simula os custos e produções dos novos geradores
    final List<Map<String, dynamic>> newGenerators = [
      {'name': 'Fubá Ancestral', 'cost': '1e400', 'production': '1e230'},
      {'name': 'Moedor Cósmico', 'cost': '1e450', 'production': '1e260'},
      {'name': 'Memória do Fubá', 'cost': '1e500', 'production': '1e290'},
      {'name': 'Forno Primordial', 'cost': '1e550', 'production': '1e320'},
      {'name': 'Receita Universal', 'cost': '1e600', 'production': '1e350'},
      {'name': 'Sonho de Fubá', 'cost': '1e650', 'production': '1e380'},
      {'name': 'Tempo do Fubá', 'cost': '1e700', 'production': '1e410'},
      {'name': 'O Observador do Fubá', 'cost': '1e750', 'production': '1e440'},
      {'name': 'Fubá do Vazio', 'cost': '1e800', 'production': '1e470'},
      {'name': 'A Primeira Receita', 'cost': '1e900', 'production': '1e540'},
      {'name': 'Fubá Infinito', 'cost': '1e1000', 'production': '1e610'},
      {'name': 'O Paradoxo do Fubá', 'cost': '1e1100', 'production': '1e680'},
      {'name': 'A Última Pergunta do Fubá', 'cost': '1e1200', 'production': '1e750'},
      {'name': 'O Jogo do Fubá', 'cost': '1e1300', 'production': '1e820'},
      {'name': 'A Barreira do Fubá', 'cost': '1e1400', 'production': '1e890'},
      {'name': 'O Armazém do Fubá', 'cost': '1e1250', 'production': '1e800'},
      {'name': 'A Variável do Fubá', 'cost': '1e1300', 'production': '1e850'},
      {'name': 'O Ciclo Eterno do Fubá', 'cost': '1e1350', 'production': '1e900'},
      {'name': 'A Receita Recursiva', 'cost': '1e1400', 'production': '1e950'},
      {'name': 'O Coletor de Fubá', 'cost': '1e1450', 'production': '1e1000'},
      {'name': 'O Compilador de Fubá', 'cost': '1e1475', 'production': '1e1050'},
      {'name': 'A Biblioteca do Fubá', 'cost': '1e1485', 'production': '1e1100'},
      {'name': 'O Detector de Fubá', 'cost': '1e1490', 'production': '1e1150'},
      {'name': 'A Exceção do Fubá', 'cost': '1e1495', 'production': '1e1200'},
      {'name': 'O Ponto Nulo do Fubá', 'cost': '1e1498', 'production': '1e1250'},
      {'name': 'A Última Receita', 'cost': '1e1499', 'production': '1e1300'},
      {'name': 'O Fubá Absoluto', 'cost': '1e1500', 'production': '1e1350'},
    ];
    
    print('Análise de Progressão:');
    print('${'Gerador'.padRight(25)}${'Custo'.padRight(15)}${'Produção'.padRight(15)}Razão Custo/Prod');
    print('-' * 70);
    
    for (int i = 0; i < newGenerators.length; i++) {
      final gen = newGenerators[i];
      final cost = BigDecimal.parse(gen['cost']);
      final production = BigDecimal.parse(gen['production']);
      final ratio = cost.divide(production, scale: 2, roundingMode: RoundingMode.HALF_UP);
      
      print('${'${gen['name']}'.padRight(25)}${'${gen['cost']}'.padRight(15)}${'${gen['production']}'.padRight(15)}${ratio.toDouble().toStringAsFixed(1)}');
    }
    
    print('\n=== ANÁLISE DE WALLS ===\n');
    
    // Identifica as seções de progressão suave vs walls
    print('Seção Suave 1 (34-42): Custo 1e400-1e800');
    print('Primeiro Wall (43-48): Custo 1e900-1e1400 (requer múltiplas ascensões)');
    print('Seção Suave 2 (49-53): Custo 1e1250-1e1450');
    print('Wall Final (54-60): Custo 1e1475-1e1500 (requer transcendências)');
    
    print('\n=== VALIDAÇÃO DE BALANCEAMENTO ===\n');
    
    // Verifica se as razões custo/produção são apropriadas
    final smoothSection1 = newGenerators.take(9).toList(); // 34-42
    final firstWall = newGenerators.skip(9).take(6).toList(); // 43-48
    final smoothSection2 = newGenerators.skip(15).take(5).toList(); // 49-53
    final finalWall = newGenerators.skip(20).toList(); // 54-60
    
    print('Seção Suave 1 - Razões médias:');
    _analyzeSection(smoothSection1);
    
    print('\nPrimeiro Wall - Razões médias:');
    _analyzeSection(firstWall);
    
    print('\nSeção Suave 2 - Razões médias:');
    _analyzeSection(smoothSection2);
    
    print('\nWall Final - Razões médias:');
    _analyzeSection(finalWall);
  }
  
  static void _analyzeSection(List<Map<String, dynamic>> generators) {
    if (generators.isEmpty) return;
    
    double totalRatio = 0;
    for (final gen in generators) {
      final cost = BigDecimal.parse(gen['cost']);
      final production = BigDecimal.parse(gen['production']);
      final ratio = cost.divide(production, scale: 2, roundingMode: RoundingMode.HALF_UP);
      totalRatio += ratio.toDouble();
    }
    
    final avgRatio = totalRatio / generators.length;
    print('Razão média: ${avgRatio.toStringAsFixed(1)}');
    
    // Verifica se a progressão está balanceada
    if (avgRatio < 1000) {
      print('✅ Seção bem balanceada');
    } else if (avgRatio < 10000) {
      print('⚠️ Seção moderadamente desafiadora');
    } else {
      print('🔥 Seção muito desafiadora (wall)');
    }
  }
}

void main() {
  final generator = TestGenerator(BigDecimal.parse('1.0'));
  
  print('=== TESTE DE BALANCEAMENTO DOS GERADORES ===\n');
  
  final testPoints = [50, 100, 150, 200, 250, 300, 400, 500, 600, 700, 800, 1000];
  
  for (int owned in testPoints) {
    final production = generator.getProduction(owned);
    final multiplier = production.divide(generator.baseProduction, scale: 2, roundingMode: RoundingMode.HALF_UP);
    
    print('${owned.toString().padLeft(4)} geradores: ${multiplier.toDouble().toStringAsFixed(1)}x base');
  }
  
  print('\n=== COMPARAÇÃO COM FÓRMULA ANTERIOR ===\n');
  
  // Fórmula anterior para comparação
  for (int owned in [100, 200, 300, 400, 500, 600, 800, 1000]) {
    if (owned <= 100) {
      print('${owned.toString().padLeft(4)} geradores: ${owned.toDouble().toStringAsFixed(1)}x base (linear)');
    } else {
      final oldFormula = pow(owned, 1.5);
      print('${owned.toString().padLeft(4)} geradores: ${oldFormula.toStringAsFixed(1)}x base (ANTIGA)');
    }
  }
  
  print('\n');
  NewGeneratorBalanceTest.testGeneratorProgression();
}
