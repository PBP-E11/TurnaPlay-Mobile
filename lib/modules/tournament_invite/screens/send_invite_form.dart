import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:turnaplay_mobile/modules/tournaments/screens/creationForm.dart';
import 'package:turnaplay_mobile/widgets/base_screen.dart';

class SendInviteFormScreen extends StatefulWidget {
  final String baseUrl;

  const SendInviteFormScreen({
    super.key,
    required this.baseUrl,
  });

  @override
  State<SendInviteFormScreen> createState() => _SendInviteFormScreenState();
}

class _SendInviteFormScreenState extends State<SendInviteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _tournamentIdController = TextEditingController();
  final _teamIdController = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _tournamentIdController.dispose();
    _teamIdController.dispose();
    super.dispose();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final request = context.read<CookieRequest>();

      final payload = <String, dynamic>{
        "username": _usernameController.text.trim(),
        "tournament_id": _tournamentIdController.text.trim(),
        "team_id": _teamIdController.text.trim(),
      };

      final res = await request.postJson(
        "${widget.baseUrl}/api/invites/send/",
        jsonEncode(payload),
      );

      final ok = (res is Map && res["ok"] == true);
      if (!ok) {
        final msg = (res is Map && res["message"] != null)
            ? res["message"].toString()
            : "Failed to send invite";
        _snack(msg);
        return;
      }

      _snack("Invite sent");
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _snack("Error: $e");
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TournamentForm(),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      initialIndex: 0,
      onTap: _onItemTapped,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Send Invitation",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Target username",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final s = (v ?? "").trim();
                  if (s.isEmpty) return "Username is required";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tournamentIdController,
                decoration: const InputDecoration(
                  labelText: "tournament_id",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final s = (v ?? "").trim();
                  if (s.isEmpty) return "tournament_id is required";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _teamIdController,
                decoration: const InputDecoration(
                  labelText: "team_id",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final s = (v ?? "").trim();
                  if (s.isEmpty) return "team_id is required";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Send"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}