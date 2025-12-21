import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/profiles/blocs/profiles_bloc.dart';
import 'add_deck_dialog.dart';

class ProfileDetail extends StatelessWidget {
  final int profileId;

  const ProfileDetail({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Detail')),
      body: BlocBuilder<ProfilesBloc, ProfilesState>(
        builder: (context, state) {
          final profile = state.getProfile(profileId);

          if (profile == null) {
            return const Center(child: Text('Profile not found'));
          }

          return Column(
            children: [
              _buildProfileHeader(context, profile),
              _buildDecksHeader(context),
              _buildDecksList(context, profile),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            child: Text(
              profile.username[0].toUpperCase(),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.username,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${profile.decks.length} ${profile.decks.length == 1 ? 'Deck' : 'Decks'}',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildDecksHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Decks',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showAddDeckDialog(context, profileId),
            tooltip: 'Add Deck',
          ),
        ],
      ),
    );
  }

  Widget _buildDecksList(BuildContext context, dynamic profile) {
    return Expanded(
      child: profile.decks.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              itemCount: profile.decks.length,
              itemBuilder: (context, index) {
                final deck = profile.decks[index];
                return _DeckCard(deck: deck, profileId: profileId);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.style, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No decks yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => showAddDeckDialog(context, profileId),
            icon: const Icon(Icons.add),
            label: const Text('Add Deck'),
          ),
        ],
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  final dynamic deck;
  final int profileId;

  // Commander art dimensions - change this to resize the image everywhere
  static const double _imageWidth = 160.0;
  static const double _aspectRatio = 626 / 457; // Original aspect ratio
  static double get _imageHeight => _imageWidth / _aspectRatio;

  const _DeckCard({required this.deck, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCommanderArt(),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    deck.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Commander: ${deck.commander.name}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deck.commander.typeLine,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                context.read<ProfilesBloc>().add(
                  RemoveDeck(profileId, deck.id),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommanderArt() {
    final art = deck.commander.art;

    if (art.url.isEmpty) {
      return SizedBox(
        width: _imageWidth,
        height: _imageHeight,
        child: Icon(Icons.style, size: _imageWidth * 0.6),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image(
        image: art.provider,
        width: _imageWidth,
        height: _imageHeight,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: _imageWidth,
            height: _imageHeight,
            child: Icon(Icons.broken_image, size: _imageWidth * 0.6),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: _imageWidth,
            height: _imageHeight,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
