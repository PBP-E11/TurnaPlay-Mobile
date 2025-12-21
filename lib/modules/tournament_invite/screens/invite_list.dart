import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/TournamentInviteEntry.dart';
import '../widgets/invite_tile.dart';

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

  void _reload() {
    setState(() {
      _future = _load();
    });
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
      appBar: AppBar(
        title: const Text("Tournament Invites"),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<(TournamentInviteResponse, TournamentInviteResponse)>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("No data"));
          }

          final (incomingRes, outgoingRes) = snapshot.data!;
          final incoming = incomingRes.invites;
          final outgoing = outgoingRes.invites;

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Text(
                  "Incoming (${incoming.length})",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (incoming.isEmpty)
                  const Text("No incoming invites.")
                else
                  ...incoming.map(
                    (invite) => InviteTile(
                      invite: invite,
                      kind: InviteTileKind.incoming,
                      baseUrl: baseUrl,
                      onChanged: _reload,
                    ),
                  ),

                const SizedBox(height: 20),

                Text(
                  "Outgoing (${outgoing.length})",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (outgoing.isEmpty)
                  const Text("No outgoing invites.")
                else
                  ...outgoing.map(
                    (invite) => InviteTile(
                      invite: invite,
                      kind: InviteTileKind.outgoing,
                      baseUrl: baseUrl,
                      onChanged: _reload,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}