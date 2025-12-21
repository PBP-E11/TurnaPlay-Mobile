import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turnaplay_mobile/widgets/base_screen.dart';
import 'package:turnaplay_mobile/modules/tournaments/screens/creationForm.dart';
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

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.of(context, rootNavigator: true).pushReplacementNamed('/home');
    } else if (index == 1) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (context) => const TournamentCreationForm()),
      );
    } else if (index == 2) {
      Navigator.of(context, rootNavigator: true).pushReplacementNamed('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameAccountController>();

    if (controller.gamesLoading) {
      return BaseScreen(
        initialIndex: 2,
        onTap: _onItemTapped,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.games.isEmpty) {
      return BaseScreen(
         initialIndex: 2,
        onTap: _onItemTapped,
        body: const Center(child: Text('No games available')),
      );
    }

    return BaseScreen(
      initialIndex: 2,
      onTap: _onItemTapped,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Add Game Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedGameId,
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
          ],
        ),
      ),
    );
  }
}