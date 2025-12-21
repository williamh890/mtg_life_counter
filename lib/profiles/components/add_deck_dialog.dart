import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/profiles/blocs/profiles_bloc.dart';
import 'package:mtg_life_counter/profiles/models/card_info.dart';
import 'package:mtg_life_counter/profiles/models/deck.dart';
import 'package:mtg_life_counter/profiles/services/scryfall_service.dart';
import 'dart:async';

import 'package:mtg_life_counter/services/image_store.dart';

// --- Debouncer Utility ---
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
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
  final _debouncer = Debouncer(milliseconds: 600);

  List<CardInfo> _searchResults = [];
  CardInfo? _selectedCommander;
  bool _isSearching = false;

  @override
  void dispose() {
    _nameController.dispose();
    _commanderController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final results = await searchCards(query);
    if (!mounted) return;

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
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

    // Clear selection if user modifies the text
    if (_selectedCommander != null && query != _selectedCommander!.name) {
      setState(() => _selectedCommander = null);
    }

    setState(() => _isSearching = true);
    _debouncer.run(() => _performSearch(query));
  }

  void _selectCard(CardInfo card) {
    setState(() {
      _selectedCommander = card;
      _searchResults = [];
      _commanderController.text = card.name;
      _commanderController.selection = TextSelection.fromPosition(
        TextPosition(offset: card.name.length),
      );
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedCommander = null;
      _commanderController.clear();
    });
  }

  Future<void> _submitDeck() async {
    if (_selectedCommander == null) return;

    final name = _nameController.text.trim().isEmpty
        ? _selectedCommander!.name
        : _nameController.text.trim();

    final localCommander = await _persistDeckImages(_selectedCommander!);

    final deck = Deck.create(name, localCommander);

    if (!mounted) return;
    context.read<ProfilesBloc>().add(AddDeck(widget.profileId, deck));

    Navigator.of(context).pop();
  }

  Future<CardInfo> _persistDeckImages(CardInfo commander) async {
    final safe = commander.name
        .replaceAll(RegExp(r'[^\w]+'), '_')
        .toLowerCase();

    final art = await ImageStore.ensureLocal(
      commander.art,
      namespace: 'deck_images',
      filename: '${safe}_art.jpg',
    );

    final card = await ImageStore.ensureLocal(
      commander.card,
      namespace: 'deck_images',
      filename: '${safe}_card.jpg',
    );

    return CardInfo(
      name: commander.name,
      manaCost: commander.manaCost,
      typeLine: commander.typeLine,
      art: art,
      card: card,
    );
  }

  bool get _canSubmit => _commanderController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Deck'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDeckNameField(),
              const SizedBox(height: 16),
              _buildCommanderSearchField(),
              _buildSearchResults(),
              _buildSelectedCommanderPreview(),
              _buildNoResultsMessage(),
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
          onPressed: _canSubmit ? _submitDeck : null,
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildDeckNameField() {
    return TextField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Deck Name',
        hintText: 'Defaults to Commander Name',
        prefixIcon: Icon(Icons.style),
      ),
      autofocus: true,
    );
  }

  Widget _buildCommanderSearchField() {
    return TextField(
      controller: _commanderController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        labelText: 'Commander (Required)',
        hintText: 'Search for a commander...',
        prefixIcon: const Icon(Icons.person_search),
        suffixIcon: _isSearching ? _buildLoadingIndicator() : null,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(12.0),
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty || _selectedCommander != null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: _CardGrid(cards: _searchResults, onCardSelected: _selectCard),
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
    );
  }

  Widget _buildSelectedCommanderPreview() {
    if (_selectedCommander == null) return const SizedBox.shrink();

    return _CommanderPreviewCard(
      commander: _selectedCommander!,
      onClear: _clearSelection,
    );
  }

  Widget _buildNoResultsMessage() {
    final shouldShow =
        !_isSearching &&
        _searchResults.isEmpty &&
        _selectedCommander == null &&
        _commanderController.text.isNotEmpty;

    if (!shouldShow) return const SizedBox.shrink();

    return const Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Text('No cards found.', style: TextStyle(color: Colors.red)),
    );
  }
}

// --- Card Grid Widget ---
class _CardGrid extends StatelessWidget {
  final List<CardInfo> cards;
  final ValueChanged<CardInfo> onCardSelected;

  const _CardGrid({required this.cards, required this.onCardSelected});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.70,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => _CardGridItem(
        card: cards[index],
        onTap: () => onCardSelected(cards[index]),
      ),
    );
  }
}

// --- Card Grid Item Widget ---
class _CardGridItem extends StatelessWidget {
  final CardInfo card;
  final VoidCallback onTap;

  const _CardGridItem({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: _buildCardImage(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            card.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCardImage() {
    if (card.card.isCached || card.card.url.isNotEmpty) {
      return Image(
        image: card.card.provider,
        fit: BoxFit.contain,
        width: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[200],
          width: double.infinity,
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }

    return Container(
      color: Colors.grey[200],
      width: double.infinity,
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}

// --- Commander Preview Card Widget ---
class _CommanderPreviewCard extends StatelessWidget {
  final CardInfo commander;
  final VoidCallback onClear;

  const _CommanderPreviewCard({required this.commander, required this.onClear});

  @override
  Widget build(BuildContext context) {
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
          _buildCommanderThumbnail(),
          const SizedBox(width: 12),
          Expanded(child: _buildCommanderInfo(context)),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }

  Widget _buildCommanderThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image(
        image: commander.card.provider,
        width: 60,
        height: 84,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60),
      ),
    );
  }

  Widget _buildCommanderInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Commander Selected:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          commander.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(commander.typeLine, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// --- Helper Function ---
void showAddDeckDialog(BuildContext context, int profileId) {
  showDialog(
    context: context,
    builder: (_) => AddDeckDialog(profileId: profileId),
  );
}
