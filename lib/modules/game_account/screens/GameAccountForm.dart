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
  final Color primaryColor = const Color(0xFF494598);

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
        MaterialPageRoute(builder: (context) => const TournamentForm()),
      );
    } else if (index == 2) {
      Navigator.of(context, rootNavigator: true).pushReplacementNamed('/profile');
    }
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameAccountController>();

    return BaseScreen(
      initialIndex: 2,
      onTap: _onItemTapped,
      body: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Add Game Account',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: controller.gamesLoading
            ? Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
            : controller.games.isEmpty
                ? const Center(child: Text('No games available'))
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Game dropdown
                          _buildLabel('Game'),
                          DropdownButtonFormField<String>(
                            decoration:
                                _buildInputDecoration('Select a game'),
                            value: _selectedGameId,
                            icon:
                                const Icon(Icons.keyboard_arrow_down),
                            items: controller.games
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g.id,
                                    child: Text(g.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedGameId = v),
                            validator: (v) =>
                                v == null ? 'Please select a game' : null,
                          ),
                          const SizedBox(height: 16),

                          // In-game name
                          _buildLabel('In-game Username'),
                          TextFormField(
                            controller: _ingameNameController,
                            style:
                                const TextStyle(color: Colors.black),
                            decoration: _buildInputDecoration(
                              'Your in-game username',
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty
                                    ? 'Required'
                                    : null,
                          ),
                          const SizedBox(height: 32),

                          // Save button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }

                                await controller.addAccount(
                                  _selectedGameId!,
                                  _ingameNameController.text,
                                );

                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(30),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}