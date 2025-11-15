import 'dart:math';
import 'package:flutter/material.dart';

class OrbitingEmoji extends StatefulWidget {
  final String emoji;
  final double fontSize;
  final double orbitRadius;
  final Duration orbitDuration;

  const OrbitingEmoji({
    super.key,
    required this.emoji,
    this.fontSize = 24,
    this.orbitRadius = 20,
    this.orbitDuration = const Duration(seconds: 3),
  });

  @override
  State<OrbitingEmoji> createState() => _OrbitingEmojiState();
}

class _OrbitingEmojiState extends State<OrbitingEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.orbitDuration,
    )..repeat();
  }

  @override
  void didUpdateWidget(OrbitingEmoji oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orbitDuration != widget.orbitDuration) {
      _controller.duration = widget.orbitDuration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> _splitEmojis(String emojiString) {
    final emojis = <String>[];
    final runes = emojiString.runes.toList();
    
    if (runes.isEmpty) {
      return [emojiString];
    }
    
    String currentEmoji = '';
    int i = 0;
    
    while (i < runes.length) {
      final rune = runes[i];
      final char = String.fromCharCode(rune);
      
      if (_isEmojiRune(rune)) {
        if (currentEmoji.isNotEmpty) {
          emojis.add(currentEmoji);
        }
        currentEmoji = char;
        
        i++;
        while (i < runes.length && (runes[i] == 0xFE0F || runes[i] == 0x200D)) {
          currentEmoji += String.fromCharCode(runes[i]);
          i++;
        }
        
        emojis.add(currentEmoji);
        currentEmoji = '';
      } else if (rune == 0x200D || rune == 0xFE0F) {
        currentEmoji += char;
        i++;
      } else {
        if (currentEmoji.isNotEmpty) {
          currentEmoji += char;
        } else if (emojis.isEmpty) {
          return [emojiString];
        }
        i++;
      }
    }
    
    if (currentEmoji.isNotEmpty) {
      emojis.add(currentEmoji);
    }
    
    return emojis.isEmpty ? [emojiString] : emojis;
  }

  bool _isEmojiRune(int rune) {
    return (rune >= 0x1F300 && rune <= 0x1F9FF) ||
        (rune >= 0x1FA00 && rune <= 0x1FAFF) ||
        (rune >= 0x2600 && rune <= 0x26FF) ||
        (rune >= 0x2700 && rune <= 0x27BF) ||
        (rune >= 0x1F600 && rune <= 0x1F64F) ||
        (rune >= 0x1F680 && rune <= 0x1F6FF) ||
        (rune >= 0x1F1E0 && rune <= 0x1F1FF) ||
        (rune >= 0x2B00 && rune <= 0x2BFF) ||
        (rune >= 0x23E9 && rune <= 0x23FF) ||
        (rune >= 0x231A && rune <= 0x231B) ||
        (rune >= 0x25FD && rune <= 0x25FE) ||
        (rune >= 0x2614 && rune <= 0x2615) ||
        (rune >= 0x2648 && rune <= 0x2653) ||
        (rune >= 0x267F && rune <= 0x267F) ||
        (rune >= 0x2693 && rune <= 0x2693) ||
        (rune >= 0x26A1 && rune <= 0x26A1) ||
        (rune >= 0x26AA && rune <= 0x26AB) ||
        (rune >= 0x26BD && rune <= 0x26BE) ||
        (rune >= 0x26C4 && rune <= 0x26C5) ||
        (rune >= 0x26CE && rune <= 0x26CE) ||
        (rune >= 0x26D4 && rune <= 0x26D4) ||
        (rune >= 0x26EA && rune <= 0x26EA) ||
        (rune >= 0x26F2 && rune <= 0x26F3) ||
        (rune >= 0x26F5 && rune <= 0x26F5) ||
        (rune >= 0x26FA && rune <= 0x26FA) ||
        (rune >= 0x26FD && rune <= 0x26FD) ||
        (rune >= 0x2705 && rune <= 0x2705) ||
        (rune >= 0x270A && rune <= 0x270B) ||
        (rune >= 0x2728 && rune <= 0x2728) ||
        (rune >= 0x274C && rune <= 0x274C) ||
        (rune >= 0x274E && rune <= 0x274E) ||
        (rune >= 0x2753 && rune <= 0x2755) ||
        (rune >= 0x2757 && rune <= 0x2757) ||
        (rune >= 0x2795 && rune <= 0x2797) ||
        (rune >= 0x27B0 && rune <= 0x27B0) ||
        (rune >= 0x27BF && rune <= 0x27BF) ||
        (rune == 0x3030) ||
        (rune == 0x303D) ||
        (rune == 0x3297) ||
        (rune == 0x3299);
  }

  @override
  Widget build(BuildContext context) {
    final emojiRunes = widget.emoji.runes.length;
    
    if (emojiRunes < 2) {
      return Text(
        widget.emoji,
        style: TextStyle(fontSize: widget.fontSize),
      );
    }

    final emojis = _splitEmojis(widget.emoji);
    
    if (emojis.length < 2) {
      return Text(
        widget.emoji,
        style: TextStyle(fontSize: widget.fontSize),
      );
    }

    final firstEmoji = emojis[0];
    final secondEmoji = emojis[1];

    return SizedBox(
      width: widget.fontSize + widget.orbitRadius * 2,
      height: widget.fontSize + widget.orbitRadius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            firstEmoji,
            style: TextStyle(fontSize: widget.fontSize),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = _controller.value * 2 * pi;
              final x = cos(angle) * widget.orbitRadius;
              final y = sin(angle) * widget.orbitRadius;
              
              return Transform.translate(
                offset: Offset(x, y),
                child: child,
              );
            },
            child: Text(
              secondEmoji,
              style: TextStyle(fontSize: widget.fontSize * 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

