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
          children: ([Text(_team!.teamName) as Widget])
            ..addAll(buildMembers(context, _team!)),
        ),
      ),
    );
  }
}

List<Widget> buildMembers(BuildContext context, Team team) {
  List<Widget> widgets = [];
  for (TeamMember member in team.members) {
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
