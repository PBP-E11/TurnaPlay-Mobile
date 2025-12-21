import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/TournamentInviteEntry.dart';
import '../screens/game_account_picker_dialog.dart';

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

  bool get _isPending => invite.status.toLowerCase() == "pending";

  Future<void> _showSnack(BuildContext context, String text) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<String?> _pickGameAccountId(BuildContext context) async {
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => const GameAccountPickerDialog(),
    );
    if (result == null || result.trim().isEmpty) return null;
    return result.trim();
  }

  String _extractErrorMessage(dynamic res) {
    if (res is Map) {
      if (res["error"] != null) return res["error"].toString();
      if (res["message"] != null) return res["message"].toString();
      if (res["detail"] != null) return res["detail"].toString();
    }
    return "Request failed";
  }

  Future<void> _postRespond(
    BuildContext context, {
    required String inviteId,
    required String action,
    String? gameAccountId,
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
      await _showSnack(context, _extractErrorMessage(res));
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
      await _showSnack(context, _extractErrorMessage(res));
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
    if (!_isPending) return const SizedBox.shrink();

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
              final gameAccountId = await _pickGameAccountId(context);
              if (gameAccountId == null) {
                await _showSnack(context, "No game account selected");
                return;
              }
              await _postRespond(
                context,
                inviteId: invite.id,
                action: "accept",
                gameAccountId: gameAccountId,
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