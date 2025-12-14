import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/profiles/blocs/profiles_bloc.dart';
import 'package:mtg_life_counter/profiles/services/scryfall_service.dart';
import 'dart:async';

// --- Debouncer Utility ---
class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

// --- AddDeckDialog Widget ---

class AddDeckDialog extends StatefulWidget {
  final int profileId;

  const AddDeckDialog({super.key, required this.profileId});

  @override
  State<AddDeckDialog> createState() => _AddDeckDialogState();
}

class _AddDeckDialogState extends State<AddDeckDialog> {
  final _nameController = TextEditingController();
  final _commanderController = TextEditingController();

  // State variables
  List<CardInfo> _searchResults = [];
  CardInfo? _selectedCommander;
  bool _isSearching = false;

  final _debouncer = Debouncer(milliseconds: 600);

  @override
  void dispose() {
    _nameController.dispose();
    _commanderController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _selectedCommander = null;
        _isSearching = false;
      });
      return;
    }

    if (_selectedCommander != null && query != _selectedCommander!.name) {
      setState(() {
        _selectedCommander = null;
      });
    }

    setState(() {
      _isSearching = true;
    });

    _debouncer.run(() async {
      final results = await searchCards(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  void _selectCard(CardInfo card) {
    setState(() {
      _selectedCommander = card;
      _searchResults = []; // Hide grid
      _commanderController.text = card.name;

      _commanderController.selection = TextSelection.fromPosition(
        TextPosition(offset: _commanderController.text.length),
      );
    });
  }

  void _submitDeck() {
    String name = _nameController.text.trim();
    final commander =
        _selectedCommander?.name ?? _commanderController.text.trim();

    // Ensure we have at least a commander
    if (commander.isNotEmpty) {
      // Auto-fill Logic: If name is empty, use the commander's name
      if (name.isEmpty) {
        name = commander;
      }

      context.read<ProfilesBloc>().add(
        AddDeck(widget.profileId, name, commander),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // UPDATED: Submit is allowed if we have a commander, even if name is empty
    final bool canSubmit = _commanderController.text.trim().isNotEmpty;

    return AlertDialog(
      title: const Text('Add Deck'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Deck Name',
                  hintText: 'Defaults to Commander Name', // Updated hint
                  prefixIcon: Icon(Icons.style),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _commanderController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  labelText: 'Commander (Required)', // Updated label
                  hintText: 'Search for a commander...',
                  prefixIcon: const Icon(Icons.person_search),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
              ),

              // --- GRID View for Search Results ---
              if (_searchResults.isNotEmpty && _selectedCommander == null) ...[
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          childAspectRatio: 0.70,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final card = _searchResults[index];
                      return GestureDetector(
                        onTap: () => _selectCard(card),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: card.imageUrl.isNotEmpty
                                    ? Image.network(
                                        card.imageUrl,
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                      )
                                    : Container(
                                        color: Colors.grey[200],
                                        width: double.infinity,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              card.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Tap a card to select it',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              // --- Selected Card Preview ---
              if (_selectedCommander != null)
                _buildCommanderPreview(_selectedCommander!),

              // --- No Results ---
              if (!_isSearching &&
                  _searchResults.isEmpty &&
                  _selectedCommander == null &&
                  _commanderController.text.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'No cards found.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: canSubmit ? _submitDeck : null,
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildCommanderPreview(CardInfo card) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: card.imageUrl.isNotEmpty
                ? Image.network(
                    card.imageUrl,
                    width: 60,
                    height: 84,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 60),
                  )
                : const Icon(Icons.image_not_supported, size: 60),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Commander Selected:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  card.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(card.typeLine, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () {
              setState(() {
                _selectedCommander = null;
                _commanderController.clear();
              });
            },
          ),
        ],
      ),
    );
  }
}

void showAddDeckDialog(BuildContext context, int profileId) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AddDeckDialog(profileId: profileId);
    },
  );
}
