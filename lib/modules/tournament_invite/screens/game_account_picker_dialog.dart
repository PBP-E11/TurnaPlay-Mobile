import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../game_account/models/GameAccountAPI.dart';
import '../../game_account/models/GameAccountController.dart';
import '../../game_account/models/GameAccountEntry.dart';

class GameAccountPickerDialog {
  static Future<String?> show(BuildContext context) async {
    return showDialog<String?>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          child: ChangeNotifierProvider<GameAccountController>(
            create: (ctx) {
              final req = ctx.read<CookieRequest>();
              return GameAccountController(GameAccountApi(req));
            },
            child: const _GameAccountPickerBody(),
          ),
        );
      },
    );
  }
}

class _GameAccountPickerBody extends StatelessWidget {
  const _GameAccountPickerBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameAccountController>();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F5F5),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context, null),
          ),
          title: const Text('Choose Game Account'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: () => controller.loadAccounts(),
            ),
          ],
        ),
        body: controller.loading
            ? const Center(child: CircularProgressIndicator())
            : controller.error != null
                ? Center(child: Text(controller.error!))
                : _AccountList(accounts: controller.accounts),
      ),
    );
  }
}

class _AccountList extends StatelessWidget {
  final List<GameAccountEntry> accounts;

  const _AccountList({required this.accounts});

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return const Center(child: Text("No game accounts found."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final acc = accounts[index];
        return Card(
          child: ListTile(
            title: Text(acc.ingameName),
            subtitle: Text(acc.gameName ?? "Unknown game"),
            onTap: () => Navigator.pop(context, acc.id),
          ),
        );
      },
    );
  }
}