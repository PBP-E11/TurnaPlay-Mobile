import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:turnaplay_mobile/modules/game_account/models/GameAccountAPI.dart';
import 'package:turnaplay_mobile/modules/game_account/models/GameAccountEntry.dart';
import 'package:turnaplay_mobile/modules/tournament_registration/widgets/components.dart';
import 'package:turnaplay_mobile/modules/tournaments/models/TournamentEntry.dart';
import '../screens/view_team.dart';
import '../util.dart';

class CreateTeamForm extends StatefulWidget {
  final Tournament tournament; // passed from previous page
  const CreateTeamForm({super.key, required this.tournament});

  @override
  State<CreateTeamForm> createState() => _CreateTeamFormState();
}

class _CreateTeamFormState extends State<CreateTeamForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _teamNameController = TextEditingController();
  List<GameAccountEntry>? _gameAccounts;
  String? _selectedGameAccountId;
  bool _isLoading = true;

  Future<void> _loadState() async {
    {
      final payload = {'tournament_id': widget.tournament.id};

      final responseBody = await sendPost(
        context.read<CookieRequest>(),
        'api/team/details/',
        payload,
      );
      if (responseBody != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ViewTeam(tournament: widget.tournament),
          ),
        );
        return;
      }
    }

    if (mounted) {
      _gameAccounts = await context.read<GameAccountApi>().fetchAccounts(
        gameId: widget.tournament.gameId,
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedGameAccountId == null) {
      return;
    }

    final payload = {
      'tournament_id': widget.tournament.id,
      'leader_game_account_id': _selectedGameAccountId,
      'team_name': _teamNameController.text,
    };

    setState(() => _isLoading = true);
    final responseBody = await sendPost(
      context.read(),
      'api/team/create/',
      payload,
    );
    if (responseBody != null) {
      debugPrint('Submitted form and got: $responseBody');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ViewTeam(tournament: widget.tournament),
          ),
        );
      }
    }
    setState(() => _isLoading = false);
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
      appBar: AppBar(title: const Text('Create Team')),
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

              buildLabel('Team Name'),
              TextFormField(
                controller: _teamNameController,
                decoration: buildInputDecoration('Team Name'),
                validator: (val) => val == null || val.isEmpty
                    ? 'Please enter a team name'
                    : null,
              ),

              // Submit button
              buildElevatedButtonText(
                onPressed: _submitForm,
                text: 'Create Team',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
