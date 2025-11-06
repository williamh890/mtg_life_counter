// lib/ui/life_counter_page.dart
import 'package:flutter/material.dart';
import '../blocs/life_bloc.dart';

class PlayerTile extends StatefulWidget {
  final Player player;
  final bool isDamageMode;
  final int damageAmount;

  final void Function(int delta) onAdjustDamage;
  final VoidCallback onCancel;
  final void Function(DamageMode) onDone;

  const PlayerTile({
    super.key,
    required this.player,
    required this.isDamageMode,
    required this.damageAmount,
    required this.onAdjustDamage,
    required this.onCancel,
    required this.onDone,
  });

  @override
  State<PlayerTile> createState() => _PlayerTileState();
}

class _PlayerTileState extends State<PlayerTile> {
  DamageMode _selectedDamageMode = DamageMode.damage;

  @override
  Widget build(BuildContext context) {
    if (widget.player.isDead) {
      return Container(
        color: Colors.grey.shade800.withValues(alpha: .7),
        child: const Center(
          child: Text(
            'DEAD',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
        ),
      );
    } else if (widget.isDamageMode) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SegmentedButton<DamageMode>(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                  showSelectedIcon: false,
                  segments: DamageMode.values.map((damageMode) {
                    return ButtonSegment<DamageMode>(
                      value: damageMode,
                      label: Text(damageMode.label),
                    );
                  }).toList(),
                  selected: {_selectedDamageMode},
                  onSelectionChanged: (Set<DamageMode> newSelection) {
                    setState(() {
                      _selectedDamageMode = newSelection.first;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Select Damage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => widget.onAdjustDamage.call(-1),
                ),
                Text(
                  '${widget.damageAmount}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => widget.onAdjustDamage.call(1),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => widget.onDone(_selectedDamageMode),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.player.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.player.life}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
  }
}
