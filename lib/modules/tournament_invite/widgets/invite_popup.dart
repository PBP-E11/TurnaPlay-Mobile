import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class InvitePopupPoller extends StatefulWidget {
  final Widget child;
  final String baseUrl;
  final Duration interval;
  final VoidCallback onOpenInvites;
  final VoidCallback? onAfterDialog;

  const InvitePopupPoller({
    super.key,
    required this.child,
    required this.onOpenInvites,
    this.baseUrl = "$HOST:8000",
    this.interval = const Duration(seconds: 10),
    this.onAfterDialog,
  });

  @override
  State<InvitePopupPoller> createState() => _InvitePopupPollerState();
}

class _InvitePopupPollerState extends State<InvitePopupPoller> {
  Timer? _timer;
  DateTime _lastPoll = DateTime.now();
  String? _lastSeenLatestCreatedAt;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.interval, (_) async {
      await _poll();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    if (!mounted) return;
    if (_dialogOpen) return;

    final request = context.read<CookieRequest>();

    dynamic res;
    try {
      res = await request.get("${widget.baseUrl}/api/invites/new/");
    } catch (_) {
      _lastPoll = DateTime.now();
      return;
    }

    if (res is! Map) {
      _lastPoll = DateTime.now();
      return;
    }

    final map = Map<String, dynamic>.from(res as Map);
    final ok = map["ok"] == true;
    if (!ok) {
      _lastPoll = DateTime.now();
      return;
    }

    final pendingCount = (map["pending_count"] is int)
        ? map["pending_count"] as int
        : 0;
    final latestCreatedAt = map["latest_created_at"] as String?;

    final hasNew =
        pendingCount > 0 &&
        latestCreatedAt != null &&
        latestCreatedAt.isNotEmpty &&
        latestCreatedAt != _lastSeenLatestCreatedAt;

    if (!hasNew) {
      _lastPoll = DateTime.now();
      return;
    }

    _lastSeenLatestCreatedAt = latestCreatedAt;
    _lastPoll = DateTime.now();

    await _showInviteDialog(pendingCount);
  }

  Future<void> _showInviteDialog(int pendingCount) async {
    if (!mounted) return;

    _dialogOpen = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("New tournament invite"),
          content: Text(
            pendingCount == 1
                ? "You have 1 pending invite."
                : "You have $pendingCount pending invites.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Later"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                widget.onOpenInvites();
              },
              child: const Text("Open invites"),
            ),
          ],
        );
      },
    );

    _dialogOpen = false;
    widget.onAfterDialog?.call();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
