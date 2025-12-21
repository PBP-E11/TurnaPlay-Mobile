import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/TournamentInviteEntry.dart';

class InviteListScreen extends StatefulWidget {
  const InviteListScreen({super.key});

  @override
  State<InviteListScreen> createState() => _InviteListScreenState();
}

class _InviteListScreenState extends State<InviteListScreen> {
  late Future<(TournamentInviteResponse, TournamentInviteResponse)> _future;


  static const String baseUrl = "http://127.0.0.1:8000";

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(TournamentInviteResponse, TournamentInviteResponse)> _load() async {
    final request = context.read<CookieRequest>();

    final incomingJson = await request.get("$baseUrl/api/invites/incoming/");
    final outgoingJson = await request.get("$baseUrl/api/invites/outgoing/");

    final incoming = TournamentInviteResponse.fromJson(
      Map<String, dynamic>.from(incomingJson),
    );
    final outgoing = TournamentInviteResponse.fromJson(
      Map<String, dynamic>.from(outgoingJson),
    );

    return (incoming, outgoing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tournament Invites")),
      body: FutureBuilder<(TournamentInviteResponse, TournamentInviteResponse)>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final (incomingRes, outgoingRes) = snapshot.data!;
          final incoming = incomingRes.invites;
          final outgoing = outgoingRes.invites;

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text("Incoming (${incoming.length})",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...incoming.map(_InviteTile.new),

              const SizedBox(height: 16),

              Text("Outgoing (${outgoing.length})",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...outgoing.map(_InviteTile.new),
            ],
          );
        },
      ),
    );
  }
}

class _InviteTile extends StatelessWidget {
  final TournamentInvite invite;
  const _InviteTile(this.invite);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text("${invite.tournament.name} • ${invite.team.name}"),
        subtitle: Text("${invite.status} • ${invite.createdAt.toLocal()}"),
      ),
    );
  }
}