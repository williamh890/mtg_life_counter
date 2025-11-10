import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/life_counter/blocs/players_bloc.dart';

class DamageSelectTile extends StatefulWidget {
  final int? targetId;
  final int? sourceId;

  final VoidCallback onCancel;
  final VoidCallback onDone;

  const DamageSelectTile({
    super.key,
    this.targetId,
    this.sourceId,
    required this.onCancel,
    required this.onDone,
  });

  @override
  State<DamageSelectTile> createState() => _DamageSelectTileState();
}

class _DamageSelectTileState extends State<DamageSelectTile> {
  DamageMode _selectedDamageMode = DamageMode.damage;
  bool _isCommanderDamage = false;
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SegmentedButton<DamageMode>(
                  showSelectedIcon: false,
                  segments: DamageMode.values
                      .map(
                        (m) => ButtonSegment<DamageMode>(
                          value: m,
                          label: Text(m.label),
                        ),
                      )
                      .toList(),
                  selected: {_selectedDamageMode},
                  onSelectionChanged: (s) =>
                      setState(() => _selectedDamageMode = s.first),
                ),
                const SizedBox(width: 12),
                SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment<int>(value: 0, label: Text('Commander')),
                  ],
                  emptySelectionAllowed: true,
                  selected: _isCommanderDamage ? {0} : {},
                  onSelectionChanged: (_) =>
                      setState(() => _isCommanderDamage = !_isCommanderDamage),
                ),
              ],
            ),

            // Center area
            Expanded(
              child: Stack(
                children: [
                  Row(
                    children: [
                      // Left half (-)
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _decreaseDamage,
                            splashColor: Colors.white24,
                            highlightColor: Colors.white10,
                            child: const Center(
                              child: Icon(
                                Icons.remove,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Right half (+)
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _increaseDamage,
                            splashColor: Colors.white24,
                            highlightColor: Colors.white10,
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Center damage number
                  Center(
                    child: Text(
                      '$_damageAmount',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom buttons
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
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _applyDamage,
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _applyDamage() {
    final target = widget.targetId;
    final source = widget.sourceId;

    if (target == null) {
      return;
    }

    final event = switch (_selectedDamageMode) {
      DamageMode.damage => DamagePlayer(target, _damageAmount),
      DamageMode.healing => HealPlayer(target, _damageAmount),
      DamageMode.lifelink => LifelinkDamagePlayer(
        source!,
        target,
        _damageAmount,
      ),
    };

    final bloc = context.read<PlayersBloc>();
    bloc.add(event);

    if (_isCommanderDamage) {
      bloc.add(CommanderDamage(source!, target, _damageAmount));
    }

    setState(() {
      _damageAmount = 0;
      _selectedDamageMode = DamageMode.damage;
    });

    widget.onDone();
  }
}
