// lib/ui/life_counter_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/life_bloc.dart';

class LifeCounterPage extends StatefulWidget {
  final int playerCount;
  const LifeCounterPage({super.key, required this.playerCount});

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
  int _damageAmount = 1;

  @override
  void initState() {
    super.initState();
    _tileKeys.addAll(List.generate(widget.playerCount, (_) => GlobalKey()));
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
    setState(() {
      _dragStart = touchGlobal; // start at touch point
      _dragCurrent = touchGlobal;
      _isDragging = true;
      _damageTargetIndex = null;
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
      // remove target != source check
      setState(() {
        _damageTargetIndex = target;
        _damageAmount = 1;
      });
    }
  }

  void _cancelDamage() => setState(() => _damageTargetIndex = null);

  void _applyDamage(LifeBloc bloc) {
    if (_damageTargetIndex == null) return;
    final target = _damageTargetIndex!;
    bloc.add(UpdateLife(target, -_damageAmount));
    setState(() => _damageTargetIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.playerCount;
    return BlocProvider(
      create: (_) => LifeBloc(playerCount: count),
      child: Builder(
        builder: (context) {
          final bloc = context.read<LifeBloc>();
          return BlocBuilder<LifeBloc, List<int>>(
            builder: (context, lives) {
              final columns = count <= 2 ? 1 : 2;
              final rows = (count / columns).ceil();
              return Scaffold(
                body: Stack(
                  children: [
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        childAspectRatio:
                            MediaQuery.of(context).size.width /
                            MediaQuery.of(context).size.height *
                            columns /
                            rows,
                      ),
                      itemCount: count,
                      itemBuilder: (context, i) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanStart: (details) {
                            if (_damageTargetIndex == i) {
                              return; // block new drag
                            }
                            _startDrag(i, details.globalPosition);
                          },
                          onPanUpdate: (d) => _updateDrag(d.globalPosition),
                          onPanEnd: (_) {
                            if (_dragCurrent != null) _endDrag(_dragCurrent!);
                          },
                          child: Container(
                            key: _tileKeys[i],
                            margin: const EdgeInsets.all(2),
                            color: _playerColors[i % _playerColors.length],
                            child: PlayerTile(
                              index: i,
                              life: lives[i],
                              isDamageMode: _damageTargetIndex == i,
                              damageAmount: _damageAmount,
                              onAdjustDamage: (d) =>
                                  setState(() => _damageAmount += d),
                              onCancel: _cancelDamage,
                              onDone: () => _applyDamage(bloc),
                              onLocalAdjust: (d) => bloc.add(UpdateLife(i, d)),
                            ),
                          ),
                        );
                      },
                    ),

                    if (_isDragging &&
                        _dragStart != null &&
                        _dragCurrent != null)
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PlayerTile extends StatelessWidget {
  final int index;
  final int life;
  final bool isDamageMode;
  final int damageAmount;
  final void Function(int delta) onLocalAdjust;
  final void Function(int delta)? onAdjustDamage;
  final VoidCallback? onCancel;
  final VoidCallback? onDone;

  const PlayerTile({
    super.key,
    required this.index,
    required this.life,
    required this.isDamageMode,
    required this.damageAmount,
    required this.onLocalAdjust,
    this.onAdjustDamage,
    this.onCancel,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isDamageMode
          ? Column(
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
                    TextButton(
                      onPressed: onCancel,
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: onDone,
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Player ${index + 1}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$life',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
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
      ..color = Colors.black
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
    canvas.drawPath(arrow, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter old) =>
      old.start != start || old.end != end || old.curveUp != curveUp;
}
