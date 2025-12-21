import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:turnaplay_mobile/modules/tournaments/models/TournamentEntry.dart';
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
      });
    }
  }

  Future<void> _leaveTeam() async {
    final payload = {'team_id': _team!.teamId};
    final uri = _team!.isUserLeader
        ? 'api/team/delete/'
        : 'api/team/member/delete/';

    final responseBody = await sendPost(
      context.read<CookieRequest>(),
      uri,
      payload,
    );

    if (responseBody != null && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTeamDetails();
  }

  @override
  Widget build(BuildContext context) {
    if (_team == null) {
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
      onPressed: () {
        // TODO: proper redirect
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CreateTeamForm(tournament: widget.tournament),
          ),
        );
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
        // TODO: proper redirect
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CreateTeamForm(tournament: widget.tournament),
          ),
        );
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
        // TODO: proper redirect
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CreateTeamForm(tournament: widget.tournament),
          ),
        );
      },
      child: const Text('Add Member'),
    );
  }
}
