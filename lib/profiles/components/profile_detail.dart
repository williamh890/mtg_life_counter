import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/profiles/blocs/profiles_bloc.dart';
// Import the dialog helper function
import 'add_deck_dialog.dart';

class ProfileDetail extends StatelessWidget {
  // Renamed to ProfileDetail
  final int profileId;

  const ProfileDetail({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    // ... (Scaffold, AppBar, BlocBuilder remains the same)
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
              // Profile Header
              // ... (Container and content remain the same)
              Container(
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
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.username,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${profile.decks.length} ${profile.decks.length == 1 ? 'Deck' : 'Decks'}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              // Decks Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Decks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      // CALL THE EXTERNAL HELPER
                      onPressed: () => showAddDeckDialog(context, profileId),
                      tooltip: 'Add Deck',
                    ),
                  ],
                ),
              ),
              // Decks List
              Expanded(
                child: profile.decks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.style,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No decks yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  showAddDeckDialog(context, profileId),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Deck'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: profile.decks.length,
                        itemBuilder: (context, index) {
                          final deck = profile.decks[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.style, size: 40),
                              title: Text(
                                deck.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                'Commander: ${deck.commander}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  context.read<ProfilesBloc>().add(
                                    RemoveDeck(profileId, deck.id),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
