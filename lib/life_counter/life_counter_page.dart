// lib/ui/life_counter_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/life_counter/blocs/postgame_bloc.dart';
import 'package:mtg_life_counter/life_counter/components/damage_select_tile.dart';
import 'package:mtg_life_counter/life_counter/components/dead_player_tile.dart';
import 'package:mtg_life_counter/life_counter/components/game_overview_tile.dart';
import 'package:mtg_life_counter/life_counter/components/rating_tile.dart';
import 'package:mtg_life_counter/life_counter/components/select_winner_tile.dart';
import 'package:mtg_life_counter/life_counter/models/player.dart';
import 'package:mtg_life_counter/life_counter/models/postgame_phase.dart';
import 'blocs/players_bloc.dart';
import 'components/player_tile.dart';

class LifeCounterPage extends StatefulWidget {
  const LifeCounterPage({super.key});

  @override
  State<LifeCounterPage> createState() => _LifeCounterPageState();
}

class _LifeCounterPageState extends State<LifeCounterPage> {
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

  int _getPlayerQuarterTurns(List<int> row, int index) {
    if (row.length == 1) {
      return -1;
    }

    final isLeftTile = row.indexOf(index) == 0;
    if (isLeftTile) {
      return 2;
    } else {
      return -0;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MultiBlocListener(
      listeners: [
        BlocListener<PlayersBloc, PlayersState>(
          listenWhen: (previous, current) {
            if (current.eventHistory.isEmpty) return false;
            return current.eventHistory.last is PassTurn;
          },
          listener: (context, state) {
            _cancelDamage();
          },
        ),
        BlocListener<PlayersBloc, PlayersState>(
          listenWhen: (previous, current) {
            return !previous.isGameFinished && current.isGameFinished;
          },
          listener: (context, state) {
            context.read<PostGameBloc>().add(InitializePostGame(state));
          },
        ),
        BlocListener<PostGameBloc, PostGameState>(
          listenWhen: (previous, current) {
            return previous.phase != PostGamePhase.notStarted &&
                current.phase == PostGamePhase.notStarted;
          },
          listener: (_, state) {
            context.read<PlayersBloc>().add(UndoAction());
          },
        ),
        BlocListener<PostGameBloc, PostGameState>(
          listenWhen: (previous, current) {
            return current.phase == PostGamePhase.completed;
          },
          listener: (context, _) {
            Navigator.pop(context);
          },
        ),
      ],
      child: BlocBuilder<PlayersBloc, PlayersState>(
        builder: (context, state) {
          final players = state.players;
          final playerIds = players.keys.toList();
          final columns = _getLayoutColumns(playerIds);

          return Stack(
            children: [
              Scaffold(
                body: SafeArea(
                  child: SizedBox.expand(
                    child: Row(
                      children: columns.map((column) {
                        return Flexible(
                          flex: column.length + columns.length,
                          child: Column(
                            children: column.map((playerId) {
                              final player = players[playerId]!;
                              return _buildPlayerTile(
                                column,
                                playerId,
                                player,
                                state,
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                floatingActionButton: _getActionButtons(context, state),
              ),
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
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Widget? _getActionButtons(BuildContext context, PlayersState state) {
    if (!state.isGameFinished && !state.allPlayersAreDead) {
      return null;
    }

    if (state.isGameFinished) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'cancel',
            onPressed: () {
              context.read<PostGameBloc>().add(PreviousPostGameStep());
            },
            backgroundColor: Colors.red,
            child: Icon(Icons.close),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'done',
            onPressed: () {
              // Handle done
              context.read<PostGameBloc>().add(NextPostgameStep());
            },
            child: Icon(Icons.check),
          ),
        ],
      );
    }

    if (state.allPlayersAreDead) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'cancel',
            onPressed: () {
              context.read<PlayersBloc>().add(UndoAction());
            },
            backgroundColor: Colors.white,
            child: Icon(Icons.undo),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'done',
            onPressed: () {
              context.read<PlayersBloc>().add(FinishGame());
            },
            child: Icon(Icons.check),
          ),
        ],
      );
    }

    return null;
  }

  List<List<int>> _getLayoutColumns(List<int> playerIds) {
    List<List<int>> columns = [];
    List<int> column = [];
    final len = playerIds.length;

    for (var r = 0; 2 * r < len; r++) {
      if ((r + 1) * 2 <= len) {
        column.add(r);
      }
      column.add(len - r - 1);

      columns.add(column);
      column = [];
    }

    return columns;
  }

  Widget _buildPlayerTile(
    List<int> column,
    int playerId,
    Player player,
    PlayersState state,
  ) {
    final playerTile = Container(
      key: _tileKeys[playerId],
      margin: EdgeInsets.zero,
      color: player.getColor(),
      child: SizedBox.expand(
        child: RotatedBox(
          quarterTurns: _getPlayerQuarterTurns(column, playerId),
          child: Stack(
            children: [
              _getPlayerGameTile(player, playerId, state.turnPlayerId),
              if (state.isGameFinished) _getPlayerPostGameTile(player),
            ],
          ),
        ),
      ),
    );

    return Expanded(
      child: state.isGameFinished
          ? playerTile
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (d) => _startDrag(playerId, d.globalPosition),
              onPanUpdate: (d) => _updateDrag(d.globalPosition),
              onPanEnd: (_) {
                if (_dragCurrent != null) _endDrag(_dragCurrent!);
              },
              child: playerTile,
            ),
    );
  }

  Widget _getPlayerGameTile(Player player, int index, int turnPlayerId) {
    final isDamageMode = _damageTargetIndex == index;

    if (player.isDead()) {
      return DeadPlayerTile();
    } else if (isDamageMode) {
      return DamageSelectTile(
        targetId: _damageTargetIndex,
        sourceId: _damageSourceIndex,
        onCancel: _cancelDamage,
        onDone: _applyDamage,
      );
    } else {
      return PlayerTile(player: player, isPlayersTurn: turnPlayerId == index);
    }
  }

  Widget _getPlayerPostGameTile(Player player) {
    return BlocBuilder<PostGameBloc, PostGameState>(
      builder: (context, state) {
        return switch (state.phase) {
          PostGamePhase.notStarted => Text('Not started'),
          PostGamePhase.winners => SelectWinnerTile(
            player: player,
            isWinner: state.isWinner(player.id),
          ),
          PostGamePhase.rating => RatingTile(
            player: player,
            rating: state.ratings[player.id]!,
          ),
          PostGamePhase.overview => GameOverviewTile(player: player),
          PostGamePhase.completed => Text('Game over!'),
        };
      },
    );
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
