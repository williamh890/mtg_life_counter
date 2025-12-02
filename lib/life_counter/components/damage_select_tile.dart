import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/life_counter/blocs/players_bloc.dart';
import 'package:mtg_life_counter/life_counter/models/damage_mode.dart';
import 'package:mtg_life_counter/life_counter/models/target_select.dart';

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
  TargetSelect _targetSelectMode = TargetSelect.player;
  bool _isCommanderDamage = false;
  int _damageAmount = 0;
  Timer? _holdTimer;

  @override
  Widget build(BuildContext context) {
    final damageTypeSelectorRow = Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SegmentedButton<DamageMode>(
              showSelectedIcon: false,
              segments: DamageMode.values
                  .where((mode) {
                    if (_isCommanderDamage) {
                      return mode != DamageMode.infect &&
                          mode != DamageMode.healing;
                    }
                    return true;
                  })
                  .map(
                    (mode) => ButtonSegment<DamageMode>(
                      value: mode,
                      label: Text(_getDamageTypeLabel(mode, _targetSelectMode)),
                    ),
                  )
                  .toList(),
              selected: {_selectedDamageMode},
              onSelectionChanged: (s) =>
                  setState(() => _selectedDamageMode = s.first),
            ),
            if (_targetSelectMode == TargetSelect.player &&
                (_selectedDamageMode != DamageMode.infect &&
                    _selectedDamageMode != DamageMode.healing)) ...[
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
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SegmentedButton<TargetSelect>(
              showSelectedIcon: false,
              segments: TargetSelect.values
                  .where((mode) {
                    if (_isCommanderDamage ||
                        widget.targetId != widget.sourceId) {
                      return mode == TargetSelect.player;
                    }
                    return true;
                  })
                  .map(
                    (mode) => ButtonSegment<TargetSelect>(
                      value: mode,
                      label: Text(mode.label),
                    ),
                  )
                  .toList(),
              selected: <TargetSelect>{_targetSelectMode},
              onSelectionChanged: (s) =>
                  setState(() => _targetSelectMode = s.first),
            ),
          ],
        ),
      ],
    );

    final damageAdjustRow = Expanded(
      child: Stack(
        children: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.remove, size: 64, color: Colors.white),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '$_damageAmount',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(Icons.add, size: 64, color: Colors.white),
              ],
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left half (-)
              Expanded(
                flex: 1,
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onLongPressStart: (_) => _startDecreasing(),
                    onLongPressEnd: (_) => _stopHolding(),
                    child: InkWell(
                      onTap: _decreaseDamage,
                      splashColor: Colors.white24,
                      highlightColor: Colors.white10,
                      child: Container(), // Empty tap target
                    ),
                  ),
                ),
              ),
              // Right half (+)
              Expanded(
                flex: 1,
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onLongPressStart: (_) => _startIncreasing(),
                    onLongPressEnd: (_) => _stopHolding(),
                    child: InkWell(
                      onTap: _increaseDamage,
                      splashColor: Colors.white24,
                      highlightColor: Colors.white10,
                      child: Container(), // Empty tap target
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Centered content: - amount +
        ],
      ),
    );

    final confirmButtonsRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              setState(() {
                _damageAmount = 0;
                _selectedDamageMode = DamageMode.damage;
              });
              widget.onCancel();
            },
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _applyDamage,
            child: const Text('Done'),
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [damageTypeSelectorRow, damageAdjustRow, confirmButtonsRow],
      ),
    );
  }

  void _startIncreasing() {
    setState(() {
      // Round to nearest multiple of 5, then add 5
      _damageAmount = ((_damageAmount / 5).round() * 5) + 5;
    });
    _holdTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      _increaseDamage(5);
    });
  }

  void _startDecreasing() {
    setState(() {
      // Round to nearest multiple of 5, then subtract 5
      _damageAmount = ((_damageAmount / 5).round() * 5) - 5;
      _damageAmount = _damageAmount.clamp(0, double.infinity).toInt();
    });
    _holdTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      _decreaseDamage(5);
    });
  }

  void _stopHolding() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  void _increaseDamage([int amount = 1]) {
    setState(() {
      _damageAmount += amount;
    });
  }

  void _decreaseDamage([int amount = 1]) {
    setState(() {
      _damageAmount = (_damageAmount - amount)
          .clamp(0, double.infinity)
          .toInt();
    });
  }

  _applyDamage() {
    final target = widget.targetId;
    final source = widget.sourceId;

    if (target == null || source == null) {
      return;
    }

    if (_damageAmount == 0) {
      widget.onDone();
      return;
    }

    final eventMetadata = EventMetadata.now(sourcePlayerId: source);
    final event = switch ((_selectedDamageMode, _targetSelectMode)) {
      (DamageMode.damage, TargetSelect.player) => DamagePlayer(
        target,
        _damageAmount,
        metadata: eventMetadata,
      ),
      (DamageMode.damage, TargetSelect.players) => DamagePlayers(
        _damageAmount,
        metadata: eventMetadata,
      ),
      (DamageMode.damage, TargetSelect.opponents) => DamageOpponents(
        source,
        _damageAmount,
        metadata: eventMetadata,
      ),
      (DamageMode.healing, TargetSelect.player) => HealPlayer(
        target,
        _damageAmount,
        metadata: eventMetadata,
      ),
      (DamageMode.healing, TargetSelect.players) => HealPlayers(
        _damageAmount,
        metadata: eventMetadata,
      ),
      (DamageMode.healing, TargetSelect.opponents) => HealOpponents(
        source,
        _damageAmount,
        metadata: eventMetadata,
      ),
      (DamageMode.infect, TargetSelect.player) => InfectDamagePlayer(
        target,
        _damageAmount,
        metadata: eventMetadata,
      ),
      (DamageMode.infect, TargetSelect.players) => InfectDamagePlayers(
        _damageAmount,
        metadata: eventMetadata,
      ),
      (DamageMode.infect, TargetSelect.opponents) => InfectDamageOpponents(
        source,
        _damageAmount,
        metadata: eventMetadata,
      ),
      (DamageMode.lifelink, TargetSelect.player) => LifelinkDamagePlayer(
        source,
        target,
        _damageAmount,
        metadata: eventMetadata,
      ),
      (DamageMode.lifelink, _) => Extort(
        source,
        _damageAmount,
        metadata: eventMetadata,
      ),
    };

    final bloc = context.read<PlayersBloc>();
    bloc.add(event);

    if (_isCommanderDamage) {
      bloc.add(
        CommanderDamage(
          source,
          target,
          _damageAmount,
          metadata: EventMetadata.now(
            sourcePlayerId: source,
            isChildEvent: true,
          ),
        ),
      );
    }

    setState(() {
      _damageAmount = 0;
      _selectedDamageMode = DamageMode.damage;
      _targetSelectMode = TargetSelect.player;
    });

    widget.onDone();
  }

  String _getDamageTypeLabel(DamageMode damageMode, TargetSelect target) {
    if (damageMode == DamageMode.lifelink && target != TargetSelect.player) {
      return 'Extort';
    } else {
      return damageMode.label;
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }
}
