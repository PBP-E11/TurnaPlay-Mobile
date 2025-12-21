import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/TournamentInviteEntry.dart';

enum InviteTileKind { incoming, outgoing }

class InviteTile extends StatelessWidget {
  final TournamentInvite invite;
  final InviteTileKind kind;
  final String baseUrl;
  final VoidCallback onChanged;

  const InviteTile({
    super.key,
    required this.invite,
    required this.kind,
    required this.baseUrl,
    required this.onChanged,
  });

  Future<void> _showSnack(BuildContext context, String text) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<int?> _askGameAccountId(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choose Game Account"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "game_account_id",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) return null;
    return int.tryParse(result);
  }

  Future<void> _postRespond(
    BuildContext context, {
    required String inviteId,
    required String action,
    int? gameAccountId,
  }) async {
    final request = context.read<CookieRequest>();

    final payload = <String, dynamic>{
      "invite_id": inviteId,
      "action": action,
    };

    if (gameAccountId != null) {
      payload["game_account_id"] = gameAccountId;
    }

    final res = await request.postJson(
      "$baseUrl/api/invites/respond/",
      jsonEncode(payload),
    );

    final ok = (res is Map && res["ok"] == true);
    if (!ok) {
      final msg = (res is Map && res["message"] != null)
          ? res["message"].toString()
          : "Request failed";
      await _showSnack(context, msg);
      return;
    }

    await _showSnack(context, "Success");
    onChanged();
  }

  Future<void> _postCancel(BuildContext context, {required String inviteId}) async {
    final request = context.read<CookieRequest>();

    final res = await request.postJson(
      "$baseUrl/api/invites/cancel/",
      jsonEncode({"invite_id": inviteId}),
    );

    final ok = (res is Map && res["ok"] == true);
    if (!ok) {
      final msg = (res is Map && res["message"] != null)
          ? res["message"].toString()
          : "Request failed";
      await _showSnack(context, msg);
      return;
    }

    await _showSnack(context, "Canceled");
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final title = "${invite.tournament.name} • ${invite.team.name}";
    final subtitle = "${invite.status} • ${invite.createdAt.toLocal()}";

    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: _buildActions(context),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (kind == InviteTileKind.incoming) {
      return Wrap(
        spacing: 8,
        children: [
          OutlinedButton(
            onPressed: () async {
              await _postRespond(
                context,
                inviteId: invite.id,
                action: "reject",
              );
            },
            child: const Text("Reject"),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = await _askGameAccountId(context);
              if (id == null) {
                await _showSnack(context, "Invalid game_account_id");
                return;
              }
              await _postRespond(
                context,
                inviteId: invite.id,
                action: "accept",
                gameAccountId: id,
              );
            },
            child: const Text("Accept"),
          ),
        ],
      );
    }

    return OutlinedButton(
      onPressed: () async {
        await _postCancel(context, inviteId: invite.id);
      },
      child: const Text("Cancel"),
    );
  }
}