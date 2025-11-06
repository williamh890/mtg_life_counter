// lib/ui/life_counter_page.dart
import 'package:flutter/material.dart';
import '../blocs/life_bloc.dart';

class PlayerTile extends StatelessWidget {
  final Player player;
  final bool isDamageMode;
  final int damageAmount;
  final void Function(int delta) onLocalAdjust;
  final void Function(int delta)? onAdjustDamage;
  final VoidCallback? onCancel;
  final VoidCallback? onDone;

  const PlayerTile({
    super.key,
    required this.player,
    required this.isDamageMode,
    required this.damageAmount,
    required this.onLocalAdjust,
    this.onAdjustDamage,
    this.onCancel,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    if (player.isDead) {
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
    } else if (isDamageMode) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  onPressed: () => onAdjustDamage?.call(-1),
                ),
                Text(
                  '$damageAmount',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => onAdjustDamage?.call(1),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: onCancel, child: const Text('Cancel')),
                ElevatedButton(onPressed: onDone, child: const Text('Done')),
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
              player.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$player.life',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
  }
}
