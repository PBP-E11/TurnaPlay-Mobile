import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game_account/models/GameAccountController.dart';

class GameAccountPickerDialog extends StatefulWidget {
  const GameAccountPickerDialog({super.key});

  @override
  State<GameAccountPickerDialog> createState() => _GameAccountPickerDialogState();
}

class _GameAccountPickerDialogState extends State<GameAccountPickerDialog> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = context.read<GameAccountController>();
      await controller.loadAccounts();
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameAccountController>();

    return AlertDialog(
      title: const Text("Choose Game Account"),
      content: SizedBox(
        width: 420,
        child: Builder(
          builder: (context) {
            if (controller.loading) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.error != null) {
              return Text(controller.error!);
            }

            final accounts = controller.accounts;
            if (accounts.isEmpty) {
              return const Text("No active game accounts found.");
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: accounts.map((a) {
                  final label = "${a.game} • ${a.ingameName}";
                  return RadioListTile<String>(
                    value: a.id,
                    groupValue: _selectedId,
                    onChanged: (v) => setState(() => _selectedId = v),
                    title: Text(label),
                    subtitle: Text(a.id),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _selectedId == null ? null : () => Navigator.pop(context, _selectedId),
          child: const Text("OK"),
        ),
      ],
    );
  }
}