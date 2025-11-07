import 'package:flutter/material.dart';

class DeadPlayerTile extends StatelessWidget {
  const DeadPlayerTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade800.withValues(alpha: .7),
      child: const Center(
        child: Text(
          'DEAD',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
