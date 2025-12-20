import 'package:flutter/material.dart';
import '../models/GameAccountEntry.dart';

class GameAccountDetailScreen extends StatelessWidget {
  final GameAccountEntry account;

  const GameAccountDetailScreen(this.account);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Game: ${account.gameName}'),
            const SizedBox(height: 8),
            Text('In-game name: ${account.ingameName}'),
            const SizedBox(height: 8),
            Text('Active: ${account.active}'),
          ],
        ),
      ),
    );
  }
}
