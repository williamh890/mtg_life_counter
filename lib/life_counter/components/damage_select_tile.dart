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

              SegmentedButton<int>(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
                showSelectedIcon: false,
                segments: [
                  ButtonSegment<int>(value: 0, label: Text('Commander')),
                ],
                emptySelectionAllowed: true,
                selected: _isCommanderDamage ? {0} : {},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _isCommanderDamage = !_isCommanderDamage;
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
                onPressed: _applyDamage,
                child: const Text('Done'),
              ),
            ],
          ),
        ],
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
