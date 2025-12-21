import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:turnaplay_mobile/modules/tournament_invite/screens/send_invite_form.dart';
import 'package:turnaplay_mobile/modules/tournament_registration/screens/change_game_account_form.dart';
import 'package:turnaplay_mobile/modules/tournament_registration/screens/edit_team_name_form.dart';
import 'package:turnaplay_mobile/modules/tournaments/models/TournamentEntry.dart';
import 'package:turnaplay_mobile/settings.dart';
import 'create_team_form.dart';
import '../models/team_entry.dart';
import '../models/team_member_entry.dart';
import '../util.dart';

class ViewTeam extends StatefulWidget {
  final Tournament tournament; // passed from previous page
  const ViewTeam({super.key, required this.tournament});

  @override
  State<ViewTeam> createState() => _ViewTeamState();
}

class _ViewTeamState extends State<ViewTeam> {
  Team? _team;
  bool _isLoading = true;

  Future<void> _fetchTeamDetails() async {
    final payload = {'tournament_id': widget.tournament.id};

    final responseBody = await sendPost(
      context.read<CookieRequest>(),
      'api/team/details/',
      payload,
    );

    if (responseBody == null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CreateTeamForm(tournament: widget.tournament),
        ),
      );
    } else {
      setState(() {
        _team = Team.fromJson(responseBody as Map<String, dynamic>);
        _isLoading = false;
      });
    }
  }

  Future<void> _leaveTeam() async {
    final payload = {'team_id': _team!.teamId};
    final uri = _team!.isUserLeader
        ? 'api/team/delete/'
        : 'api/team/member/delete/';

    setState(() {
      _isLoading = true;
    });

    final responseBody = await sendPost(
      context.read<CookieRequest>(),
      uri,
      payload,
    );

    if (responseBody != null && mounted) {
      Navigator.pop(context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTeamDetails();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: const CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('View Team')),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          children: ([Text(_team!.teamName), _buildEditTeamButton(context)])
            ..addAll(_buildMembers(context))
            ..addAll([
              _buildChangeGameAccountButton(context),
              _buildAddMemberButton(context),
              _buildLeaveTeamButton(context),
            ]),
        ),
      ),
    );
  }

  List<Widget> _buildMembers(BuildContext _) {
    List<Widget> widgets = [];
    for (TeamMember member in _team!.members) {
      widgets.add(
        Row(
          children: [
            Text(member.gameAccountName!),
            Text(member.userAccountName!),
          ],
        ),
      );
    }
    return widgets;
  }

  Widget _buildEditTeamButton(BuildContext context) {
    if (!_team!.isUserLeader) {
      return Container();
    }

    return ElevatedButton(
      onPressed: () async {
        final newTeamName = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditTeamNameForm(team: _team!),
          ),
        );
        if (newTeamName != null) {
          setState(() {
            _team!.teamName = newTeamName;
          });
        }
      },
      child: const Text('Edit Team Name'),
    );
  }

  Widget _buildChangeGameAccountButton(BuildContext context) {
    if (!_team!.isUserInTeam) {
      return Container();
    }

    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditGameAccountForm(
              tournament: widget.tournament,
              team: _team!,
            ),
          ),
        ).then((_) {
          _isLoading = true;
          _fetchTeamDetails();
        });
      },
      child: const Text('Change Game Account'),
    );
  }

  Widget _buildLeaveTeamButton(BuildContext context) {
    if (!_team!.isUserInTeam) {
      return Container();
    }

    return ElevatedButton(
      onPressed: () {
        _leaveTeam();
      },
      child: const Text('Leave Team'),
    );
  }

  Widget _buildAddMemberButton(BuildContext context) {
    if (!_team!.isUserLeader) {
      return Container();
    }

    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SendInviteFormScreen(baseUrl: HOST),
          ),
        ).then((_) {
          _isLoading = true;
          _fetchTeamDetails();
        });
      },
      child: const Text('Add Member'),
    );
  }
}
