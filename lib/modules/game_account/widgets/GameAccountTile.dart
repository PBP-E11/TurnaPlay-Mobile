import 'package:flutter/material.dart';
import '../models/GameAccountEntry.dart';

class GameAccountTile extends StatelessWidget {
  final GameAccountEntry account;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const GameAccountTile({
    required this.account,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(account.ingameName),
        subtitle: Text(account.gameName),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
