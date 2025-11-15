import 'package:flutter/material.dart';

class ItemQuantitySelector extends StatefulWidget {
  final int maxQuantity;
  final Function(int) onQuantitySelected;
  final String emoji;
  final String name;

  const ItemQuantitySelector({
    super.key,
    required this.maxQuantity,
    required this.onQuantitySelected,
    required this.emoji,
    required this.name,
  });

  @override
  State<ItemQuantitySelector> createState() => _ItemQuantitySelectorState();
}

class _ItemQuantitySelectorState extends State<ItemQuantitySelector> {
  int _selectedQuantity = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1D23),
      title: Row(
        children: [
          Text(
            widget.emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Quantidade: $_selectedQuantity',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _selectedQuantity.toDouble(),
            min: 1,
            max: widget.maxQuantity.toDouble().clamp(1, 50),
            divisions: (widget.maxQuantity.clamp(1, 50) - 1),
            label: _selectedQuantity.toString(),
            onChanged: (value) {
              setState(() {
                _selectedQuantity = value.toInt();
              });
            },
            activeColor: Colors.purple,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickButton(1),
              _buildQuickButton(5),
              _buildQuickButton(10),
              _buildQuickButton(25),
              if (widget.maxQuantity > 25) _buildQuickButton(widget.maxQuantity),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onQuantitySelected(_selectedQuantity);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: const Text('Adicionar'),
        ),
      ],
    );
  }

  Widget _buildQuickButton(int quantity) {
    if (quantity > widget.maxQuantity) return const SizedBox.shrink();
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedQuantity = quantity;
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: _selectedQuantity == quantity
            ? Colors.purple.withAlpha(100)
            : Colors.grey.withAlpha(30),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        quantity.toString(),
        style: TextStyle(
          color: _selectedQuantity == quantity ? Colors.white : Colors.grey,
          fontWeight: _selectedQuantity == quantity
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    );
  }
}

