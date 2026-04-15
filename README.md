# 🌽 Fuba Clicker

Um jogo clicker viciante em Flutter onde você produz fubá clicando em bolos e comprando geradores automáticos!

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)

## ![Veja você Mesmo!](https://fubaclicker.com.br)
## 🎮 Sobre o Jogo

Fuba Clicker é um jogo de clicker incremental onde você:
- **Clica** no bolo para produzir fubá manualmente
- **Compra** geradores automáticos para produção passiva
- **Desbloqueia** novos geradores conforme progride
- **Ascende** através de 12 tiers diferentes de geradores

### 🏆 Sistema de Tiers
- 🟢 **Common** - Geradores básicos
- 🔵 **Rare** - Melhor eficiência
- 🟣 **Epic** - Produção avançada
- 🟠 **Legendary** - Geradores lendários
- 🩷 **Mythical** - Poderes míticos
- 🔴 **Godly** - Divindades do fubá
- 🔵 **Cosmic** - Forças cósmicas
- 🟡 **Divine** - Poderes divinos
- ⚫ **Absolute** - Absoluto controle
- 🔵 **Transcendent** - Transcendência
- 🟣 **Eternal** - Eternidade
- ⚪ **Truth** - A verdade final

## 🚀 Funcionalidades

### ✨ Recursos Principais
- **Interface responsiva** - Funciona em mobile e desktop
- **Animações fluidas** - Usando Flutter Animate
- **Sistema de áudio** - Trilha sonora com controles
- **Background parallax** - Efeitos visuais imersivos
- **Sistema de partículas** - Efeitos visuais ao clicar
- **Persistência de dados** - Progresso salvo automaticamente

### 🎯 Mecânicas do Jogo
- **Click manual** - Produz fubá clicando no bolo
- **Produção automática** - Geradores produzem fubá por segundo
- **Crescimento exponencial** - Custos aumentam conforme você compra
- **Sistema de desblocagem** - Novos geradores conforme progresso
- **Formatação de números** - Números grandes formatados (K, M, B, etc.)

## 🛠️ Tecnologias Utilizadas

### 📱 Framework Principal
- **Flutter 3.9.2+** - Framework de desenvolvimento
- **Dart** - Linguagem de programação

### 📦 Principais Dependências
- **flutter_riverpod** - Gerenciamento de estado
- **flutter_animate** - Animações avançadas
- **lottie** - Animações Lottie
- **just_audio** - Sistema de áudio
- **flutter_gen** - Geração automática de assets

### 🎨 Assets e Recursos
- **Imagens** - Sprites e ícones customizados
- **Áudio** - Trilha sonora e efeitos sonoros
- **Animações** - Efeitos visuais e transições

## 📱 Plataformas Suportadas

- ✅ **Android** - APK nativo
- ✅ **iOS** - App nativo
- ✅ **Web** - PWA responsivo
- ✅ **Windows** - App desktop
- ✅ **macOS** - App desktop
- ✅ **Linux** - App desktop

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK 3.9.2 ou superior
- Dart SDK
- IDE (VS Code, Android Studio, etc.)

### Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/fuba_clicker.git
cd fuba_clicker
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Execute o projeto**
```bash
flutter run
```

### 🔧 Comandos Úteis

```bash
# Executar em modo debug
flutter run

# Executar em modo release
flutter run --release

# Build para Android
flutter build apk

# Build para Web
flutter build web

# Limpar cache
flutter clean
flutter pub get

# Análise de código
flutter analyze

# Testes
flutter test
```

## 📁 Estrutura do Projeto

```
lib/
├── gen/                    # Arquivos gerados automaticamente
│   └── assets.gen.dart    # Assets gerados pelo flutter_gen
├── models/                # Modelos de dados
│   ├── fuba_generator.dart # Modelo dos geradores
│   └── wave_offset.dart   # Modelo para animações
├── providers/             # Gerenciamento de estado
│   ├── audio_provider.dart    # Estado do áudio
│   └── game_providers.dart    # Estado do jogo
├── utils/                 # Utilitários
│   └── constants.dart     # Constantes do jogo
├── widgets/               # Componentes da UI
│   ├── generator_section.dart    # Seção de geradores
│   ├── home_page.dart           # Página principal
│   ├── parallax_background.dart # Background animado
│   └── particle_system.dart     # Sistema de partículas
└── main.dart              # Ponto de entrada
```

## 🎨 Design e UX

### 🎯 Princípios de Design
- **Interface minimalista** - Foco na jogabilidade
- **Feedback visual** - Animações e efeitos responsivos
- **Acessibilidade** - Controles intuitivos
- **Responsividade** - Adaptável a diferentes telas

### 🌈 Paleta de Cores
- **Tema escuro** - Melhor experiência visual
- **Laranja/Dourado** - Cor principal do fubá
- **Gradientes** - Efeitos visuais suaves
- **Cores por tier** - Identificação visual dos geradores

## 🎵 Sistema de Áudio

### 🔊 Recursos de Áudio
- **Trilha sonora** - Música de fundo
- **Efeitos sonoros** - Feedback ao clicar
- **Controles de volume** - Liga/desliga música
- **Persistência** - Estado salvo entre sessões

### 🎮 Controles Especiais
- **Easter egg** - Clique múltiplo no botão de áudio
- **Mensagens humorísticas** - Feedback interativo

## 📊 Sistema de Progressão

### 📈 Mecânicas de Progressão
- **Produção passiva** - Geradores trabalham automaticamente
- **Crescimento exponencial** - Desafio crescente
- **Desblocagem sequencial** - Progressão linear
- **Números grandes** - Satisfação de ver crescimento

### 🎯 Balanceamento
- **Custos escalonados** - 15% de aumento por compra
- **Produção linear** - Cada gerador adiciona produção fixa
- **Desblocagem progressiva** - Novos geradores conforme necessário

## 🐛 Solução de Problemas

### ❌ Problemas Comuns

**Erro de dependências:**
```bash
flutter clean
flutter pub get
```

**Problemas de build:**
```bash
flutter doctor
flutter upgrade
```

**Assets não carregam:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🤝 Contribuindo

### 📝 Como Contribuir
1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### 🎯 Áreas de Contribuição
- **Novos geradores** - Adicionar mais opções
- **Melhorias visuais** - Animações e efeitos
- **Balanceamento** - Ajustes de gameplay
- **Otimizações** - Performance e código
- **Documentação** - Melhorar este README

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Autor

**Fuba Clicker** - Desenvolvido com ❤️ em Flutter

---

⭐ **Se você gostou do projeto, não esqueça de dar uma estrela!** ⭐

🌽 **Que o fubá esteja sempre com você!** 🌽
