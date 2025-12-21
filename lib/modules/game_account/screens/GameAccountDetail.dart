import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turnaplay_mobile/widgets/base_screen.dart';
import 'package:turnaplay_mobile/modules/tournaments/screens/creationForm.dart';
import '../models/GameAccountEntry.dart';
import '../models/GameAccountController.dart';

class GameAccountDetailScreen extends StatefulWidget {
  final GameAccountEntry account;

  const GameAccountDetailScreen(this.account, {super.key});

  @override
  State<GameAccountDetailScreen> createState() =>
      _GameAccountDetailScreenState();
}

class _GameAccountDetailScreenState extends State<GameAccountDetailScreen> {
  static const Color primaryColor = Color(0xFF494598);

  bool _editing = false;

  late GameAccountEntry _account;
  late TextEditingController _ingameNameController;
  String? _selectedGameId;

  late String _originalIngameName;
  late String? _originalGameId;

  @override
  void initState() {
    super.initState();

    _account = widget.account;
    _originalIngameName = _account.ingameName;
    _originalGameId = _account.game;
    _ingameNameController = TextEditingController(text: _account.ingameName);
    _selectedGameId = _account.game;
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
      body: SingleChildScrollView(
        child: Column(
          children: [
             // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  
                  const Text(
                    'Account Detail',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  if (!_editing)
                    Align(
                    alignment: Alignment.centerRight,
                     child:IconButton(
                      icon: const Icon(Icons.edit, color: primaryColor),
                      onPressed: () {
                        setState(() => _editing = true);
                      },
                    ),
                    ),
                ],
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: _editing ? _editSection(controller) : _viewSection(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // VIEW MODE 

  Widget _viewSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(
          icon: Icons.videogame_asset,
          label: 'Game',
          value: _account.gameName ?? 'Unknown',
        ),
        const SizedBox(height: 20),
        _infoRow(
          icon: Icons.person,
          label: 'In-game Name',
          value: _account.ingameName,
        ),
        const SizedBox(height: 20),
        _infoRow(
          icon: Icons.check_circle_outline,
          label: 'Status',
          value: _account.active ? 'Active' : 'Inactive',
          valueColor: _account.active ? Colors.green : Colors.grey[600],
        ),
      ],
    );
  }

  // EDIT MODE 
  Widget _editSection(GameAccountController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Game
        _buildLabel('Game'),
        DropdownButtonFormField<String>(
          value: _selectedGameId,
          decoration: _buildInputDecoration('Select a game'),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: controller.games
              .map(
                (g) => DropdownMenuItem(
                  value: g.id,
                  child: Text(g.name),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedGameId = v),
        ),
        const SizedBox(height: 16),

        // In-game name
        _buildLabel('In-game Name'),
        TextFormField(
          controller: _ingameNameController,
          style: const TextStyle(color: Colors.black),
          decoration:
              _buildInputDecoration('Your in-game username'),
        ),
        const SizedBox(height: 32),

        // Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _editing = false);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 2,
                ),
                onPressed: () async {
                  final newName = _ingameNameController.text.trim();
                  final newGameId = _selectedGameId;

                  if (newName == _originalIngameName &&
                      newGameId == _originalGameId) {
                    setState(() => _editing = false);
                    return;
                  }

                  final updated = await controller.updateAccount(
                    id: _account.id,
                    gameId: newGameId ?? _originalGameId!,
                    ingameName:
                        newName.isEmpty ? _originalIngameName : newName,
                  );

                  setState(() {
                    _account = updated;
                    _originalIngameName = updated.ingameName;
                    _originalGameId = updated.game;
                    _editing = false;
                  });
                },
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: primaryColor),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}