// lib/ui/life_counter_page.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/players_bloc.dart';

class PlayerTile extends StatefulWidget {
  final Player player;
  final int? targetId;
  final bool isDamageMode;

  final void Function(int delta) onAdjustDamage;
  final VoidCallback onCancel;
  final void Function(DamageMode) onDone;

  const PlayerTile({
    super.key,
    required this.player,
    this.targetId,
    required this.isDamageMode,
    required this.onAdjustDamage,
    required this.onCancel,
    required this.onDone,
  });

  @override
  State<PlayerTile> createState() => _PlayerTileState();
}

class _PlayerTileState extends State<PlayerTile> {
  DamageMode _selectedDamageMode = DamageMode.damage;
  int _damageAmount = 0;

  void _increaseDamage() {
    setState(() {
      _damageAmount += 1;
    });
  }

  void _decreaseDamage() {
    setState(() {
      _damageAmount = math.max(0, _damageAmount - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayersBloc>();

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
                  onPressed: () => _decreaseDamage(),
                ),
                Text(
                  '$_damageAmount',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _increaseDamage(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _damageAmount = 0;
                      _selectedDamageMode = DamageMode.damage;
                    });
                    widget.onCancel();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (widget.targetId == null) {
                      return;
                    }
                    final target = widget.targetId!;

                    PlayerEvent event;
                    if (_selectedDamageMode == DamageMode.damage) {
                      event = DamagePlayer(target, _damageAmount);
                    } else if (_selectedDamageMode == DamageMode.healing) {
                      event = HealPlayer(target, _damageAmount);
                    } else {
                      event = DamagePlayer(target, _damageAmount);
                    }

                    bloc.add(event);
                    setState(() {
                      _damageAmount = 0;
                      _selectedDamageMode = DamageMode.damage;
                    });
                    widget.onDone(_selectedDamageMode);
                  },
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
