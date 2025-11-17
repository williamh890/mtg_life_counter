import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/life_counter/blocs/postgame_bloc.dart';
import 'package:mtg_life_counter/life_counter/models/player.dart';
import 'package:mtg_life_counter/life_counter/models/player_rating.dart';

class RatingTile extends StatelessWidget {
  final Player player;
  final PlayerRating rating;

  const RatingTile({super.key, required this.player, required this.rating});

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
