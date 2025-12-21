import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turnaplay_mobile/modules/game_account/models/GameAccountAPI.dart';
import 'package:turnaplay_mobile/modules/game_account/models/GameAccountEntry.dart';
import 'package:turnaplay_mobile/modules/tournament_registration/models/team_entry.dart';
import 'package:turnaplay_mobile/modules/tournaments/models/TournamentEntry.dart';
import '../util.dart';
import '../widgets/whatever.dart';

class EditGameAccountForm extends StatefulWidget {
  final Team team; // passed from previous page
  final Tournament tournament;
  const EditGameAccountForm({
    super.key,
    required this.team,
    required this.tournament,
  });

  @override
  State<EditGameAccountForm> createState() => _EditGameAccountFormState();
}

class _EditGameAccountFormState extends State<EditGameAccountForm> {
  final _formKey = GlobalKey<FormState>();
  List<GameAccountEntry>? _gameAccounts;
  String? _selectedGameAccountId;
  bool _isLoading = true;

  Future<void> _loadState() async {
    _gameAccounts = await context.read<GameAccountApi>().fetchAccounts(
      gameId: widget.tournament.gameId,
    );

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedGameAccountId == null) {
      return;
    }

    final payload = {
      'team_id': widget.team.teamId,
      'game_account_id': _selectedGameAccountId,
    };

    final responseBody = await sendPost(
      context.read(),
      'api/team/member/update/',
      payload,
    );
    if (responseBody != null && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Change Game Account')),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel('Game Account'),
              DropdownButtonFormField<String>(
                decoration: buildInputDecoration('Select Game Account'),
                items: _gameAccounts!
                    .map(
                      (gameAccount) => DropdownMenuItem<String>(
                        value: gameAccount.id,
                        child: Text(gameAccount.ingameName),
                      ),
                    )
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedGameAccountId = val),
                validator: (val) =>
                    val == null ? 'Please select a game account' : null,
              ),

              buildElevatedButtonText(
                onPressed: _submitForm,
                text: 'Change Game Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
