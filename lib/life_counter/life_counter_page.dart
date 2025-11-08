// lib/ui/life_counter_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/life_counter/components/damage_select_tile.dart';
import 'package:mtg_life_counter/life_counter/components/dead_player_tile.dart';
import 'blocs/players_bloc.dart';
import 'components/player_tile.dart';

class LifeCounterPage extends StatefulWidget {
  const LifeCounterPage({super.key});

  @override
  State<LifeCounterPage> createState() => _LifeCounterPageState();
}

class _LifeCounterPageState extends State<LifeCounterPage> {
  static const List<Color> _playerColors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.yellowAccent,
    Colors.cyanAccent,
    Colors.pinkAccent,
  ];

  final List<GlobalKey> _tileKeys = [];
  Offset? _dragStart;
  Offset? _dragCurrent;
  bool _isDragging = false;

  int? _damageTargetIndex;
  int? _damageSourceIndex;

  @override
  void initState() {
    super.initState();
    final playersBloc = context.read<PlayersBloc>();
    final playerCount = playersBloc.state.players.length;

    _tileKeys.addAll(List.generate(playerCount, (_) => GlobalKey()));
  }

  Rect? _getTileRect(int index) {
    final ctx = _tileKeys[index].currentContext;
    if (ctx == null) return null;
    final render = ctx.findRenderObject();
    if (render is RenderBox) {
      final pos = render.localToGlobal(Offset.zero);
      return pos & render.size;
    }
    return null;
  }

  int? _findTileAt(Offset pos) {
    for (var i = 0; i < _tileKeys.length; i++) {
      final rect = _getTileRect(i);
      if (rect != null && rect.contains(pos)) return i;
    }
    return null;
  }

  void _startDrag(int source, Offset touchGlobal) {
    if (_damageTargetIndex == source) return; // disable while in damage mode
    setState(() {
      _dragStart = touchGlobal;
      _dragCurrent = touchGlobal;
      _isDragging = true;
      _damageTargetIndex = null;
      _damageSourceIndex = source;
    });
  }

  void _updateDrag(Offset pos) {
    if (!_isDragging) return;
    setState(() => _dragCurrent = pos);
  }

  void _endDrag(Offset pos) {
    if (!_isDragging) return;
    final target = _findTileAt(pos);
    setState(() {
      _isDragging = false;
      _dragCurrent = null;
      _dragStart = null;
    });

    if (target != null) {
      setState(() {
        _damageTargetIndex = target;
      });
    }
  }

  double _getPlayerRotateAngle(List<int> row, int index) {
    if (row.length == 1) {
      return 0;
    }

    final isLeftTile = row.indexOf(index) == 0;
    if (isLeftTile) {
      return pi / 2;
    } else {
      return -pi / 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayersBloc>();
    return BlocBuilder<PlayersBloc, PlayersState>(
      builder: (context, state) {
        final players = state.players;
        return Scaffold(
          backgroundColor: Colors.black,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final spacing = 4.0;
              final tiles = <Widget>[];

              // compute row structure
              List<List<int>> rows = [];
              int remaining = players.length;
              int current = 0;
              while (remaining > 0) {
                if (remaining == 1) {
                  rows.add([current]);
                  remaining -= 1;
                  current += 1;
                } else if (remaining == 3 || remaining == 5 || remaining == 7) {
                  rows.add([current, current + 1]);
                  remaining -= 2;
                  current += 2;
                } else {
                  rows.add([current, current + 1]);
                  remaining -= 2;
                  current += 2;
                }
              }

              final rowCount = rows.length;
              final rowHeight =
                  (constraints.maxHeight - spacing * (rowCount + 1)) / rowCount;

              double y = spacing;
              for (var row in rows) {
                final countInRow = row.length;
                final width =
                    (constraints.maxWidth - spacing * (countInRow + 1)) /
                    countInRow;
                double x = spacing;
                for (var index in row) {
                  Player player = players[index]!;
                  tiles.add(
                    Positioned(
                      left: x,
                      top: y,
                      width: width,
                      height: rowHeight,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: (d) => _startDrag(index, d.globalPosition),
                        onPanUpdate: (d) => _updateDrag(d.globalPosition),
                        onPanEnd: (_) {
                          if (_dragCurrent != null) {
                            _endDrag(_dragCurrent!);
                          }
                        },
                        child: Container(
                          key: _tileKeys[index],
                          margin: EdgeInsets.zero,
                          color: _playerColors[index % _playerColors.length],
                          child: Transform.rotate(
                            angle: _getPlayerRotateAngle(row, index),
                            child: _getPlayerTile(player, index, bloc),
                          ),
                        ),
                      ),
                    ),
                  );
                  x += width + spacing;
                }
                y += rowHeight + spacing;
              }

              return Stack(
                children: [
                  ...tiles,
                  if (_isDragging && _dragStart != null && _dragCurrent != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _ArrowPainter(
                            start: _dragStart!,
                            end: _dragCurrent!,
                            curveUp: true,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _getPlayerTile(Player player, int index, PlayersBloc bloc) {
    final isDamageMode = _damageTargetIndex == index;

    if (player.isDead) {
      return DeadPlayerTile();
    } else if (isDamageMode) {
      return DamageSelectTile(
        targetId: _damageTargetIndex,
        sourceId: _damageSourceIndex,
        onCancel: _cancelDamage,
        onDone: _applyDamage,
      );
    } else {
      return PlayerTile(player: player);
    }
  }

  void _cancelDamage() => setState(() {
    _damageTargetIndex = null;
    _damageSourceIndex = null;
  });

  void _applyDamage() {
    setState(() {
      _damageTargetIndex = null;
      _damageSourceIndex = null;
    });
  }
}

class _ArrowPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final bool curveUp;
  const _ArrowPainter({
    required this.start,
    required this.end,
    required this.curveUp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final delta = end - start;
    if (delta.distance < 4) {
      canvas.drawLine(start, end, paint);
      return;
    }

    final mid = (start + end) / 2;
    final perp = Offset(-delta.dy, delta.dx);
    final curvature = min(150.0, delta.distance / 2 + 20.0);
    final dir = curveUp ? -1.0 : 1.0;
    final ctrl = mid + (perp / perp.distance) * curvature * dir;

    final path = Path()..moveTo(start.dx, start.dy);
    path.quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);

    // arrowhead
    final tangent = (end - ctrl);
    final tangentNorm =
        tangent / (tangent.distance == 0 ? 1.0 : tangent.distance);
    const arrowSize = 12.0;
    final perpT = Offset(-tangentNorm.dy, tangentNorm.dx);
    final p1 = end - tangentNorm * arrowSize + perpT * (arrowSize / 2);
    final p2 = end - tangentNorm * arrowSize - perpT * (arrowSize / 2);
    final arrow = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(arrow, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter old) =>
      old.start != start || old.end != end || old.curveUp != curveUp;
}
