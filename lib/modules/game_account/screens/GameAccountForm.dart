import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turnaplay_mobile/modules/tournaments/models/GameEntry.dart';
import '../models/GameAccountController.dart';

class GameAccountFormScreen extends StatefulWidget {
  @override
  State<GameAccountFormScreen> createState() => _GameAccountFormScreenState();
}

class _GameAccountFormScreenState extends State<GameAccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ingameNameController = TextEditingController();

  String? _selectedGameId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameAccountController>().loadGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameAccountController>();

    if (controller.gamesLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (controller.games.isEmpty) {
      return const Center(child: Text('No games available'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Game Account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedGameId,
                items: controller.games
                    .map(
                      (g) => DropdownMenuItem(value: g.id, child: Text(g.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedGameId = v),
                decoration: const InputDecoration(labelText: 'Game'),
                validator: (v) => v == null ? 'Please select a game' : null,
              ),
              TextFormField(
                controller: _ingameNameController,
                decoration: const InputDecoration(labelText: 'In-game name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  await controller.addAccount(
                    _selectedGameId!,
                    _ingameNameController.text,
                  );

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF494598),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
