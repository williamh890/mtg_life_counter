import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/life_counter/blocs/postgame_bloc.dart';
import 'package:mtg_life_counter/life_counter/models/player.dart';
import 'package:mtg_life_counter/life_counter/models/player_rating.dart';

class RatingTile extends StatelessWidget {
  final Player player;
  final List<Player> otherPlayers;
  final PlayerRating rating;

  const RatingTile({
    super.key,
    required this.player,
    required this.otherPlayers,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PostGameBloc>();

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Happiness Rating
          const Text(
            'How was your experience?',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: GameRating.values.map((gameRating) {
              return _buildEmojiButton(
                gameRating: gameRating,
                isSelected: rating.gameRating == gameRating,
                onTap: () => _updateRating(bloc, gameRating),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Saltiness Rating
          const Text(
            'Saltiness level',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final value = index + 1;
              return _buildSaltButton(
                value: value,
                selectedValue: rating.saltiness,
                onTap: () => _updateSaltiness(bloc, value),
              );
            }),
          ),

          const SizedBox(height: 24),

          // Commend and Cringe Dropdowns Side by Side
          Row(
            children: [
              Expanded(
                child: _buildPlayerDropdown(
                  context: context,
                  bloc: bloc,
                  label: 'Commend',
                  icon: Icons.thumb_up,
                  iconColor: Colors.green,
                  selectedPlayerId: rating.commendedPlayerId,
                  excludedPlayerId: rating.cringePlayerId,
                  onChanged: (playerId) =>
                      bloc.add(SetCommendedPlayer(player.id, playerId)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPlayerDropdown(
                  context: context,
                  bloc: bloc,
                  label: 'Cringe',
                  icon: Icons.thumb_down,
                  iconColor: Colors.orange,
                  selectedPlayerId: rating.cringePlayerId,
                  excludedPlayerId: rating.commendedPlayerId,
                  onChanged: (playerId) =>
                      bloc.add(SetCringePlayer(player.id, playerId)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerDropdown({
    required BuildContext context,
    required PostGameBloc bloc,
    required String label,
    required IconData icon,
    required Color iconColor,
    required int? selectedPlayerId,
    required int? excludedPlayerId,
    required Function(int?) onChanged,
  }) {
    // Filter out the excluded player
    final availablePlayers = otherPlayers
        .where((p) => excludedPlayerId == null || p.id != excludedPlayerId)
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                isExpanded: true,
                hint: Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                value: selectedPlayerId,
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  ...availablePlayers.map((otherPlayer) {
                    return DropdownMenuItem<int?>(
                      value: otherPlayer.id,
                      child: Text(
                        otherPlayer.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateRating(PostGameBloc bloc, GameRating gameRating) {
    bloc.add(SetRating(player.id, gameRating));
  }

  void _updateSaltiness(PostGameBloc bloc, int salt) {
    bloc.add(SetSaltiness(player.id, salt));
  }

  Widget _buildEmojiButton({
    required GameRating gameRating,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? gameRating.color.withValues(alpha: 0.2)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? gameRating.color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              gameRating.icon,
              size: 32,
              color: isSelected ? gameRating.color : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            gameRating.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? gameRating.color : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaltButton({
    required int value,
    required int? selectedValue,
    required VoidCallback onTap,
  }) {
    final isFilled = selectedValue != null && value <= selectedValue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isFilled ? Colors.blue.shade100 : Colors.grey.shade100,
          shape: BoxShape.circle,
          border: Border.all(
            color: isFilled ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.water_drop,
            size: 24,
            color: isFilled ? Colors.blue : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
